import UIKit

final class EmojiCell: UICollectionViewCell, SelectableCell {
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(emojiLabel)
        
        NSLayoutConstraint.activate([
            emojiLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            emojiLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            emojiLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            emojiLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        contentView.layer.cornerRadius = 16
        contentView.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = ""
        contentView.backgroundColor = .clear
    }
    
    func config(with emoji: String) {
        emojiLabel.text = emoji
    }
    
    func select() {
        contentView.backgroundColor = .ypLightGray
    }
    
    func deselect() {
        contentView.backgroundColor = .clear
    }
}
