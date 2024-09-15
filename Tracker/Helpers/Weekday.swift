import Foundation

enum Weekday: Int, CaseIterable {
    case sunday = 1, monday, tuesday, wednesday, thursday, friday, saturday
    
    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()
    
    var fullName: String {
        return Weekday.formatter.weekdaySymbols[self.rawValue - 1].capitalized
    }
    
    var shortName: String {
        return Weekday.formatter.shortWeekdaySymbols[self.rawValue - 1].capitalized
    }
    
    static func orderedWeekdays() -> [Weekday] {
        let firstWeekday = Calendar.current.firstWeekday
        return (0..<7).compactMap { index in
            let dayIndex = (index + firstWeekday - 1) % 7 + 1
            if let day = Weekday(rawValue: dayIndex) {
                return day
            }
            return nil
        }
    }
    
    init(date: Date) {
        let weekdayIndex = Calendar.current.component(.weekday, from: date)
        self = Weekday(rawValue: weekdayIndex) ?? .monday
    }
}
