import Foundation

protocol StatisticsServiceProtocol {
    var numberOfCompleted: Int { get }
    func onTrackerCompletion()
    func onTrackerUnCompletion()
}

final class StatisticsService: StatisticsServiceProtocol {
    private let userDefaults = UserDefaults.standard
    
    private enum Keys: String {
        case numberOfCompleted
    }
    
    private(set) var numberOfCompleted: Int {
        get {
            userDefaults.integer(forKey: Keys.numberOfCompleted.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.numberOfCompleted.rawValue)
        }
    }
    
    func onTrackerCompletion() {
        numberOfCompleted += 1
    }
    
    func onTrackerUnCompletion() {
        guard numberOfCompleted > 0 else {return }
        numberOfCompleted -= 1
    }
}
