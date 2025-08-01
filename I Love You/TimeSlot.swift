import Foundation

struct TimeSlot {
    let startHour: Int
    let startMinute: Int
    let endHour: Int
    let endMinute: Int
    
    var timeString: String {
        let startTime = formatTo12Hour(hour: startHour, minute: startMinute)
        let endTime = (endHour == 23 && endMinute == 59) ? "onwards"
                     : formatTo12Hour(hour: endHour, minute: endMinute)
        return "\(startTime) - \(endTime)"
    }
    
    private func formatTo12Hour(hour: Int, minute: Int) -> String {
        let period = hour >= 12 ? "PM" : "AM"
        let displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour)
        return String(format: "%d:%02d %@", displayHour, minute, period)
    }
    
    func isCurrentlyActive() -> Bool {
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        let startTimeInMinutes = startHour * 60 + startMinute
        let endTimeInMinutes = (endHour == 23 && endMinute == 59) ? 24 * 60
                              : endHour * 60 + endMinute
        
        return currentTimeInMinutes >= startTimeInMinutes && currentTimeInMinutes < endTimeInMinutes
    }
}

struct DaySchedule {
    let dayName: String
    let slots: [TimeSlot]
}

enum FreeTimeStatus {
    case noSchedule
    case dayOver
    case currentlyFree(TimeSlot, String)
    case nextSlotToday(TimeSlot, String)
    case nextSlotOtherDay(TimeSlot, String, Int)
}

class FreeTimeManager: ObservableObject {
    static let shared = FreeTimeManager()
    
    private let weeklySchedule: [Int: DaySchedule] = [
        2: DaySchedule(dayName: "Monday", slots: [
            TimeSlot(startHour: 8, startMinute: 0, endHour: 10, endMinute: 30),
            TimeSlot(startHour: 12, startMinute: 10, endHour: 13, endMinute: 50),
            TimeSlot(startHour: 14, startMinute: 40, endHour: 15, endMinute: 30),
            TimeSlot(startHour: 17, startMinute: 10, endHour: 23, endMinute: 59)
        ]),
        3: DaySchedule(dayName: "Tuesday", slots: [
            TimeSlot(startHour: 13, startMinute: 0, endHour: 13, endMinute: 50)
        ]),
        4: DaySchedule(dayName: "Wednesday", slots: [
            TimeSlot(startHour: 8, startMinute: 0, endHour: 8, endMinute: 50),
            TimeSlot(startHour: 13, startMinute: 0, endHour: 13, endMinute: 50),
            TimeSlot(startHour: 16, startMinute: 20, endHour: 23, endMinute: 59)
        ]),
        5: DaySchedule(dayName: "Thursday", slots: [
            TimeSlot(startHour: 8, startMinute: 0, endHour: 8, endMinute: 50),
            TimeSlot(startHour: 13, startMinute: 0, endHour: 13, endMinute: 50),
            TimeSlot(startHour: 17, startMinute: 10, endHour: 23, endMinute: 59)
        ]),
        6: DaySchedule(dayName: "Friday", slots: [
            TimeSlot(startHour: 13, startMinute: 0, endHour: 13, endMinute: 50),
            TimeSlot(startHour: 17, startMinute: 10, endHour: 23, endMinute: 59)
        ]),
        7: DaySchedule(dayName: "Saturday", slots: [
            TimeSlot(startHour: 0, startMinute: 0, endHour: 23, endMinute: 59)
        ]),
        1: DaySchedule(dayName: "Sunday", slots: [
            TimeSlot(startHour: 0, startMinute: 0, endHour: 23, endMinute: 59)
        ])
    ]
    
    func getCurrentFreeTimeStatus() -> FreeTimeStatus {
        let calendar = Calendar.current
        let now = Date()
        let currentHour = calendar.component(.hour, from: now)
        let currentMinute = calendar.component(.minute, from: now)
        let dayOfWeek = calendar.component(.weekday, from: now)
        
        guard let todaySchedule = weeklySchedule[dayOfWeek] else {
            return .noSchedule
        }
        
        // Check if currently in a free slot
        if let currentSlot = todaySchedule.slots.first(where: { $0.isCurrentlyActive() }) {
            return (currentHour >= 17 && currentMinute >= 10) ? .dayOver : .currentlyFree(currentSlot, todaySchedule.dayName)
        }
        
        // Find next free slot today
        let currentTimeInMinutes = currentHour * 60 + currentMinute
        if let nextSlotToday = todaySchedule.slots.first(where: { slot in
            let slotStartInMinutes = slot.startHour * 60 + slot.startMinute
            return slotStartInMinutes > currentTimeInMinutes
        }) {
            return .nextSlotToday(nextSlotToday, todaySchedule.dayName)
        }
        
        // Find next day with free slots
        var nextDay = (dayOfWeek % 7) + 1
        var daysAhead = 1
        
        while daysAhead <= 7 {
            if let schedule = weeklySchedule[nextDay], !schedule.slots.isEmpty {
                return .nextSlotOtherDay(schedule.slots.first!, schedule.dayName, daysAhead)
            }
            nextDay = (nextDay % 7) + 1
            if nextDay == 0 { nextDay = 7 }
            daysAhead += 1
        }
        
        return .noSchedule
    }
    
    func getTodaySchedule() -> DaySchedule? {
        let calendar = Calendar.current
        let dayOfWeek = calendar.component(.weekday, from: Date())
        return weeklySchedule[dayOfWeek]
    }
}
