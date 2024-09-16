import UIKit

final class ColorCell: UICollectionViewCell, SelectableCell {
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var color: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(colorView)
        
        NSLayoutConstraint.activate([
            colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            colorView.heightAnchor.constraint(equalToConstant: 40),
            colorView.widthAnchor.constraint(equalToConstant: 40)
        ])
        
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        contentView.layer.borderWidth = 3
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        color = nil
        colorView.backgroundColor = .clear
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
    
    func config(with color: UIColor) {
        self.color = color
        colorView.backgroundColor = color
    }
    
    func select() {
        guard let color else { return }
        contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
    
    func deselect() {
        contentView.layer.borderColor = UIColor.clear.cgColor
    }
}
