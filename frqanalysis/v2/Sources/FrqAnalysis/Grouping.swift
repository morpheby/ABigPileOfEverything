import Foundation

public class Grouping<U,V> where U: Hashable, V: Hashable {

    public let data: [U: Double]
    public let target: [V: Double]

    public let negCoeff = 0.1
    public let closedLimit = 10

    public struct NodeRef<U,V> where U: Hashable, V: Hashable {
        public var state: [V: [U]]
        public var left: [U]
        public var sums: [V: Double]
        let context: Grouping<U,V>

        public init(state: [V: [U]], left: [U], in context: Grouping<U,V>) {
            self.state = state
            self.left = left
            self.context = context
            sums = Dictionary(uniqueKeysWithValues: self.state.map { targetKey, selected in (targetKey, selected.map { dataKey in context.data[dataKey]! } .reduce(0.0, +)) })
        }

        public init(from other: NodeRef<U,V>, adding value: (key: V, data: U)) {
            self.context = other.context
            self.state = other.state
            self.left = other.left
            self.state[value.key, default: []].append(value.data)
            self.sums = other.sums
            self.sums[value.key, default: 0.0] += context.data[value.data]!
        }
    }

    public init(of data: [U: Double], to target: [V: Double]) {
        self.data = data
        self.target = target
    }

    public func errorOpen(in sums: [V: Double]) -> Double {
        let error = sums.map { targetKey, sum in
            let diff = sum - self.target[targetKey]!
            return diff > 0 ? diff : -diff * negCoeff
        } .reduce(0.0, +)
        return error
    }

    public func errorClosed(in sums: [V: Double]) -> Double {
        let error = sums.map { targetKey, sum in
            abs(sum - self.target[targetKey]!)
            } .reduce(0.0, +)
        return error
    }

    public func orderOpen(left: NodeRef<U,V>, right: NodeRef<U,V>) -> Bool {
        return self.errorOpen(in: left.sums) > self.errorOpen(in: right.sums)
    }

    public func orderClosed(left: NodeRef<U,V>, right: NodeRef<U,V>) -> Bool {
        return self.errorClosed(in: left.sums) > self.errorClosed(in: right.sums)
    }
}

