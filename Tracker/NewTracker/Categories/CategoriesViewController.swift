import UIKit

final class CategoriesViewController: AddTrackerFlowViewController {
    // MARK: - Private Properties
    private var viewModel: CategoriesViewModelProtocol
    
    private lazy var tableView: BaseTable = {
        let table = BaseTable(frame: .zero, style: .grouped)
        table.baseTableDelegate = self
        table.register(CategoryCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var addCategoryButton: ActionButton = {
        ActionButton(title: "Добавить категорию", target: self, action: #selector(addCategoryButtonDidTap))
    }()
    
    private let currentCategory: String
    
    private enum Constants {
        static let cellIdentifier = "cell"
    }
    
    // MARK: - View Life Cycle
    init(viewModel: CategoriesViewModelProtocol, currentCategory: String) {
        self.viewModel = viewModel
        self.currentCategory = currentCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        setupBindings()
        
        title = "Категория"
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(addCategoryButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -16),
            
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupBindings() {
        viewModel.onDataChanged = { [weak self] in
            guard let self else { return }
            tableView.reloadData()
        }
    }
    
    // MARK: - Actions
    @objc func addCategoryButtonDidTap(_ sender: UIButton) {
        navigationController?.pushViewController(NewCategoryViewController(), animated: true)
    }
}

// MARK: - BaseTableDataSourceDelegate
extension CategoriesViewController: BaseTableDataSourceDelegate {
    func numberOfSections() -> Int {
        viewModel.numberOfSections
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        viewModel.numberOfCategories(section)
    }
    
    func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.category(at: indexPath)
        cell.configure(name: category.name, isSelected: category.name == currentCategory)
        
        return cell
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
        viewModel.didSelectRowAt(indexPath: indexPath)
    }
}
