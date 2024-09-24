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
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        let button = UIBarButtonItem(customView: datePicker)
        return button
    }()
    
    private lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.placeholder = NSLocalizedString(
            "searchController.searchBar.placeholder",
            comment: "Placeholder for the search bar"
        )
        return searchController
    }()
    
    private lazy var stubView: UIView = {
        let caption = NSLocalizedString("trackers.stubView.caption",
                                        comment: "Caption for the stub view when there are no items to track")
        let stubView = StubView(frame: .zero)
        stubView.configure(with: caption)
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
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var trackerStore: TrackerStoreProtocol = {
        TrackerStore(delegate: self, for: currentDate)
    }()
    
    private enum Constants {
        static let cellIdentifier = "cell"
        static let headerIdentifier = "header"
    }
    
    private var currentDate: Date = Date().startOfDay
    
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
    }
    
    deinit {
       removeObservers()
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        view.addSubview(stubView)
        view.addSubview(UIView(frame: .zero))
        view.addSubview(collectionView)
        collectionView.isHidden = true
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stubView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func configureViewState() {
        collectionView.isHidden = trackerStore.isEmpty
        stubView.isHidden = !trackerStore.isEmpty
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = datePickerButton
        navigationItem.searchController = searchController
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = NSLocalizedString("trackers.tabBarItem.title", comment: "Title for the Trackers tab")
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
        
        trackerStore.updateDate(currentDate)
        collectionView.reloadData()
        configureViewState()
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
            menuItems.append(self.createDeleteAction())
            
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
            
            let viewController = EditTrackerViewController(
                completionStatus: self.trackerStore.completionStatus(for: indexPath),
                categoryName: self.trackerStore.categoryName(for: indexPath)
            )
            
            let navigationController = UINavigationController(rootViewController: viewController)
            navigationController.modalPresentationStyle = .formSheet
            present(navigationController, animated: true)
        }
    }
    
    private func createDeleteAction() -> UIAction {
        let title = NSLocalizedString("contextMenu.delete.title", comment: "Delete item")
        return UIAction(title: title, attributes: .destructive) { action in
            
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
