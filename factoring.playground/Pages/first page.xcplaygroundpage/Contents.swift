//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

let hugeX = 512

fastpow(2, 5)

struct DimRep {
    var dimrep_points: [Int: DimRep]

    static let one = DimRep(dr: [:])

    private init(dr: [Int: DimRep]) {
        self.dimrep_points = dr
    }

    init?(_ arrays: [Int]...) {
        self.init(arrays)
    }

    init?(_ points: [[Int]]) {
        var groupedDict: [Int: [[Int]]] = [:]
        for a in points {
            let dropped = a.dropFirst()
            if dropped.count == 0 && groupedDict[a.first!] != nil && groupedDict[a.first!]!.count != 0 {
                return nil
            }
            if dropped.count != 0 && groupedDict[a.first!] != nil && groupedDict[a.first!]!.count == 0 {
                return nil
            }

            if groupedDict.index(forKey: a.first!) == nil {
                groupedDict[a.first!] = []
            }
            if dropped.count != 0 {
                groupedDict[a.first!]!.append(Array(a.dropFirst()))
            }
        }

        var points: [Int: DimRep] = [:]
        for (key, value) in groupedDict {
            if value.count != 0 {
                if let dr = DimRep(value) {
                    points[key] = dr
                } else {
                    return nil
                }
            } else {
                points[key] = DimRep.one
            }
        }
        self.init(dr: points)
    }

    subscript(_ range: Range<Int>) -> DimRep {
        get {
//            return DimRep(Array(
//                self.dimrep_points.lazy.map { a in Array(a[range]) }
//            ))
            return DimRep.one
        }
    }

    subscript(_ idx: Int) -> [Int] {
        get {
//            return Array(self.dimrep_points.lazy.map { a in a[idx] })
            return []
        }
    }
}

let testVal1 = DimRep([2,3,2]) // 2 to 3 to 2 == 2 to 9 == 512
let testVal2 = DimRep([2,2], [2,3]) // 2 to 3*2 == 2 to 6 == 64
let testVal3 = DimRep([2,2,2], [2,3]) // 2 to (2 to 2)*3 == 2 to 4*3 == 2 * 12 == 4096
let testVal4 = DimRep([2,2], [2,2,2]) // invalid
let testVal5 = DimRep([2,2,2,2,2], [2,2]) // invalid

extension DimRep: CustomDebugStringConvertible {
    var debugDescription: String {
        if self == DimRep.one {
            return "1"
        } else {
            return self.dimrep_points.debugDescription
        }
    }
}

extension DimRep {
    func toInt() -> Int {
        if self == DimRep.one {
            return 1
        } else {
            return self.dimrep_points.lazy.map { key, value in
                fastpow(key, value.toInt())
            } .reduce(1) { x, y in x*y }
        }
    }
}

testVal1?.toInt()
testVal2?.toInt()
testVal3?.toInt()
testVal4?.toInt()
testVal5?.toInt()

extension DimRep: Comparable {
    static func ==(lhs: DimRep, rhs: DimRep) -> Bool {
        return Set(lhs.dimrep_points.keys) == Set(rhs.dimrep_points.keys) &&
            zip(lhs.dimrep_points.values, rhs.dimrep_points.values).map { l, r in
                l == r
        } .reduce(true) { x, v in x && v }
    }

    static func <(lhs: DimRep, rhs: DimRep) -> Bool {
        return lhs.toInt() < rhs.toInt()
    }
}

var ct = 2

var primes: [Int] = [2]
var composites: [DimRep] = []

var lastvals: [Int] = [0]

func expval(num: DimRep, factors: DimRep) -> Double {
    return pow(Double(num.toInt()), 1.0/Double(factors.toInt()))
}

expval(num: DimRep([2,3,2])!, factors: DimRep([3,2])!)

for i in 1...10 {
    var dimrep: [Int] = []


}
