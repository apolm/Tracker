import UIKit

final class TrackersListViewController: UIViewController {
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
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        view.addSubview(stubView)
        
        setupConstraints()
        setupNavigationBar()
        
    }
    
    // MARK: - Private Methods
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            stubView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = datePickerButton
        navigationItem.searchController = searchController
        
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Трекеры"
    }
    
    // MARK: - Actions
    @objc private func addTrackerButtonDidTap() {
        let vc = Test()
        vc.modalPresentationStyle = .formSheet
        present(vc, animated: true)
    }
}
