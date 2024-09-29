import UIKit

final class FilterViewController: AddTrackerFlowViewController {
    private lazy var tableView: BaseTable = {
        let table = BaseTable(frame: .zero, style: .grouped)
        table.baseTableDelegate = self
        table.register(FilterCell.self, forCellReuseIdentifier: cellReuseID)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private let allFilters: [TrackerFilterOption] = TrackerFilterOption.allCases
    private let cellReuseID = "FilterCell"
    
    var onFilterSelected: ((TrackerFilterOption) -> Void)?
    var currentFilter: TrackerFilterOption?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        title = NSLocalizedString("filter.title", comment: "Filter")
    }
}

// MARK: - BaseTableDataSourceDelegate
extension FilterViewController: BaseTableDataSourceDelegate {
    func numberOfSections() -> Int {
        1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        allFilters.count
    }
    
    func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseID, for: indexPath) as? FilterCell else {
            return UITableViewCell()
        }
        
        let item = allFilters[indexPath.row]
        let isSelected = currentFilter == item
        cell.configure(name: item.localizedTitle, isSelected: isSelected)
        
        return cell
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
        let selectedFilter = allFilters[indexPath.row]
        onFilterSelected?(selectedFilter)
        self.dismiss(animated: true)
    }
}
