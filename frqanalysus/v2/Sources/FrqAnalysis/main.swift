//: Playground - noun: a place where people can play

import Cocoa


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

extension Grouping {
    func make() -> [V: [U]] {
        let branching = target.keys

//        var open: [NodeRef<U,V>] = [NodeRef(state: [:], left: Array(data.keys), in: self)]
        var open: SortedArray<NodeRef<U,V>> = SortedArray([NodeRef(state: [:], left: Array(data.keys), in: self)], sortedBy: self.orderOpen)
        var closed: SortedArray<NodeRef<U,V>> = SortedArray([], sortedBy: self.orderClosed)

        while var node = open.popLast() {
            if let next = node.left.popLast() {
                let new = branching.map { targetKey -> NodeRef<U,V> in
                    let newNode = NodeRef(from: node, adding: (targetKey, next))
                    return newNode
                }
                open.append(contentsOf: new)
//                open.sort(by: self.orderOpen)
            } else {
                closed.append(node)
                if closed.count > closedLimit {
                    break
                }
            }

            if open.count > 200 {
                open.removeSubrange(..<(open.count-200))
            }

            open.count
        }

        return closed.popLast()!.state
    }
}


let final = Grouping(of: frq2dict, to: frq1dict).make()
print(final)
print(Dictionary(uniqueKeysWithValues: final.map { targetKey, dataKeys in (frq1dict[targetKey]!, dataKeys.map { key in frq2dict[key]! }) }))
print(Dictionary(uniqueKeysWithValues: final.map { targetKey, dataKeys in (frq1dict[targetKey]!, dataKeys.map { key in frq2dict[key]! } .reduce(0.0,+)) }))
