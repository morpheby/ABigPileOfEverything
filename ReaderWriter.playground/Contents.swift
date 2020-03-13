import Cocoa

class ExecutionQueueHolder {
    var queue: DispatchQueue

    init(identifier: String) {
        queue = DispatchQueue(label: identifier, attributes: .concurrent)
    }
}

class ExecutionInternalStorage<T> {
    var storage: T

    init(storage: T) {
        self.storage = storage
    }
}


// While we are in Swift 4.2 world (and not in Swift 5.0), full memory
// exclusivity isn't completely enforced yet. Thus, proper CoW is only
// possible with pinning, which is internal to Swift implementation.
// And because we can't do this, there exists no implementation of
// Writer that will properly ensure `storage` is actually unique.
// So please, just make sure you don't copy this :)

public struct ExecutionQueue<T> {
    var storage: ExecutionInternalStorage<T>
    var queue = ExecutionQueueHolder(identifier: "abc")

    public init(value: T) {
        storage = ExecutionInternalStorage(storage: value)
    }

    public func read<U>(_ closure: (T) throws -> U) rethrows -> U {
        return try queue.queue.sync {
            return try closure(storage.storage)
        }
    }

    public mutating func modify<U>(_ closure: (inout T) throws -> U) rethrows -> U {
        return try queue.queue.sync(flags: .barrier) {
            return try closure(&storage.storage)
        }
    }

    public mutating func modifyAsync(_ closure: @escaping (inout T) -> Void) -> Void {
        queue.queue.async(flags: .barrier) { [storage] in
            closure(&storage.storage)
        }
    }
}

class Dummy {
    var st = ExecutionQueue<Int>(value: 0)
}

let d = Dummy()

let queue1 = DispatchQueue(label: "bg1")
let queue2 = DispatchQueue(label: "bg2")

queue1.async {
    print("1: Ready")
    d.st.read { (value) in
        print("1: \(value)")
        sleep(2)
    }
}

sleep(1)

queue2.async {
    print("2: Ready")
    sleep(2)
    d.st.modify { (value) in
        value = value + 1
        print("2: \(value)")
        sleep(4)
    }
}

queue1.sync {
    print("3: Ready")
    sleep(3)
    d.st.read { (value) in
        print("3: \(value)")
        sleep(5)
    }
}


// Reset
print("4: Reset")
d.st.storage.storage = 0

for _ in 0..<500 {
    queue1.async {
        d.st.modify({ (value) in
            value += 1
            value
        })
    }

    queue2.async {
        d.st.modify({ (value) in
            value += 1
            value
        })
    }
}
queue1.sync {}
queue2.sync {}
print("5: \(d.st.read({ $0 })) == 1000") // No race



