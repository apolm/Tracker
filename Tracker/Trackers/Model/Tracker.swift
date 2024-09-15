import UIKit

struct Tracker: Equatable, Hashable {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let days: Set<Weekday>?
    let isRegular: Bool
    
    init(id: UUID, name: String, color: UIColor, emoji: String, days: Set<Weekday>?) {
        self.id = id
        self.name = name
        self.color = color
        self.emoji = emoji
        self.days = days
        self.isRegular = days != nil
    }
    
    static func == (lhs: Tracker, rhs: Tracker) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
