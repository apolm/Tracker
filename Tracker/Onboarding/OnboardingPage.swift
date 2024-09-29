import UIKit

final class OnboardingPage: UIViewController {
    // MARK: - Private Properties
    private lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var captionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .boldSystemFont(ofSize: 32)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var finishButton: ActionButton = {
        let title = NSLocalizedString("onboarding.finishButton.title", comment: "Title for the finish button")
        return ActionButton(title: title, target: self, action: #selector(finishButtonDidTap))
    }()
    
    private var labelOffset: CGFloat = {
        return UIScreen.main.bounds.width <= 320 ? 24 : 64
    }()
    private var onCompletion: (() -> Void)?
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(backgroundImage)
        view.addSubview(captionLabel)
        view.addSubview(finishButton)
        
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            captionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            captionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            captionLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: labelOffset),
            
            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            finishButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Private Methods
    func config(text: String, background: UIImage, onCompletion: (() -> Void)?) {
        backgroundImage.image = background
        captionLabel.text = text
        self.onCompletion = onCompletion
    }
    
    // MARK: - Actions
    @objc private func finishButtonDidTap(_ sender: UIButton) {
        onCompletion?()
    }
}
