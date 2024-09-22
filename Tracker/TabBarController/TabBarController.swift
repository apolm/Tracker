import UIKit

final class TabBarController: UITabBarController {
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
        
        tabBar.layer.borderWidth = 0.5
        tabBar.layer.borderColor = UIColor.ypGray.cgColor
    }
}
