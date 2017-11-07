//
//  Helpers.swift
//  FrqAnalysis
//
//  Created by Ilya Mikhaltsou on 11/6/17.
//

import Foundation

internal func logistic(_ x: Double) -> Double {
    return 1.0 / (1.0 + exp(-x))
}

internal func logistic_derivative(_ x: Double) -> Double {
    return logistic(x) * (1.0 - logistic(x))
}

internal func random() -> Double {
    return Double(arc4random()) / Double(UInt32.max)
}

internal func randomArray(count: Int, randomF: () -> Double = random) -> [Double] {
    let result: [Double] =
        withoutActuallyEscaping(randomF) { r in
            let seq: UnfoldFirstSequence<Double> = sequence(first: r()) { _ in
                r()
            }
            return Array(seq.prefix(count))
    }
    return result
}

extension Sequence {
    internal func all(condition: (Element) throws -> Bool) rethrows -> Bool {
        for value in self {
            guard try condition(value) else { return false }
        }
        return true
    }
}
