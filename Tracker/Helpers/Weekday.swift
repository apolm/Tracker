import Foundation

enum Weekday: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    var name: String {
        switch self {
        case .monday:
            return "Понедельник"
        case .tuesday:
            return "Вторник"
        case .wednesday:
            return "Среда"
        case .thursday:
            return "Четверг"
        case .friday:
            return "Пятница"
        case .saturday:
            return "Суббота"
        case .sunday:
            return "Воскресенье"
        }
    }
    
    init(date: Date) {
        self = Weekday(rawValue: Calendar.current.component(.weekday, from: date)) ?? .monday
    }
}

// Get the first weekday according to the current calendar settings
//let calendar = Calendar.current
//let firstWeekday = calendar.firstWeekday
