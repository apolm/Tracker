import UIKit

final class TabBarController: UITabBarController {
    private var topBorder: CALayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackers = TrackersViewController()
        trackers.tabBarItem = UITabBarItem(
            title: NSLocalizedString("trackers.tabBarItem.title", comment: "Title for the Trackers tab"),
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil)
        let navigationController = UINavigationController(rootViewController: trackers)
        
        let statistics = StatisticsViewController()
        statistics.tabBarItem = UITabBarItem(
            title: NSLocalizedString("statistics.tabBarItem.title", comment: "Title for the Statistics tab"),
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil)
        
        viewControllers = [navigationController, statistics]
        
        setupTopBorder()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let topBorder {
            topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if previousTraitCollection?.userInterfaceStyle != traitCollection.userInterfaceStyle {
            topBorder?.backgroundColor = UIColor.ypGrayDark.cgColor
        }
    }
    
    private func setupTopBorder() {
        let border = CALayer()
        border.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 0.5)
        border.backgroundColor = UIColor.ypGrayDark.cgColor
        tabBar.layer.addSublayer(border)
        topBorder = border
    }
}
