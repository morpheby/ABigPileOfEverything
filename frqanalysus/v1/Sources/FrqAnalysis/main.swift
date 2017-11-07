//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

func logistic(_ x: Double) -> Double {
    return 1.0 / (1.0 + exp(-x))
}

func logistic_derivative(_ x: Double) -> Double {
    return logistic(x) * (1.0 - logistic(x))
}

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

func random() -> Double {
    return Double(arc4random()) / Double(UInt32.max)
}

func randomArray(count: Int, randomF: () -> Double = random) -> [Double] {
    let result: [Double] =
        withoutActuallyEscaping(randomF) { r in
            let seq: UnfoldFirstSequence<Double> = sequence(first: r()) { _ in
                r()
            }
            return Array(seq.prefix(count))
        }
    return result
}

func groupingError(of group: [Double], to value: Double) -> Double {
    return group.reduce(0.0, +) - value
}

func performGroupingFinal<U,V>(in groupingProbabilities: [U: [V: Double]]) -> [V: [U]] {
    var choice: [V: [U]] = [:]
    for (dataKey, possibilities) in groupingProbabilities {
        if let p = possibilities.max(by: { leftPair, rightPair in
            leftPair.value < rightPair.value
        }) {
            choice[p.key, default: []].append(dataKey)
        }
    }
    return choice
}

func performGrouping<U,V>(in groupingProbabilities: [U: [V: Double]]) -> [V: [(U, Double)]] {
    var choice: [V: [(U, Double)]] = [:]
    for (dataKey, possibilities) in groupingProbabilities {
        for (targetKey, p) in possibilities {
            choice[targetKey, default: []].append((dataKey, p))
        }
    }
    return choice
}

func randomGrouping<U,V>(of data: [U: Double], to target: [V: Double]) -> [V: [U]] {
    var groupingQs =
        Dictionary(uniqueKeysWithValues:
            data.keys.map { k in
                return (k, Dictionary(uniqueKeysWithValues:
                    zip(target.keys,
                        randomArray(count: target.count)
                    )
                ))
            }
    )

    let errorThreshold = 0.05
    var stepCoeff = 0.05
    let iterationLimit = 100
    var totalError = Double.infinity
    var lastTotalError = totalError
    var iteration = 0

    var bestError = totalError
    var bestGrouping = groupingQs

    while totalError > errorThreshold && iteration < iterationLimit {
        totalError = 0.0

        var newGrouping = groupingQs
        let candidate = performGrouping(in: groupingQs)
        let candidateFinal = performGroupingFinal(in: groupingQs)
        for (targetKey, probs) in candidate {
//            let error = probs.map { dataKey, p in p * logistic(data[dataKey]!) } .reduce(0.0, +) - target[targetKey]!
            let error = candidateFinal[targetKey, default: []].map { key in data[key]! } .reduce(0.0, +) - target[targetKey]!
            totalError += abs(error)
            let sign = error.sign == .plus ? -1.0 : 1.0
            let probsDic = Dictionary(uniqueKeysWithValues: probs)

            newGrouping = Dictionary(uniqueKeysWithValues: newGrouping.map { dataKey, poss in
                var possibilities = poss
                let p = possibilities[targetKey]!
                let diff = sign * stepCoeff * data[dataKey]! * logistic_derivative(probsDic[dataKey]!)
                possibilities[targetKey] = p + diff
                return (dataKey, possibilities)
            })
        }

        if lastTotalError < totalError {
            stepCoeff *= 0.9
        } else {
            stepCoeff *= 1.1
        }

        if totalError < bestError {
            bestError = totalError
            bestGrouping = groupingQs
        }

        groupingQs = newGrouping

        lastTotalError = totalError
        iteration += 1
    }

    return performGroupingFinal(in: bestGrouping)
}

let final = randomGrouping(of: frq2dict, to: frq1dict)
print(final)
print(Dictionary(uniqueKeysWithValues: final.map { targetKey, dataKeys in (frq1dict[targetKey]!, dataKeys.map { key in frq2dict[key]! }) }))
print(Dictionary(uniqueKeysWithValues: final.map { targetKey, dataKeys in (frq1dict[targetKey]!, dataKeys.map { key in frq2dict[key]! } .reduce(0.0,+)) }))
