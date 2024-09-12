import UIKit

final class Test: AddTrackerFlowViewController {
    private lazy var testLabel: UILabel = {
        let label = UILabel()
        label.text = "Test"
        label.backgroundColor = UIColor(red: 51/255.0, green: 207/255.0, blue: 105/255.0, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var testLabel2: UILabel = {
        let label = UILabel()
        label.text = "Test"
        label.backgroundColor = UIColor(red: 255/255.0, green: 103/255.0, blue: 77/255.0, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let x = !testLabel.isEnabled && !testLabel2.isEnabled
        
        title = "Test"
        view.addSubview(testLabel)
        view.addSubview(testLabel2)
        
        NSLayoutConstraint.activate([
            testLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            testLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            testLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            testLabel.heightAnchor.constraint(equalToConstant: 60),
            
            testLabel2.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            testLabel2.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            //testLabel2.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
            testLabel2.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
}



