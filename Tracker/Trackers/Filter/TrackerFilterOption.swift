import Foundation

enum TrackerFilterOption: String, CaseIterable {
    case all = "All trackers"
    case today = "Trackers for current day"
    case completed = "Completed"
    case uncompleted = "Uncompleted"

    var localizedTitle: String {
        switch self {
        case .all:
            return NSLocalizedString("filter.all", comment: "All trackers")
        case .today:
            return NSLocalizedString("filter.today", comment: "Trackers for current day")
        case .completed:
            return NSLocalizedString("filter.completed", comment: "Completed")
        case .uncompleted:
            return NSLocalizedString("filter.uncompleted", comment: "Uncompleted")
        }
    }
}
