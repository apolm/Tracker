import UIKit

final class EditTrackerViewController: AddTrackerFlowViewController {
    // MARK: - Private Properties
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var numberOfCompletionsLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = BaseTable(frame: .zero, style: .grouped)
        table.baseTableDelegate = self
        table.register(TextCell.self, forCellReuseIdentifier: Constants.textCellID)
        table.register(LinkCell.self, forCellReuseIdentifier: Constants.linkCellID)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(SectionHeader.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Constants.headerID)
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: Constants.footerID)
        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: Constants.emojiCellID)
        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: Constants.colorCellID)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        let title = NSLocalizedString("cancelButton.title", comment: "Title for the cancel button")
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.backgroundColor = .ypWhite
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(cancelButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var createButton: ActionButton = {
        let title = isNew 
        ? NSLocalizedString("createButton.title", comment: "Title for the create button")
        : NSLocalizedString("saveButton.title", comment: "Title for the save button")
        
        return ActionButton(title: title, target: self, action: #selector(createButtonDidTap))
    }()
    
    private let isNew: Bool
    private let isRegular: Bool
    private let id: UUID
    private var name: String = ""
    private var categoryName: String = ""
    private var color = UIColor.clear
    private var emoji = ""
    private var days: Set<Weekday>?
    
    private let numberOfCompletions: Int
    
    private enum Constants {
        static let headerHeight: CGFloat = 18
        static let footerHeight: CGFloat = 16
        
        static let headerID = "header"
        static let footerID = "footerIdentifier"
        
        static let textCellID = "TextCell"
        static let linkCellID = "LinkCell"
        static let emojiCellID = "EmojiCell"
        static let colorCellID = "ColorCell"
    }
    
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    private let sectionLayout = GeometricParams(
        columnCount: 6,
        rowCount: 3,
        leftInset: 16,
        rightInset: 16,
        topInset: 24,
        bottomInset: 24,
        columnSpacing: 5,
        rowSpacing: 0
    )
    private var cellSize: CGFloat {
        let availableWidth = view.frame.width - sectionLayout.totalInsetWidth
        return availableWidth / CGFloat(sectionLayout.columnCount)
    }
    private var selectedCells: [Int: IndexPath] = [:]
    
    // MARK: - Public Methods
    init(isRegular: Bool) {
        isNew = true
        self.isRegular = isRegular
        id = UUID()
        numberOfCompletions = 0
        super.init(nibName: nil, bundle: nil)
    }
    
    init(completionStatus: TrackerCompletion, categoryName: String) {
        isNew = false
        isRegular = !(completionStatus.tracker.days?.isEmpty ?? true)
        id = completionStatus.tracker.id
        name = completionStatus.tracker.name
        self.categoryName = categoryName
        color = completionStatus.tracker.color
        emoji = completionStatus.tracker.emoji
        days = completionStatus.tracker.days
        numberOfCompletions = completionStatus.numberOfCompletions
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        
        if isNew {
            configureForNewTracker()
        } else {
            configureForExistingTracker()
        }
        
        configureViewState()
        addHideKeyboardTapGesture()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateTableViewHeight()
    }
    
    private func updateTableViewHeight() {
        tableView.layoutIfNeeded()
        tableViewHeightConstraint?.constant = tableView.contentSize.height
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        if !isNew {
            contentView.addSubview(numberOfCompletionsLabel)
        }
        contentView.addSubview(tableView)
        contentView.addSubview(collectionView)
        contentView.addSubview(cancelButton)
        contentView.addSubview(createButton)
        scrollView.addSubview(contentView)
        view.addSubview(scrollView)
    }
    
    private func setupConstraints() {
        let sectionHeight = cellSize * CGFloat(sectionLayout.rowCount) + sectionLayout.totalInsetHeight + Constants.headerHeight
        let totalCollectionHeight = sectionHeight * 2 + Constants.footerHeight
        
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 250)
        tableViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        if isNew {
            NSLayoutConstraint.activate([
                tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                tableView.topAnchor.constraint(equalTo: contentView.topAnchor)
            ])
        } else {
            NSLayoutConstraint.activate([
                numberOfCompletionsLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                numberOfCompletionsLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                numberOfCompletionsLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                
                tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                tableView.topAnchor.constraint(equalTo: numberOfCompletionsLabel.bottomAnchor, constant: 16),
            ])
        }
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 16),
            collectionView.heightAnchor.constraint(equalToConstant: totalCollectionHeight),
            
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            createButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            createButton.topAnchor.constraint(equalTo: cancelButton.topAnchor),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor),
            createButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    private func configureForNewTracker() {
        title = isRegular
                ? NSLocalizedString("newTrackerView.title.regular", comment: "Title for creating a new habit")
                : NSLocalizedString("newTrackerView.title.irregular", comment: "Title for creating a new irregular event")
    }
    
    private func configureForExistingTracker() {
        title = isRegular
                ? NSLocalizedString("existingTrackerView.title.regular", comment: "Title for editing existing habit")
                : NSLocalizedString("existingTrackerView.title.irregular", comment: "Title for editing existing irregular event")
        
        numberOfCompletionsLabel.text = String(
            format: NSLocalizedString(
                "numberOfDays",
                comment: "Number of days"
            ),
            numberOfCompletions
        )
        
        if let emojiIndex = emojis.firstIndex(of: emoji) {
            let indexPath = IndexPath(item: emojiIndex, section: 0)
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            selectedCells[0] = indexPath
        }
        
        if let colorIndex = colors.firstIndex(of: color.toHex()) {
            let indexPath = IndexPath(item: colorIndex, section: 1)
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
            selectedCells[1] = indexPath
        }
    }
    
    private func configureViewState() {
        let daysAreValid = days?.isEmpty == false || !isRegular
        createButton.isEnabled = 
            !categoryName.isEmpty && 
            !name.isEmpty &&
            daysAreValid &&
            color != .clear &&
            !emoji.isEmpty
    }
    
    private func addHideKeyboardTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func cancelButtonDidTap() {
        self.dismiss(animated: true)
    }
    
    @objc private func createButtonDidTap() {
        let notification = isNew
        ? TrackersViewController.addTrackerNotificationName
        : TrackersViewController.updateTrackerNotificationName
        
        let tracker = Tracker(id: id, name: name, color: color, emoji: emoji, days: days)
        let category = TrackerCategory(name: categoryName, trackers: [tracker])
        NotificationCenter.default.post(name: notification, object: category)
        
        self.dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension EditTrackerViewController {
    var emojis: [String] {
        [
            "🙂", "😻", "🌺", "🐶", "❤️", "😱",
            "😇", "😡", "🥶", "🤔", "🙌", "🍔",
            "🥦", "🏓", "🥇", "🎸", "🌴", "😪"
        ]
    }
    
    var colors: [String] {
        [
            "#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4",
            "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC",
            "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"
        ]
    }
}

// MARK: - BaseTableDataSourceDelegate
extension EditTrackerViewController: BaseTableDataSourceDelegate {
    func numberOfSections() -> Int {
        2
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        section == 0 ? 1 : (isRegular ? 2 : 1)
    }
    
    func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            return dequeueAndConfigureTextCell(from: tableView, for: indexPath)
            
        case 1:
            return dequeueAndConfigureLinkCell(from: tableView, for: indexPath)
            
        default:
            return UITableViewCell()
        }
    }
    
    private func dequeueAndConfigureTextCell(from tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.textCellID, for: indexPath) as? TextCell else {
            return UITableViewCell()
        }
        let placeholder = NSLocalizedString(
            "newTrackerView.name.placeholder",
            comment: "Placeholder for the tracker name input"
        )
        cell.configure(text: name, placeholder: placeholder) { [weak self] text in
            self?.name = text
            self?.configureViewState()
        }
        return cell
    }
    
    private func dequeueAndConfigureLinkCell(from tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.linkCellID, for: indexPath) as? LinkCell else {
            return UITableViewCell()
        }
        if indexPath.row == 0 {
            cell.configure(title: NSLocalizedString("category", comment: "Title for the category cell"), caption: categoryName)
        } else if indexPath.row == 1 {
            var caption = ""
            if let days {
                if days.count == Weekday.allCases.count {
                    caption = NSLocalizedString("schedule.isEveryDay", comment: "Caption for every day in the schedule")
                } else {
                    caption = Weekday.orderedWeekdays()
                        .filter{ days.contains($0) }
                        .map{ $0.shortName }
                        .joined(separator: ", ")
                }
            }
            cell.configure(title: NSLocalizedString("schedule", comment: "Title for the schedule cell"), caption: caption)
        }
        return cell
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            let viewModel = CategoriesViewModel()
            viewModel.delegate = self
            let viewController = CategoriesViewController(viewModel: viewModel, currentCategory: categoryName)
            navigationController?.pushViewController(viewController, animated: true)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            let viewController = ScheduleViewController(days: days)
            viewController.onCompletion = { [weak self] result in
                self?.days = result
                self?.tableView.reloadData()
                self?.configureViewState()
            }
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegate
extension EditTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.headerID, for: indexPath) as? SectionHeader else {
                return UICollectionReusableView()
            }
            let sectionTitle = indexPath.section == 0
                ? NSLocalizedString("newTrackerView.emojiGroup.title", comment: "Title for the Emoji section")
                : NSLocalizedString("newTrackerView.colorGroup.title", comment: "Title for the Color section")
            view.config(with: sectionTitle)
            return view
        } else if kind == UICollectionView.elementKindSectionFooter {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.footerID, for: indexPath)
            footerView.backgroundColor = .clear
            return footerView
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if let previousIndexPath = selectedCells[indexPath.section],
           let previousCell = collectionView.cellForItem(at: previousIndexPath) as? SelectableCell {
            guard previousIndexPath != indexPath else { return }
            previousCell.deselect()
            collectionView.deselectItem(at: previousIndexPath, animated: true)
        }
        if let cell = collectionView.cellForItem(at: indexPath) as? SelectableCell {
            selectedCells[indexPath.section] = indexPath
            cell.select()
            
            if indexPath.section == 0 {
                emoji = emojis[indexPath.row]
            } else {
                color = UIColor(hex: colors[indexPath.item]) ?? .clear
            }
            configureViewState()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension EditTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return section == 0 ? emojis.count : colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.emojiCellID, for: indexPath) as? EmojiCell else {
                return UICollectionViewCell()
            }
            cell.prepareForReuse()
            cell.config(with: emojis[indexPath.item])
            if selectedCells[indexPath.section] == indexPath {
                cell.select()
            }
            return cell
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.colorCellID, for: indexPath) as? ColorCell else {
                return UICollectionViewCell()
            }
            cell.prepareForReuse()
            cell.config(with: UIColor(hex: colors[indexPath.item]) ?? UIColor())
            if selectedCells[indexPath.section] == indexPath {
                cell.select()
            }
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension EditTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: Constants.headerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: collectionView.frame.width, height: Constants.footerHeight)
        }
        return CGSize(width: 0, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: sectionLayout.topInset, left: sectionLayout.leftInset, bottom: sectionLayout.bottomInset, right: sectionLayout.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        sectionLayout.rowSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        sectionLayout.columnSpacing
    }
}

// MARK: - CategorySelectionDelegate
extension EditTrackerViewController: CategorySelectionDelegate {
    func didSelectCategory(_ name: String) {
        categoryName = name
        tableView.reloadData()
        configureViewState()
        
        navigationController?.popViewController(animated: true)
    }
}
