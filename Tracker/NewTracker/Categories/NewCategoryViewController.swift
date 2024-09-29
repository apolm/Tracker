import UIKit

final class NewCategoryViewController: AddTrackerFlowViewController {
    // MARK: - Private Properties
    private lazy var tableView: BaseTable = {
        let table = BaseTable(frame: .zero, style: .grouped)
        table.baseTableDelegate = self
        table.register(TextCell.self, forCellReuseIdentifier: Constants.cellIdentifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var createButton: ActionButton = {
        let title = NSLocalizedString("doneButton.title", comment: "Title for the done button")
        return ActionButton(title: title, target: self, action: #selector(createButtonDidTap))
    }()
    
    private lazy var store: TrackerCategoryStore = {
        TrackerCategoryStore(delegate: nil)
    }()
    
    private enum Constants {
        static let cellIdentifier = "cell"
    }
    
    private var name: String = "" {
        didSet {
            configureViewState()
        }
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupConstraints()
        configureViewState()
        addHideKeyboardTapGesture()
                
        title = NSLocalizedString(
            "newCategoryView.title",
            comment: "Title for the new category view"
        )
    }
    
    // MARK: - Private Methods
    private func setupViews() {
        view.addSubview(tableView)
        view.addSubview(createButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: createButton.topAnchor, constant: -16),
            
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureViewState() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        createButton.isEnabled = !trimmedName.isEmpty
    }
    
    private func addHideKeyboardTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func createButtonDidTap() {
        store.addCategory(name)
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - BaseTableDataSourceDelegate
extension NewCategoryViewController: BaseTableDataSourceDelegate {
    func numberOfSections() -> Int {
        1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        1
    }
    
    func cellForRowAt(_ tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath) as? TextCell else {
            return UITableViewCell()
        }
        let placeholder = NSLocalizedString(
            "newCategoryView.name.placeholder",
            comment: "Placeholder for the category name input"
        )
        cell.configure(text: "", placeholder: placeholder) { [weak self] text in
            self?.name = text
        }
        return cell
    }
    
    func didSelectRowAt(indexPath: IndexPath) {
    }
}
