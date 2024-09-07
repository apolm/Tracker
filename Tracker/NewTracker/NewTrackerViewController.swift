import UIKit

final class NewTrackerViewController: AddTrackerFlowViewController {
    // MARK: - Private Properties
    private lazy var tableView: UITableView = {
        let table = BaseTable(frame: .zero, style: .grouped)
        table.baseTableDelegate = self
        table.register(TextCell.self, forCellReuseIdentifier: textCellID)
        table.register(LinkCell.self, forCellReuseIdentifier: linkCellID)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Отменить", for: .normal)
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
        ActionButton(title: "Создать", target: self, action: #selector(createButtonDidTap))
    }()
    
    private let isRegular: Bool
    private var name: String = ""
    private var days: Set<Weekday>?
    private let textCellID = "TextCell"
    private let linkCellID = "LinkCell"
    
    // MARK: - Public Methods
    init(isRegular: Bool) {
        self.isRegular = isRegular
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        setupConstraints()
        configureViewState()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        title = isRegular ? "Новая привычка" : "Новое нерегулярное событие"
    }
    
    // MARK: - Private Methods
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),
            
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.trailingAnchor.constraint(equalTo: createButton.leadingAnchor, constant: -8),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor)
        ])
    }
    
    private func configureViewState() {
        let daysAreValid = days?.isEmpty == false || !isRegular
        createButton.isEnabled = !name.isEmpty && daysAreValid
    }
    
    // MARK: - Actions
    @objc private func cancelButtonDidTap() {
        self.dismiss(animated: true)
    }
    
    @objc private func createButtonDidTap() {
        let color = [
            UIColor(red: 51/255.0, green: 207/255.0, blue: 105/255.0, alpha: 1),
            UIColor(red: 255/255.0, green: 136/255.0, blue: 30/255.0, alpha: 1),
            UIColor(red: 255/255.0, green: 103/255.0, blue: 77/255.0, alpha: 1),
            UIColor(red: 173/255.0, green: 86/255.0, blue: 218/255.0, alpha: 1),
            UIColor(red: 249/255.0, green: 212/255.0, blue: 212/255.0, alpha: 1),
            UIColor(red: 246/255.0, green: 196/255.0, blue: 139/255.0, alpha: 1)
        ].randomElement()!
        let emoji = ["🌺", "😻", "❤️", "💫", "🥦", "🥇"].randomElement()!
        let tracker = Tracker(id: UUID(), name: name, color: color, emoji: emoji, days: days)
        NotificationCenter.default.post(name: TrackersViewController.notificationName, object: tracker)
        self.dismiss(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - BaseTableDataSourceDelegate
extension NewTrackerViewController: BaseTableDataSourceDelegate {
    func numberOfSections() -> Int {
        2
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        section == 0 ? 1 : (isRegular ? 2 : 1)
    }
    
    func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: textCellID, for: indexPath) as? TextCell else {
                return UITableViewCell()
            }
            cell.onTextChange = { [weak self] text in
                self?.name = text
                self?.configureViewState()
            }
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: linkCellID, for: indexPath) as? LinkCell else {
                return UITableViewCell()
            }
            if indexPath.row == 0 {
                cell.configure(title: "Категория", caption: "Общая категория")
            } else if indexPath.row == 1 {
                var caption = ""
                if let days {
                    if days.count == Weekday.allCases.count {
                        caption = "Каждый день"
                    } else {
                        caption = Weekday.orderedWeekdays()
                            .filter{ days.contains($0) }
                            .map{ $0.shortName }
                            .joined(separator: ", ")
                    }
                }
                cell.configure(title: "Расписание", caption: caption)
            }
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
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
