import UIKit

var str = "Hello, playground"

extension Date {
    func difference(to endDate: Date, in dateComponent: Calendar.Component) -> Int? {
        let calendar: Calendar = Calendar.current
        let date1 = calendar.startOfDay(for: self)
        let date2 = calendar.startOfDay(for: endDate)

        let flags: Set<Calendar.Component> = [dateComponent]
        let components = calendar.dateComponents(flags, from: date1, to: date2)
        return components.value(for: dateComponent)
    }
}

let date1 = DateComponents(calendar: Calendar.current, timeZone: nil, era: 1, year: 2019, month: 10, day: 03).date!
let date2 = DateComponents(calendar: Calendar.current, timeZone: nil, era: 1, year: 2019, month: 9, day: 01).date!

date2.difference(to: date1, in: .month)
date2.difference(to: date1, in: .day)

