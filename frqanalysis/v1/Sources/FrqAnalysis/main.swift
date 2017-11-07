//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"


let frq1 = [
    0.3,
    0.25,
    0.2,
    0.15,
    0.1,
]
frq1.reduce(0.0, +) // 1.0
let frq1dict: [Int: Double] = Dictionary(uniqueKeysWithValues: Array(frq1.enumerated()).map({ o, v in
        (o,v)
}))

let frq2 = [
    0.205,
    0.1,

    0.06,
    0.05,
    0.09,
    0.05,

    0.11,
    0.09,

    0.11,
    0.05,

    0.085,
]
frq2.reduce(0.0, +) // 1.0
let frq2dict: [Int: Double] = Dictionary(uniqueKeysWithValues: Array(frq2.enumerated()).map({ o, v in
        (o,v)
}))


let grouping = Grouping(of: frq2dict, to: frq1dict)
grouping.iterationLimit = 200
let final = grouping.make()
print(final)
print(Dictionary(uniqueKeysWithValues: final.map { targetKey, dataKeys in (frq1dict[targetKey]!, dataKeys.map { key in frq2dict[key]! }) }))
print(Dictionary(uniqueKeysWithValues: final.map { targetKey, dataKeys in (frq1dict[targetKey]!, dataKeys.map { key in frq2dict[key]! } .reduce(0.0,+)) }))

