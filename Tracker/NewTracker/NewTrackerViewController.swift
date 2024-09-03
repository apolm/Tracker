import UIKit

//TODO: - доступность кнопки, видимость расписания

final class NewTrackerViewController: AddTrackerFlowViewController {
    // MARK: - Public Properties
    let isRegular: Bool //TODO: обработать
    
    // MARK: - Private Properties
    private lazy var tableView: UITableView = {
        let table = BaseTable(frame: .zero, style: .grouped)
        table.baseTableDelegate = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.clearButtonMode = .whileEditing
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.translatesAutoresizingMaskIntoConstraints = false
                
        return textField
    }()
    
    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var scheduleLabel: UILabel = {
        let label = UILabel()
        label.text = "Расписание"
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
    
    private var schedule: Set<Weekday>?
    
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
    
    // MARK: - Actions
    @objc private func cancelButtonDidTap() {
        
    }
    
    @objc private func createButtonDidTap() {
        
    }
}

// MARK: - BaseTableDataSourceDelegate
extension NewTrackerViewController: BaseTableDataSourceDelegate {
    func numberOfSections() -> Int {
        2
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        section == 0 ? 1 : 2
    }
    
    func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 0 {
            cell.contentView.addSubview(textField)
            NSLayoutConstraint.activate([
                textField.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                textField.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -12),
                textField.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                textField.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
            ])
        } else {
            cell.accessoryType = .disclosureIndicator
            
            if indexPath.row == 0 {
                cell.contentView.addSubview(categoryLabel)
                
                NSLayoutConstraint.activate([
                    categoryLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                    categoryLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                    categoryLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                    categoryLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
                ])
            } else if indexPath.row == 1 {
                cell.contentView.addSubview(scheduleLabel)
                
                NSLayoutConstraint.activate([
                    scheduleLabel.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
                    scheduleLabel.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -16),
                    scheduleLabel.topAnchor.constraint(equalTo: cell.contentView.topAnchor),
                    scheduleLabel.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor)
                ])
            }
        }
        return cell
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 1 {
            let viewController = ScheduleViewController(days: schedule)
            viewController.onCompletion = { [weak self] result in
                self?.schedule = result
            }
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
