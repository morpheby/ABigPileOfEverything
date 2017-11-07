//
//  Grouping.swift
//  FrqAnalysis
//
//  Created by Ilya Mikhaltsou on 11/6/17.
//

import Foundation

public class Grouping<DataIndex,TargetIndex> where DataIndex: Hashable, TargetIndex: Hashable {
    private let data: [DataIndex: Double]
    private let target: [TargetIndex: Double]

    public var errorThreshold = 0.05
    public var stepCoeff = 0.05
    public var iterationLimit = 100

    private struct GroupingValue {
        var p: Double
    }

    public init(of data: [DataIndex: Double], to target: [TargetIndex: Double]) {
        self.data = data
        self.target = target
    }

    private func performGroupingFinal(in groupingProbabilities: HashMatrix<DataIndex, TargetIndex, GroupingValue>) -> [TargetIndex: [DataIndex]] {
        var choice: [TargetIndex: [DataIndex]] = [:]
        for dataKey in groupingProbabilities.rowIndices {
            let possibilities = groupingProbabilities[row: dataKey]
            if let p = possibilities.max(by: { leftPair, rightPair in
                leftPair.value.p < rightPair.value.p
            }) {
                choice[p.key, default: []].append(dataKey)
            }
        }
        return choice
    }

    func make() -> [TargetIndex: [DataIndex]] {

        var groupingQs = HashMatrix(rowIndices: Array(data.keys), columnIndices: Array(target.keys),
                                    supplyingValue: { row, column in
            GroupingValue(p: random())
        })

        var totalError = Double.infinity
        var lastTotalError = totalError
        var iteration = 0

        var bestError = totalError
        var bestGrouping = groupingQs

        while totalError > errorThreshold && iteration < iterationLimit {
            totalError = 0.0

            var newGrouping = groupingQs
            let candidateFinal = performGroupingFinal(in: groupingQs)
            for targetKey in target.keys {
                let target = self.target[targetKey]!
                let error = (candidateFinal[targetKey]?
                    .map { key in data[key]! } .reduce(0.0, +) ?? 0) - target
                totalError += abs(error)
                let sign = error.sign == .plus ? -1.0 : 1.0

                for dataKey in data.keys {
                    let data = self.data[dataKey]!
                    let grp = groupingQs[row: dataKey, column: targetKey]
                    let diff = sign * stepCoeff * data * logistic_derivative(grp.p)
                    newGrouping[row: dataKey, column: targetKey].p += diff
                }
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

}

