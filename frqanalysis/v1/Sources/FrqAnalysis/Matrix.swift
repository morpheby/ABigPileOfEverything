//
//  Matrix.swift
//  FrqAnalysis
//
//  Created by Ilya Mikhaltsou on 11/6/17.
//

import Foundation

public struct FixedSizeMatrix<Element> {

    public let rowCount: Int
    public let columnCount: Int

    private var data: [[Element]]
    public typealias Index = Int

    public init(rowCount: Int, columnCount: Int, defaultValue: Element) {
        self.rowCount = rowCount
        self.columnCount = columnCount
        data = Array(
            repeating: Array(
                repeating: defaultValue,
                count: columnCount),
            count: rowCount
        )
    }

    public init(rowMajorData: [[Element]]) {
        self.rowCount = rowMajorData.count

        let columnCount = rowMajorData.first?.count ?? 0
        self.columnCount = columnCount

        precondition(rowMajorData.all { v in v.count == columnCount }, "Unaligned data")

        data = rowMajorData
    }

    public func allDataRowMajor() -> [[Element]] {
        return data
    }

    public subscript(row row: Index, column column: Index) -> Element {
        get {
            precondition(row < rowCount, "Row \(row) out of bounds of matrix with row size \(rowCount)")
            precondition(column < columnCount, "Column \(column) out of bounds of matrix with column size \(columnCount)")
            return data[row][column]
        }
        set {
            precondition(row < rowCount, "Row \(row) out of bounds of matrix with row size \(rowCount)")
            precondition(column < columnCount, "Column \(column) out of bounds of matrix with column size \(columnCount)")
            data[row][column] = newValue
        }
    }

    public subscript(_ x: Index, _ y: Index) -> Element {
        get {
            return self[row: y, column: x]
        }
        set {
            self[row: y, column: x] = newValue
        }
    }

    public subscript(row row: Index) -> [Element] {
        get {
            precondition(row < rowCount, "Row \(row) out of bounds of matrix with row size \(rowCount)")
            return data[row]
        }
        set {
            precondition(row < rowCount, "Row \(row) out of bounds of matrix with row size \(rowCount)")
            precondition(newValue.count == columnCount, "New value for row \(row) should be of size \(columnCount), is \(newValue.count)")
            data[row] = newValue
        }
    }

    public subscript(column column: Index) -> [Element] {
        get {
            precondition(column < columnCount, "Column \(column) out of bounds of matrix with column size \(columnCount)")
            return Array(data.map { row in row[column] })
        }
        set {
            precondition(column < columnCount, "Column \(column) out of bounds of matrix with column size \(columnCount)")
            precondition(newValue.count == rowCount, "New value for column \(column) should be of size \(rowCount), is \(newValue.count)")
            for (row, value) in newValue.enumerated() {
                data[row][column] = value
            }
        }
    }
}
