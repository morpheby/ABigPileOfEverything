//
//  HashMatrix.swift
//  FrqAnalysis
//
//  Created by Ilya Mikhaltsou on 11/6/17.
//

import Foundation

public struct HashMatrix<RowIndex, ColumnIndex, Element> where RowIndex: Hashable, ColumnIndex: Hashable {

    private struct HalfBiMap<IndexLeft> where IndexLeft: Hashable {
        typealias IndexRight = Int
        private var left: [IndexLeft: IndexRight] = [:]
        private var right: [IndexLeft] = []

        init() { }

        init(leftIndices: [IndexLeft]) {
            self.right = leftIndices
            self.left = Dictionary(uniqueKeysWithValues: zip(leftIndices, Array(0..<leftIndices.count)))
        }

        mutating func updatingRightIndex(for leftIndex: IndexLeft) -> IndexRight {
            if let rightIndex = left[leftIndex] {
                return rightIndex
            } else {
                let rightIndex = right.count
                right.append(leftIndex)
                left[leftIndex] = rightIndex
                return rightIndex
            }
        }

        func rightIndex(for leftIndex: IndexLeft) -> IndexRight {
            guard let rightIndex = left[leftIndex] else { preconditionFailure("Unknown left index") }
            return rightIndex
        }

        func leftIndex(for rightIndex: IndexRight) -> IndexLeft {
            precondition(rightIndex < right.count, "Unknown right index")

            return right[rightIndex]
        }

        func leftIndices() -> [IndexLeft] {
            return right
        }
    }

    private var dataMatrix: FixedSizeMatrix<Element>
    private typealias MatrixIndex = FixedSizeMatrix<Element>.Index
    private var rowMap: HalfBiMap<RowIndex>
    private var columnMap: HalfBiMap<ColumnIndex>

    public var rowIndices: [RowIndex] {
        return rowMap.leftIndices()
    }

    public var columnIndices: [ColumnIndex] {
        return columnMap.leftIndices()
    }

    public init(rowIndices: [RowIndex], columnIndices: [ColumnIndex], value: Element) {
        dataMatrix = FixedSizeMatrix(rowCount: rowIndices.count, columnCount: columnIndices.count, defaultValue: value)
        rowMap = HalfBiMap(leftIndices: rowIndices)
        columnMap = HalfBiMap(leftIndices: columnIndices)
    }

    public init(rowIndices: [RowIndex], columnIndices: [ColumnIndex], supplyingValue: (RowIndex, ColumnIndex) -> Element) {

        let allData = rowIndices.map { rowIndex in
            columnIndices.map { columnIndex in
                supplyingValue(rowIndex, columnIndex)
            }
        }

        dataMatrix = FixedSizeMatrix(rowMajorData: allData)
        rowMap = HalfBiMap(leftIndices: rowIndices)
        columnMap = HalfBiMap(leftIndices: columnIndices)
    }

    public init(_ dictionary: [RowIndex: [ColumnIndex: Element]]) {
        let rowIndices = Array(dictionary.keys)
        precondition(rowIndices.count != 0, "Empty dictionary initialization not supported")

        let columnIndices = Array(dictionary.first!.value.keys)
        precondition(columnIndices.count != 0, "Empty dictionary initialization not supported")

        var tempMatrix: FixedSizeMatrix<Element?> = FixedSizeMatrix(rowCount: rowIndices.count, columnCount: columnIndices.count, defaultValue: nil)

        rowMap = HalfBiMap(leftIndices: rowIndices)
        columnMap = HalfBiMap(leftIndices: columnIndices)

        for (rowIndex, column) in dictionary {
            for (columnIndex, value) in column {
                tempMatrix[row: rowMap.rightIndex(for: rowIndex), column: columnMap.rightIndex(for: columnIndex)] = value
            }
        }

        let allData: [[Element]] = tempMatrix.allDataRowMajor()
            .map { row in
                row.map { value in
                    guard let v = value else { preconditionFailure("Dictionary supplied is not complete") }
                    return v
                }
            }

        self.dataMatrix = FixedSizeMatrix(rowMajorData: allData)
    }

    public subscript(row row: RowIndex, column column: ColumnIndex) -> Element {
        get {
            return dataMatrix[row: rowMap.rightIndex(for: row), column: columnMap.rightIndex(for: column)]
        }
        set {
            dataMatrix[row: rowMap.rightIndex(for: row), column: columnMap.rightIndex(for: column)] = newValue
        }
    }

    public subscript(row row: RowIndex) -> [ColumnIndex: Element] {
        get {
            return Dictionary(uniqueKeysWithValues:
                zip(
                    columnMap.leftIndices(),
                    dataMatrix[row: rowMap.rightIndex(for: row)]
                )
            )
        }
        set {
            let rowSorted = newValue
                .map { columnIndex, value in return (columnMap.rightIndex(for: columnIndex), value) }
                .sorted { left, right in left.0 < right.0 }
                .map { _, value in value }
            dataMatrix[row: rowMap.rightIndex(for: row)] = rowSorted
        }
    }

    public subscript(column column: ColumnIndex) -> [RowIndex: Element] {
        get {
            return Dictionary(uniqueKeysWithValues:
                zip(
                    rowMap.leftIndices(),
                    dataMatrix[column: columnMap.rightIndex(for: column)]
                )
            )
        }
        set {
            let columnSorted = newValue
                .map { rowIndex, value in return (rowMap.rightIndex(for: rowIndex), value) }
                .sorted { left, right in left.0 < right.0 }
                .map { _, value in value }
            dataMatrix[column: columnMap.rightIndex(for: column)] = columnSorted
        }
    }

    mutating func updateEach(using closure: (RowIndex, ColumnIndex, Element) -> Element) {
        for rowIndex in 0..<dataMatrix.rowCount {
            for columnIndex in 0..<dataMatrix.columnCount {
                let value = dataMatrix[row: rowIndex, column: columnIndex]
                dataMatrix[row: rowIndex, column: columnIndex] =
                    closure(
                        rowMap.leftIndex(for: rowIndex),
                        columnMap.leftIndex(for: columnIndex),
                        value
                    )
            }
        }
    }
}
