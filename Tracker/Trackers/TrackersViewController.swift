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
        collectionView.register(CategoryHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: headerIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = UIEdgeInsets(top: 24, left: 0, bottom: 0, right: 0)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private var currentDate: Date = Date()
    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var completedIds: Set<UUID> = [] // Trackers completed in current date
    
    // Temp collections (before CoreData)
    private var allTrackers: [Tracker] = [] // All created trackers
    
    private let cellIdentifier = "cell"
    private let headerIdentifier = "header"
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 10)
    
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
    }
    
    //TODO
    private func makeMockData() {
        let t1 = Tracker(id: UUID(), name: "Поливать растения", color: UIColor(red: 51/255.0, green: 207/255.0, blue: 105/255.0, alpha: 1), emoji: "🌺", days: [.monday, .friday])
        let t2 = Tracker(id: UUID(), name: "Кошка заслонила камеру на созвоне", color: UIColor(red: 255/255.0, green: 136/255.0, blue: 30/255.0, alpha: 1), emoji: "😻", days: [.tuesday, .thursday, .saturday])
        let t3 = Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсапе", color: UIColor(red: 255/255.0, green: 103/255.0, blue: 77/255.0, alpha: 1), emoji: "❤️", days: [.wednesday])
//        let category = TrackerCategory(name: "Домашний уют", trackers: [t1, t2, t3])
//        categories.append(category)
        
        let t4 = Tracker(id: UUID(), name: "Свидания в апреле", color: UIColor(red: 173/255.0, green: 86/255.0, blue: 218/255.0, alpha: 1), emoji: "💫", days: [.monday, .friday])
        let t5 = Tracker(id: UUID(), name: "Хорошее настроение", color: UIColor(red: 249/255.0, green: 212/255.0, blue: 212/255.0, alpha: 1), emoji: "🚴‍♂️", days: [.tuesday, .thursday, .saturday])
        let t6 = Tracker(id: UUID(), name: "Тест 3", color: UIColor(red: 246/255.0, green: 196/255.0, blue: 139/255.0, alpha: 1), emoji: "🚴‍♂️", days: [.tuesday, .thursday, .saturday])
//        let category2 = TrackerCategory(name: "Радостные мелочи", trackers: [t4, t5, t6])
//        categories.append(category2)
        allTrackers.append(contentsOf: [t1, t2, t3, t4, t5, t6])
        update()
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
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = datePickerButton
        navigationItem.searchController = searchController
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Трекеры"
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
        
        
//        if allTrackers.count == 0 {
//            let t1 = Tracker(id: UUID(), name: "Поливать растения", color: UIColor(red: 51/255.0, green: 207/255.0, blue: 105/255.0, alpha: 1), emoji: "🌺", days: [.monday, .friday])
//            allTrackers.append(t1)
//            update()
//        } else if allTrackers.count == 1 {
//            let t2 = Tracker(id: UUID(), name: "Кошка заслонила камеру на созвоне", color: UIColor(red: 255/255.0, green: 136/255.0, blue: 30/255.0, alpha: 1), emoji: "😻", days: [.tuesday, .thursday, .saturday])
//            allTrackers.append(t2)
//            update()
//        } else if allTrackers.count == 2 {
//            let t3 = Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсапе", color: UIColor(red: 255/255.0, green: 103/255.0, blue: 77/255.0, alpha: 1), emoji: "❤️", days: [.wednesday])
//            allTrackers.append(t3)
//            update()
//        } else if allTrackers.count == 3 {
//            let t4 = Tracker(id: UUID(), name: "Свидания в апреле", color: UIColor(red: 173/255.0, green: 86/255.0, blue: 218/255.0, alpha: 1), emoji: "💫", days: [.monday, .friday])
//            allTrackers.append(t4)
//            update()
//        } else if allTrackers.count == 4 {
//            let t5 = Tracker(id: UUID(), name: "Хорошее настроение", color: UIColor(red: 249/255.0, green: 212/255.0, blue: 212/255.0, alpha: 1), emoji: "🚴‍♂️", days: [.tuesday, .thursday, .saturday])
//            allTrackers.append(t5)
//            update()
//        } else if allTrackers.count == 5 {
//            let t6 = Tracker(id: UUID(), name: "Тест 3", color: UIColor(red: 246/255.0, green: 196/255.0, blue: 139/255.0, alpha: 1), emoji: "🚴‍♂️", days: [.tuesday, .thursday, .saturday])
//            allTrackers.append(t6)
//            update()
//        } else {
//            return
//        }
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        
        if let datePicker = datePickerButton.customView as? UIDatePicker {
            datePicker.removeFromSuperview()
        }
        
        update()
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as? CategoryHeader else {
            return UICollectionReusableView()
        }
        view.config(with: categories[indexPath.section])
        return view
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        cell.config(with: categories[indexPath.section].trackers[indexPath.row])
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
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: params.leftInset, bottom: 16, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
}

private struct GeometricParams {
    let cellCount: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInset: CGFloat, rightInset: CGFloat, cellSpacing: CGFloat) {
        self.cellCount = cellCount
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacing
    }
}
