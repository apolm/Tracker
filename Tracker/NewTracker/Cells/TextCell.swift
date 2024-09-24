import UIKit

final class TextCell: UITableViewCell {
    private var onTextChange: ((String) -> Void)?
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 17, weight: .regular)
        textField.clearButtonMode = .whileEditing
        textField.borderStyle = .none
        textField.backgroundColor = .clear
        textField.returnKeyType = .go
        textField.autocorrectionType = .no
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        textField.translatesAutoresizingMaskIntoConstraints = false
                
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(text: String, placeholder: String, onTextChange: @escaping (String) -> Void) {
        textField.text = text
        textField.placeholder = placeholder
        self.onTextChange = onTextChange
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        onTextChange?(textField.text ?? "")
    }
}

extension TextCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
