import UIKit

struct TrackerCategory: Hashable {
    let id: UUID
    let name: String
    let trackers: [Tracker]
}
