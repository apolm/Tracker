import UIKit

final class ScheduleCell: UITableViewCell {
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var daySwitch: UISwitch = {
        let daySwitch = UISwitch()
        daySwitch.onTintColor = .ypBlue
        daySwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        return daySwitch
    }()
    
    private var onToggle: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(dayLabel)
        contentView.addSubview(daySwitch)
        
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.trailingAnchor.constraint(equalTo: daySwitch.leadingAnchor, constant: -16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with weekday: Weekday, isOn: Bool, onToggle: @escaping (Bool) -> Void) {
        dayLabel.text = weekday.fullName
        daySwitch.isOn = isOn
        self.onToggle = onToggle
    }
    
    @objc private func switchToggled(_ sender: UISwitch) {
        onToggle?(daySwitch.isOn)
    }
}
