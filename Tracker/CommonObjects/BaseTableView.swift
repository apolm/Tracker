import UIKit

protocol BaseTableDataSourceDelegate: AnyObject {
    func numberOfSections() -> Int
    func numberOfRowsInSection(_ section: Int) -> Int
    func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
    func didSelectRowAt(indexPath: IndexPath)
}

final class BaseTable: UITableView, UITableViewDataSource, UITableViewDelegate {
    weak var baseTableDelegate: BaseTableDataSourceDelegate?
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setupTableView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTableView()
    }

    private func setupTableView() {
        self.separatorStyle = .none
        self.backgroundColor = .ypWhite
        self.delegate = self
        self.dataSource = self
    }

    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        baseTableDelegate?.numberOfSections() ?? 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        baseTableDelegate?.numberOfRowsInSection(section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = baseTableDelegate?.cellForRowAt(tableView, indexPath: indexPath) ?? UITableViewCell()
        
        cell.selectionStyle = .none
        cell.backgroundColor = .ypBackground
        
        if indexPath.row != tableView.numberOfRows(inSection: indexPath.section) - 1 {
            addSeparator(to: cell)
        }
        
        if tableView.numberOfRows(inSection: indexPath.section) == 1 {
            cell.layer.cornerRadius = 16
            cell.layer.masksToBounds = true
        } else {
            if indexPath.row == 0 {
                cell.layer.cornerRadius = 16
                cell.layer.masksToBounds = true
                cell.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            }
            
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                cell.layer.cornerRadius = 16
                cell.layer.masksToBounds = true
                cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            }
        }
        
        return cell
    }
    
    private func addSeparator(to cell: UITableViewCell) {
        let separator = UIView()
        separator.backgroundColor = .ypGray
        separator.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(separator)
        
        NSLayoutConstraint.activate([
            separator.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 16),
            separator.widthAnchor.constraint(equalToConstant: cell.frame.width - 32),
            separator.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        baseTableDelegate?.didSelectRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75.0
    }
}
