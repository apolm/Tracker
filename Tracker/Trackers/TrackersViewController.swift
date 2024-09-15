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
        searchController.searchBar.placeholder = "Поиск"
        return searchController
    }()
    
    private lazy var stubView: UIView = {
        let stubView = TrackersStubView()
        stubView.translatesAutoresizingMaskIntoConstraints = false
        return stubView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(TrackerCell.self,
                                forCellWithReuseIdentifier: cellIdentifier)
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var trackerStore: TrackerStoreProtocol = {
        TrackerStore(delegate: self, for: currentDate)
    }()
    
    private var currentDate: Date = Date().startOfDay

// TODO: - REMOVE ++
// ----------------------------------------------------------------------------------------------------

    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    
    // Helpers
    private var completedIds: Set<UUID> = [] // Trackers completed in current date
    
    // Temp (before CoreData)
    private var allTrackers: [Tracker] = [] // All created trackers
    private var completionsCounter: [UUID: Int] = [:] // Number of tracker completions

// ----------------------------------------------------------------------------------------------------
// TODO: - REMOVE --
    
    static let notificationName = NSNotification.Name("AddNewTracker")
    
    private let cellIdentifier = "cell"
    private let headerIdentifier = "header"
    private let layoutParams = GeometricParams(columnCount: 2, rowCount: 0, leftInset: 16, rightInset: 16, topInset: 12, bottomInset: 16, columnSpacing: 10, rowSpacing: 0)
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        view.addSubview(stubView)
        view.addSubview(UIView(frame: .zero))
        view.addSubview(collectionView)
        collectionView.isHidden = true
        
        setupConstraints()
        setupNavigationBar()
        configureViewState()
        
        NotificationCenter.default.addObserver(self, selector: #selector(addNewTracker), name: TrackersViewController.notificationName, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: TrackersViewController.notificationName, object: nil)
    }
    
    // MARK: - Private Methods
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
        title = "Трекеры"
    }
    
    @objc
    private func addNewTracker(_ notification: Notification) {
        guard let tracker = notification.object as? Tracker else { return }
        trackerStore.addTracker(tracker)
    }
    
    private func update() {
        let completedIrregulars = Set(
            allTrackers.filter { tracker in
                !tracker.isRegular &&
                completedTrackers.first { $0.trackerId == tracker.id } != nil
            }
        )
        completedIds = Set(
            completedTrackers
                .filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                .map { $0.trackerId }
        )
        
        let weekday = Weekday(date: currentDate)
        let selectedTrackers = allTrackers.filter { tracker in
            if let days = tracker.days {
                return days.contains(weekday)
            } else {
                return completedIds.contains(tracker.id) || !completedIrregulars.contains(tracker)
            }
        }
        categories = selectedTrackers.isEmpty ? [] : [TrackerCategory(name: "Общая категория", trackers: selectedTrackers)]
        
        collectionView.reloadData()
        
        collectionView.isHidden = selectedTrackers.isEmpty
        stubView.isHidden = !selectedTrackers.isEmpty
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
        
        
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as? SectionHeader else {
            return UICollectionReusableView()
        }
        view.config(with: trackerStore.sectionName(for: indexPath.section))
        return view
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        let completionStatus = trackerStore.completionStatus(for: indexPath)
        
        cell.config(with: completionStatus.tracker,
                    numberOfCompletions: completionStatus.numberOfCompletions,
                    isCompleted: completionStatus.isCompleted,
                    completionIsEnabled: currentDate <= Date().startOfDay)
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
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        
        if isCompleted {
            completedTrackers.append(TrackerRecord(trackerId: tracker.id, date: currentDate))
            completedIds.insert(tracker.id)
            completionsCounter[tracker.id] = (completionsCounter[tracker.id] ?? 0) + 1
        } else {
            completedTrackers.removeAll { $0.trackerId == tracker.id && $0.date == currentDate }
            completedIds.remove(tracker.id)
            if let currentCount = completionsCounter[tracker.id], currentCount > 0 {
                completionsCounter[tracker.id] = currentCount - 1
            }
        }
    }
}

// MARK: - TrackerStoreDelegate
extension TrackersViewController: TrackerStoreDelegate {
//    func didInsertSection(at sectionIndex: Int) {
//        collectionView.performBatchUpdates({
//            collectionView.insertSections(IndexSet(integer: sectionIndex))
//        }, completion: nil)
//    }
//    
//    func didDeleteSection(at sectionIndex: Int) {
//        collectionView.performBatchUpdates({
//            collectionView.deleteSections(IndexSet(integer: sectionIndex))
//        }, completion: nil)
//    }
    
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
        
        configureViewState()
    }
}

//TODO: -  Debug
extension TrackersViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        let button1 = UIBarButtonItem(
            image: UIImage(systemName: "1.circle"), style: .plain, target: self, action: #selector(debugButton1Tap))
        button1.tintColor = .red
        
        let button2 = UIBarButtonItem(
            image: UIImage(systemName: "2.circle"), style: .plain, target: self, action: #selector(debugButton2Tap))
        button2.tintColor = .red
        
        navigationItem.leftBarButtonItems?.append(contentsOf: [button1, button2])
    }
    
    @objc private func debugButton1Tap() {
        let viewController = Test()
        viewController.modalPresentationStyle = .formSheet
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .formSheet
        present(navigationController, animated: true)
    }
    
    @objc private func debugButton2Tap() {
        let tracker = Tracker(id: UUID(),
                              name: "Test1",
                              color: UIColor(hex: "#007BFA") ?? .clear,
                              emoji: "❤️",
                              days: Set(arrayLiteral: Weekday.sunday))
        trackerStore.addTracker(tracker)
    }
}
