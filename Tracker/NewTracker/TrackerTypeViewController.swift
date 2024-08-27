import UIKit

final class TrackerTypeViewController: AddTrackerFlowViewController {
    private lazy var regularTrackerButton: UIButton = {
        return createButton(withTitle: "Привычка")
    }()
    
    private lazy var irregularTrackerButton: UIButton = {
        return createButton(withTitle: "Нерегулярное событие")
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [regularTrackerButton, irregularTrackerButton])
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private func createButton(withTitle title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
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
