import UIKit

final class ScheduleViewController: AddTrackerFlowViewController {
    private lazy var tableView: BaseTable = {
        let table = BaseTable(frame: .zero, style: .grouped)
        table.baseTableDelegate = self
        table.register(ScheduleCell.self, forCellReuseIdentifier: cellReuseID)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    private lazy var completeButton: ActionButton = {
        ActionButton(title: "Готово", target: self, action: #selector(completeButtonDidTap))
    }()
    private var schedule: [(Weekday, Bool)] = []
    private let cellReuseID = "ScheduleCell"
    
    var onCompletion: ((Set<Weekday>) -> Void)?
    
    init(days: Set<Weekday>? = nil) {
        schedule = Weekday.orderedWeekdays().map { day in
            (day, days?.contains(day) ?? false)
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        view.addSubview(completeButton)
        setupConstraints()
        
        title = "Расписание"
    }
    
    @objc func completeButtonDidTap(_ sender: UIButton) {
        let days = Set(schedule.filter{ $0.1 }.map{ $0.0 })
        onCompletion?(days)
        
        navigationController?.popViewController(animated: true)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: completeButton.topAnchor, constant: -16),
            
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            completeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - BaseTableDataSourceDelegate
extension ScheduleViewController: BaseTableDataSourceDelegate {
    func numberOfSections() -> Int {
        1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return schedule.count
    }
    
    func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as? ScheduleCell else {
            return UITableViewCell()
        }
        
        let item = schedule[indexPath.row]
        cell.configure(with: item.0, isOn: item.1) { [weak self] isOn in
            self?.schedule[indexPath.row].1 = isOn
        }
        
        return cell
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
    }
}

