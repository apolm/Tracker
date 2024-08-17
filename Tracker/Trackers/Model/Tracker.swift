import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let days: Set<Weekday>?
    
    init(name: String, color: UIColor, emoji: String, days: Set<Weekday>? = nil) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.emoji = emoji
        self.days = days
    }
}
