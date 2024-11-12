import UIKit

final class TrackerTypeViewController: AddTrackerFlowViewController {
    private lazy var regularTrackerButton: ActionButton = {
        ActionButton(
            title: NSLocalizedString(
                "regularTrackerButton.title",
                comment: "Title for the habit tracker button"
            ),
            target: self,
            action: #selector(
                buttonDidTap
            )
        )
    }()
    
    private lazy var irregularTrackerButton: ActionButton = {
        ActionButton(
            title: NSLocalizedString(
                "irregularTrackerButton.title",
                comment: "Title for the irregular event tracker button"
            ),
            target: self,
            action: #selector(
                buttonDidTap
            )
        )
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
        
        title = NSLocalizedString(
            "createTrackerView.title",
            comment: "Title for the tracker creation view"
        )
    }
    
    @objc private func buttonDidTap(_ sender: UIButton) {
        let isRegular = sender == regularTrackerButton
        let viewController = EditTrackerViewController(isRegular: isRegular)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
