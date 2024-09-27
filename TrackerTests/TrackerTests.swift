import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackers() throws {
        let viewController = TabBarController()
        viewController.loadViewIfNeeded()
                
        assertSnapshot(of: viewController, as: .image())
    }
}
