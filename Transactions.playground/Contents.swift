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

public struct ExecutionQueue<T> {
    var storage: ExecutionInternalStorage<T>
    var queue = ExecutionQueueHolder(identifier: "abc")

    public init(value: T) {
        storage = ExecutionInternalStorage(storage: value)
    }


    public var reader: Reader<T> {
        return Reader<T>(storage: storage, queue: queue)
    }

    public var writer: Writer<T> {
        mutating get {
            return Writer<T>(storage: storage, queue: queue)
        }
        set { }
    }
}

public struct Reader<T>: ReaderType {

    typealias Value = T

    var storage: ExecutionInternalStorage<T>
    var queue: ExecutionQueueHolder

    init(storage: ExecutionInternalStorage<T>, queue: ExecutionQueueHolder) {
        self.storage = storage
        self.queue = queue
    }

    public func execute<U>(_ closure: (T) throws -> U) rethrows -> U {
        return try queue.queue.sync {
            return try closure(storage.storage)
        }
    }
}

public struct Writer<T>: WriterType {

    typealias Value = T

    var storage: ExecutionInternalStorage<T>
    var queue: ExecutionQueueHolder

    init(storage: ExecutionInternalStorage<T>, queue: ExecutionQueueHolder) {
        self.storage = storage
        self.queue = queue
    }

    public mutating func execute<U>(_ closure: (inout T) throws -> U) rethrows -> U {
        return try queue.queue.sync(flags: .barrier) {
            return try closure(&storage.storage)
        }
    }

    public mutating func executeAsync(_ closure: @escaping (inout T) -> Void) -> Void {
        queue.queue.async(flags: .barrier) { [storage] in
            closure(&storage.storage)
        }
    }
}

protocol ReaderType {
    associatedtype Value

    func execute<U>(_ closure: (Value) throws -> U) rethrows -> U
}

protocol WriterType {
    associatedtype Value

    mutating func execute<U>(_ closure: (inout Value) throws -> U) rethrows -> U
}

public struct TransactedReader<T> {
    typealias Value = T

    var actual: Reader<T>

    public var value: T {
        get {
            return actual.storage.storage
        }
    }
}

public struct TransactedWriter<T> {
    typealias Value = T

    var actual: Writer<T>

    public var value: T {
        get {
            return actual.storage.storage
        }
        nonmutating set {
            actual.storage.storage = newValue
        }
    }
}

public func executeTransaction<T, U>(coordinating: (_ coordinator: inout TransactionCoordinator) -> T,
                           _ closure: (T) throws -> U) rethrows -> U {
    return try TransactionCoordinator.transactionQueue.sync {
        var coordinator = TransactionCoordinator()
        defer {
            coordinator.terminate()
        }
        return try closure(coordinating(&coordinator))
    }
}

public struct TransactionCoordinator {
    static let transactionQueue = DispatchQueue(label: "transaction")

    var transactionCount: Int = 0
    let exitSemaphore = DispatchSemaphore(value: 0)

    func terminate() {
        for _ in 0..<transactionCount {
            exitSemaphore.signal()
        }
    }

    public mutating func transact<T>(_ reader: Reader<T>) -> TransactedReader<T> {
        let semaphore = DispatchSemaphore(value: 0)
        transactionCount += 1
        reader.queue.queue.async { [exitSemaphore] in
            semaphore.signal()
            exitSemaphore.wait()
        }
        semaphore.wait()
        return TransactedReader(actual: reader)
    }

    public mutating func transact<T>(_ writer: Writer<T>) -> TransactedWriter<T> {
        let semaphore = DispatchSemaphore(value: 0)
        transactionCount += 1
        writer.queue.queue.async(flags: .barrier) { [exitSemaphore] in
            semaphore.signal()
            exitSemaphore.wait()
        }
        semaphore.wait()
        return TransactedWriter(actual: writer)
    }
}

class Dummy {
    var st = ExecutionQueue<Int>(value: 0)
}

let d1 = Dummy()
let d2 = Dummy()
d2.st.storage.storage = 10

let queue1 = DispatchQueue(label: "bg1")
let queue2 = DispatchQueue(label: "bg2")
let queue3 = DispatchQueue(label: "bg3")
let queue4 = DispatchQueue(label: "bg4")
let queue5 = DispatchQueue(label: "bg5")

queue1.async {
    print("1: Ready; T = 0")
    d1.st.reader.execute { (value) in
        print("1: \(value) == 0; T = 0.1")
        sleep(5)
        print("1: Finished; T = 5")
    }
}

queue2.async {
    sleep(2)
    print("2: Ready; T = 2")
    d1.st.writer.execute { (value) in
        value = value + 1
        print("2: \(value) == 1; T = (2..., 5..., 6...) 6.1")
        sleep(5)
        print("2: Finished; T = 11")
    }
}

queue3.async {
    sleep(1)
    print("3: Ready; T = 1")
    d1.st.reader.execute { (value) in
        print("3: \(value) == 0; T = 1.1")
        sleep(5)
        print("3: Finished; T = 6")
    }
}

queue4.sync {
    sleep(7)
    print("4: Ready; T = 7")
    d1.st.reader.execute { (value) in
        print("4: \(value) == 1; T = 11.1")
        sleep(5)
        print("4: Finished; T = 16")
    }
}

// T = 16

queue1.async {
    sleep(1)
    print("5: Ready; T = 17")
    executeTransaction(coordinating: { coordinator in
        (coordinator.transact(d1.st.writer), coordinator.transact(d2.st.reader))
    }, { (r1, r2) in
        r1.value += r2.value
        print("5: \(r1.value) == 11, \(r2.value) == 10; T = 17.1")
        sleep(3)
        print("5: Finished; T = 20")
    })
}

queue2.async {
    sleep(2)
    print("6: Ready; T = 18")
    d1.st.reader.execute { (value) in
        print("6: \(value) == 11; T = 20.1")
        sleep(2)
        print("6: Finished; T = 22")
    }
}

queue3.async {
    sleep(2)
    print("7: Ready; T = 18.1")
    d2.st.reader.execute { (value) in
        print("7: \(value) == 10; T = 18.2")
        sleep(6)
        print("7: Finished; T = 24")
    }
}

queue4.async {
    sleep(3)
    print("8: Ready; T = 19")
    d1.st.reader.execute { (value) in
        print("8: \(value) == 11; T = 20.2")
        sleep(6)
        print("8: Finished; T = 26")
    }
}

queue5.sync {
    sleep(5)
    print("9: Ready; T = 21")
    executeTransaction(coordinating: { coordinator in
        (coordinator.transact(d2.st.writer), coordinator.transact(d1.st.reader))
    }, { (r2, r1) in
        r2.value += r1.value + 1
        print("9: \(r1.value) == 11, \(r2.value) == 22; T = (24...) 24.1")
        sleep(3)
        print("9: Finished; T = 27")
    })
}

// T = 27

print(d1.st.storage.storage)
print(d2.st.storage.storage)


// Reset
print("10: Reset")
d1.st.storage.storage = 0

for _ in 0..<500 {
    queue1.async {
        d1.st.writer.execute({ (value) in
            value += 1
            value
        })
    }

    queue2.async {
        d1.st.writer.execute({ (value) in
            value += 1
            value
        })
    }
}
queue1.sync {}
queue2.sync {}
print("11: \(d1.st.reader.execute({ $0 })) == 1000") // No race
