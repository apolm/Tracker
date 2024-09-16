import UIKit

final class TrackerCell: UICollectionViewCell {
    // MARK: - Private Properties
    private lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.ypGray.withAlphaComponent(0.3).cgColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var circleView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(Self.completeButtonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var isCompleted = false
    private var numberOfCompletions = 0
    private var color = UIColor()
    
    // MARK: - Public Properties
    weak var delegate: TrackerCellDelegate?
    
    // MARK: - Public Methods
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(cardView)
        cardView.addSubview(circleView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(emojiLabel)
        addSubview(counterLabel)
        addSubview(completeButton)
        
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func config(with tracker: Tracker, numberOfCompletions: Int, isCompleted: Bool, completionIsEnabled: Bool) {
        self.isCompleted = isCompleted
        self.numberOfCompletions = numberOfCompletions
        self.color = tracker.color
        
        cardView.backgroundColor = tracker.color
        completeButton.isEnabled = completionIsEnabled
        titleLabel.text = tracker.name
        emojiLabel.text = tracker.emoji
        
        configureViewState()
    }
    
    // MARK: - Private Methods
    private func configureViewState() {
        if isCompleted {
            completeButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            completeButton.backgroundColor = color.withAlphaComponent(0.3)
        } else {
            completeButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completeButton.backgroundColor = color
        }
        
        let remainder100 = numberOfCompletions % 100
        let remainder10 = numberOfCompletions % 10
        if remainder100 >= 11 && remainder100 <= 14 {
            counterLabel.text = "\(numberOfCompletions) дней"
        } else if remainder10 == 1 {
            counterLabel.text = "\(numberOfCompletions) день"
        } else if remainder10 >= 2 && remainder10 <= 4 {
            counterLabel.text = "\(numberOfCompletions) дня"
        } else {
            counterLabel.text = "\(numberOfCompletions) дней"
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cardView.topAnchor.constraint(equalTo: topAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            circleView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            circleView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            circleView.widthAnchor.constraint(equalToConstant: 24),
            circleView.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            titleLabel.topAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            emojiLabel.centerXAnchor.constraint(equalTo: circleView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: circleView.centerYAnchor),
            
            completeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34),
            
            counterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: completeButton.leadingAnchor, constant: -8),
            counterLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            counterLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24)
        ])
    }
    
    // MARK: - Actions
    @objc
    private func completeButtonDidTap() {
        isCompleted.toggle()
        delegate?.trackerCellDidChangeCompletion(for: self, to: isCompleted)
    }
}
