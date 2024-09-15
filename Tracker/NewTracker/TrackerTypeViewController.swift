import UIKit

final class TrackerTypeViewController: AddTrackerFlowViewController {
    private lazy var regularTrackerButton: ActionButton = {
        ActionButton(title: "Привычка", target: self, action: #selector(buttonDidTap))
    }()
    
    private lazy var irregularTrackerButton: ActionButton = {
        ActionButton(title: "Нерегулярное событие", target: self, action: #selector(buttonDidTap))
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [regularTrackerButton, irregularTrackerButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            regularTrackerButton.heightAnchor.constraint(equalToConstant: 60),
            irregularTrackerButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        title = "Создание трекера"
    }
    
    @objc private func buttonDidTap(_ sender: UIButton) {
        let isRegular = sender == regularTrackerButton
        let viewController = NewTrackerViewController(isRegular: isRegular)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
