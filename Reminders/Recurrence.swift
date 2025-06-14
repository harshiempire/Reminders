import Foundation

/// Frequency options for repeating reminders.
enum Recurrence: String, CaseIterable, Identifiable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"

    var id: String { rawValue }

    /// Recurrence rule string used for UNCalendarNotificationTrigger
    var rrule: String? {
        switch self {
        case .none: return nil
        case .daily: return "FREQ=DAILY;INTERVAL=1"
        case .weekly: return "FREQ=WEEKLY;INTERVAL=1"
        }
    }

    /// Convert a stored recurrence rule string back to a Recurrence value.
    static func from(rule: String?) -> Recurrence {
        switch rule {
        case "FREQ=DAILY;INTERVAL=1": return .daily
        case "FREQ=WEEKLY;INTERVAL=1": return .weekly
        default: return .none
        }
    }
}
