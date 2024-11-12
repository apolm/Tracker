import UIKit

final class TrackersViewController: UIViewController {
    // MARK: - Private Properties
    private lazy var addTrackerButton: UIBarButtonItem = {
        let boldWeight = UIImage.SymbolConfiguration(weight: .bold)
        let image = UIImage(systemName: "plus", withConfiguration: boldWeight)
        let button = UIBarButtonItem(image: image,
                                     style: .plain,
                                     target: self,
                                     action: #selector(addTrackerButtonDidTap))
        button.tintColor = .ypBlack
        return button
    }()
    
    private lazy var datePickerButton: UIBarButtonItem = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.backgroundColor = .ypGrayPale
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.layer.cornerRadius = 8
        datePicker.layer.masksToBounds = true
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        let button = UIBarButtonItem(customView: datePicker)
        return button
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
        
        let searchTextField = searchController.searchBar.searchTextField
        searchTextField.clearButtonMode = .never
        searchTextField.attributedPlaceholder = NSAttributedString(
            string: NSLocalizedString("searchController.searchBar.placeholder",
                                      comment: "Placeholder for the search bar"),
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.ypWhiteGray]
        )
        
        if let glassIconView = searchTextField.leftView as? UIImageView {
            glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
            glassIconView.tintColor = .ypWhiteGray
        }
        
