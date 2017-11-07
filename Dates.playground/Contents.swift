//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"


let RFC3339DateFormatter = DateFormatter()
RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
let date1 = RFC3339DateFormatter.date(from: "2009-07-08T10:55:32Z")

let usDateFormatter = DateFormatter()
usDateFormatter.locale = Locale(identifier: "en_US_POSIX")
usDateFormatter.dateFormat = "MM/dd/yyyy"
let date2 = usDateFormatter.date(from: "10/23/2017")
