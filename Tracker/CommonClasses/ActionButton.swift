import UIKit

final class ActionButton: UIButton {
    override var isEnabled: Bool {
        didSet {
            setBackgroundColor()
        }
    }
    
    init(title: String, target: Any?, action: Selector) {
        super.init(frame: .zero)
        setTitle(title, for: .normal)
        setTitleColor(.ypWhite, for: .normal)
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        layer.cornerRadius = 16
        layer.masksToBounds = true
        translatesAutoresizingMaskIntoConstraints = false
        addTarget(target, action: action, for: .touchUpInside)
        setBackgroundColor()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setBackgroundColor() {
        backgroundColor = isEnabled ? .ypBlack : .ypGray
    }
}