        return searchController
    }()
    
    private lazy var stubView: StubView = {
        let stubView = StubView(frame: .zero)
        stubView.translatesAutoresizingMaskIntoConstraints = false
        return stubView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackerCell.self,
                                forCellWithReuseIdentifier: Constants.cellIdentifier)
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Constants.headerIdentifier)
        collectionView.backgroundColor = .ypWhite
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 50, right: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        let title = NSLocalizedString("filter.title", comment: "Filter")
        button.setTitle(title, for: .normal)
        button.backgroundColor = .ypBlue
        button.overrideUserInterfaceStyle = .light
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(filterButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var trackerStore: TrackerStoreProtocol = {
        TrackerStore(delegate: self, date: currentDate, filter: currentFilter)
    }()
    
    private let analyticsService = AnalyticsService()
    
    private enum Constants {
        static let cellIdentifier = "cell"
        static let headerIdentifier = "header"
    }
    
    private var currentDate: Date = Date().startOfDay
    private var currentFilter: TrackerFilterOption = .all
    private var searchQuery: String?
    
    static let addTrackerNotificationName = NSNotification.Name("AddNewTracker")
    static let updateTrackerNotificationName = NSNotification.Name("UpdateTracker")
    
    private let layoutParams = GeometricParams(
        columnCount: 2,
        rowCount: 0,
        leftInset: 16,
        rightInset: 16,
        topInset: 12,
        bottomInset: 16,
        columnSpacing: 10,
        rowSpacing: 0
    )
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        setupViews()
        setupConstraints()
        setupNavigationBar()
        configureViewState()
        addObservers()
        addHideKeyboardTapGesture()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["screen" : "main"])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analyticsService.report(event: "close", params: ["screen" : "main"])
    }
    
    deinit {
       removeObservers()
    }
    
    // MARK: - Public Methods
    func setCurrentDate(to date: Date) {
        currentDate = date.startOfDay
        if let datePicker = datePickerButton.customView as? UIDatePicker {
            datePicker.date = currentDate
        }
        
        if currentFilter == .today && currentDate != Date().startOfDay {
            currentFilter = .all
        }
        
        applyFilterAndUpdateView()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        view.addSubview(stubView)
        view.addSubview(UIView(frame: .zero))
        view.addSubview(collectionView)
        view.addSubview(filterButton)
        collectionView.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stubView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureViewState() {
        let isFilteredEmpty = trackerStore.isFilteredEmpty
        let isDateEmpty = isFilteredEmpty ? trackerStore.isDateEmpty : false
        
        collectionView.isHidden = isFilteredEmpty
        stubView.isHidden = !isFilteredEmpty
        filterButton.isHidden = isDateEmpty
        
        if isDateEmpty {
            let caption = NSLocalizedString("stubView.caption.noTrackersAtDate",
                                            comment: "Caption when there are no trackers for a selected date")
            let image = UIImage(named: "StarEmoji")
            stubView.configure(caption: caption, image: image)
        } else if isFilteredEmpty {
            let caption = NSLocalizedString("stubView.caption.noTrackersMatchFilter",
                                            comment: "Caption when no trackers match the current filter")
            let image = UIImage(named: "MonocleEmoji")
            stubView.configure(caption: caption, image: image)
        }
        
        let filterTitleColor: UIColor = (currentFilter == .all || currentFilter == .today) ? .ypWhite : .ypRed
        filterButton.setTitleColor(filterTitleColor, for: .normal)
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = datePickerButton
        navigationItem.searchController = searchController
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = NSLocalizedString("trackers.tabBarItem.title", comment: "Title for the Trackers tab")
        
        searchController.searchBar.searchTextField.textColor = .ypBlack
    }
    
    private func addObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(addNewTracker),
            name: TrackersViewController.addTrackerNotificationName,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateTracker),
            name: TrackersViewController.updateTrackerNotificationName,
            object: nil
        )
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(
            self,
            name: TrackersViewController.addTrackerNotificationName,
            object: nil
        )
        
        NotificationCenter.default.removeObserver(
            self,
            name: TrackersViewController.updateTrackerNotificationName,
            object: nil
        )
    }
    
    private func addHideKeyboardTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    private func applyFilterAndUpdateView() {
        trackerStore.applyFilter(currentFilter, on: currentDate, with: searchQuery)
        collectionView.reloadData()
        configureViewState()
    }
    
    @objc private func dismissKeyboard() {
        searchController.searchBar.resignFirstResponder()
    }
    
    @objc
    private func addNewTracker(_ notification: Notification) {
        guard let category = notification.object as? TrackerCategory,
              let tracker = category.trackers.first else {
            return
        }
        
        trackerStore.addTracker(tracker, to: category)
    }
    
    @objc
    private func updateTracker(_ notification: Notification) {
        guard let category = notification.object as? TrackerCategory,
              let tracker = category.trackers.first else {
            return
        }
        
        trackerStore.updateTracker(tracker, with: category)
    }
    
    
    // MARK: - Actions
    @objc private func addTrackerButtonDidTap() {
        analyticsService.report(event: "click", params: ["screen" : "main", "item": "add_track"])
        
        let viewController = TrackerTypeViewController()
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date.startOfDay
        
        if let datePicker = datePickerButton.customView as? UIDatePicker {
            datePicker.removeFromSuperview()
        }
        
        if currentFilter == .today && currentDate != Date().startOfDay {
            currentFilter = .all
        }
        
        applyFilterAndUpdateView()
    }
    
    @objc private func filterButtonDidTap() {
        analyticsService.report(event: "click", params: ["screen" : "main", "item": "filter"])
        
        let viewController = FilterViewController()
        viewController.currentFilter = currentFilter
        viewController.onFilterSelected = { [weak self] filter in
            guard let self else { return }
            
            self.currentFilter = filter
            
            if filter == .today {
                self.currentDate = Date().startOfDay
                if let datePicker = datePickerButton.customView as? UIDatePicker {
                    datePicker.date = Date().startOfDay
                }
            }
            
            self.applyFilterAndUpdateView()
        }
        
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.headerIdentifier, for: indexPath) as? SectionHeader else {
            return UICollectionReusableView()
        }
        view.config(with: trackerStore.sectionName(for: indexPath.section))
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemsAt indexPaths: [IndexPath],
                        point: CGPoint) -> UIContextMenuConfiguration? {
        guard let indexPath = indexPaths.first else { return nil }
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell,
              cell.cardView.frame.contains(cell.convert(point, from: collectionView)) else { return nil }
        
        return UIContextMenuConfiguration(identifier: indexPath as NSCopying, actionProvider: { [weak self] actions in
            guard let self = self else { return nil }
            
            var menuItems: [UIAction] = []
            menuItems.append(self.createPinAction(for: indexPath, isPinned: cell.isPinned))
            menuItems.append(self.createEditAction(for: indexPath))
            menuItems.append(self.createDeleteAction(for: indexPath))
            
            return UIMenu(children: menuItems)
        })
    }
    
    private func createPinAction(for indexPath: IndexPath, isPinned: Bool) -> UIAction {
        let title = isPinned ? NSLocalizedString("contextMenu.unpin.title", comment: "Unpin item") :
                               NSLocalizedString("contextMenu.pin.title", comment: "Pin item")
        
        return UIAction(title: title) { [weak self] action in
            guard let self = self else { return }
            if isPinned {
                self.trackerStore.unpinTracker(at: indexPath)
            } else {
                self.trackerStore.pinTracker(at: indexPath)
            }
        }
    }
    
    private func createEditAction(for indexPath: IndexPath) -> UIAction {
        let title = NSLocalizedString("contextMenu.edit.title", comment: "Edit item")
        return UIAction(title: title) { [weak self] action in
            guard let self = self else { return }
            
            self.analyticsService.report(event: "click", params: ["screen" : "main", "item": "edit"])
            
            let viewController = EditTrackerViewController(
                completionStatus: self.trackerStore.completionStatus(for: indexPath),
                categoryName: self.trackerStore.categoryName(for: indexPath)
            )
            
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .formSheet
            present(navigationController, animated: true)
        }
    }
    
    private func createDeleteAction(for indexPath: IndexPath) -> UIAction {
        let title = NSLocalizedString("contextMenu.delete.title", comment: "Delete item")
        return UIAction(title: title, attributes: .destructive) { [weak self] action in
            guard let self = self else { return }
            
            self.analyticsService.report(event: "click", params: ["screen" : "main", "item": "delete"])
            
            let actionSheetController = UIAlertController(
                title: NSLocalizedString("deleteConfirmation.title",
                                         comment: "Are you sure you want to delete this tracker?"),
                message: nil,
                preferredStyle: .actionSheet
            )
            
            let deleteAction = UIAlertAction(
                title: NSLocalizedString("deleteButton.title",
                                         comment: "Delete button title"),
                style: .destructive
            ) { [weak self] _ in
                self?.trackerStore.deleteTracker(at: indexPath)
            }
            
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("cancelButton.title",
                                         comment: "Cancel button title"),
                style: .cancel,
                handler: nil
            )
            
            actionSheetController.addAction(deleteAction)
            actionSheetController.addAction(cancelAction)
            
            actionSheetController.preferredAction = cancelAction
            
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else { return nil }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        let targetedPreview = UITargetedPreview(view: cell.cardView, parameters: parameters)
        return targetedPreview
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfiguration configuration: UIContextMenuConfiguration,
                        dismissalPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        let targetedPreview = UITargetedPreview(view: cell.cardView, parameters: parameters)
        return targetedPreview
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        searchController.searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return trackerStore.numberOfSections
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return trackerStore.numberOfItemsInSection(section)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.cellIdentifier, for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let completionStatus = trackerStore.completionStatus(for: indexPath)
        
        cell.config(with: completionStatus.tracker,
                    numberOfCompletions: completionStatus.numberOfCompletions,
                    isCompleted: completionStatus.isCompleted,
                    completionIsEnabled: currentDate <= Date().startOfDay,
                    isPinned: completionStatus.isPinned)
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - layoutParams.totalInsetWidth
        let cellWidth =  availableWidth / CGFloat(layoutParams.columnCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: layoutParams.topInset, left: layoutParams.leftInset, bottom: layoutParams.bottomInset, right: layoutParams.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        layoutParams.rowSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        layoutParams.columnSpacing
    }
}

// MARK: - TrackerCellDelegate
extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidChangeCompletion(for cell: TrackerCell, to isCompleted: Bool) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        trackerStore.changeCompletion(for: indexPath, to: isCompleted)
        
        analyticsService.report(event: "click", params: ["screen" : "main", "item": "track"])
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        collectionView.performBatchUpdates({
            if !update.deletedSections.isEmpty {
                collectionView.deleteSections(IndexSet(update.deletedSections))
            }
            if !update.insertedSections.isEmpty {
                collectionView.insertSections(IndexSet(update.insertedSections))
            }
            
            collectionView.insertItems(at: update.insertedIndices)
            collectionView.deleteItems(at: update.deletedIndices)
            collectionView.reloadItems(at: update.updatedIndices)
            
            for move in update.movedIndices {
                collectionView.moveItem(at: move.from, to: move.to)
            }
        }, completion: nil)
        
        collectionView.performBatchUpdates({
            for move in update.movedIndices {
                collectionView.reloadItems(at: [move.to])
            }
        }, completion: nil)
        
        configureViewState()
    }
}

// MARK: - UISearchResultsUpdating
extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            searchQuery = searchText
        } else {
            searchQuery = nil
        }
        applyFilterAndUpdateView()
    }
}

