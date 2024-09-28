import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackers() throws {
        // Given: clean Core Data and add two trackers
        let store = TrackerStore()
        
        do {
            try store.deleteAll()
        } catch {
            XCTFail("Failed to clear Core Data: \(error.localizedDescription)")
            return
        }
        
        let category = TrackerCategory(name: "Test", trackers: [])
        
        let days: Set<Weekday> = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
        let regularTracker = Tracker(id: UUID(), name: "Regular", color: .red, emoji: "🌺", days: days)
        store.addTracker(regularTracker, to: category)
        
        let irregularTracker = Tracker(id: UUID(), name: "Irregular", color: .blue, emoji: "🙂", days: nil)
        store.addTracker(irregularTracker, to: category)
        
        // When: Trackers view is initialized and date is set to 01.09.2024
        let tabBarVC = TabBarController()
        tabBarVC.loadViewIfNeeded()
        
        guard let navController = tabBarVC.viewControllers?.first as? UINavigationController,
              let trackersVC = navController.viewControllers.first as? TrackersViewController else {
            XCTFail("Unexpected Tab Bar configuration")
            return
        }
        
        let dateComponents = DateComponents(year: 2024, month: 9, day: 1)
        guard let date = Calendar.current.date(from: dateComponents) else {
            XCTFail("Failed to create date for 01.09.2024")
            return
        }
        
        trackersVC.setCurrentDate(to: date)
        
        // Then: test snapshots
        assertSnapshot(of: tabBarVC, as: .image(traits: .init(userInterfaceStyle: .light)))
        assertSnapshot(of: tabBarVC, as: .image(traits: .init(userInterfaceStyle: .dark)))
    }
}
