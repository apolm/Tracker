import UIKit

final class NewTrackerViewController: AddTrackerFlowViewController {
    let isRegular: Bool
    
    init(isRegular: Bool) {
        self.isRegular = isRegular
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = isRegular ? "Новая привычка" : "Новое нерегулярное событие"
    }
}
