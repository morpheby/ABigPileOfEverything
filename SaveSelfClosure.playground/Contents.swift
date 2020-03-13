import Cocoa

class A {
    init() {
        print("Hello")
    }

    deinit {
        print("Bye")
    }

    var storedClosure: (() -> Void)?

    func method() {
        print("wooo")
    }

    func makeMeBad() {
        storedClosure = self.method
    }

    func imGood() {
        storedClosure = { [weak self] in self?.method() }
    }
}


var a: A? = nil

autoreleasepool {
    print("1")
    a = A()
    a = nil
}
print("Done")
print()

autoreleasepool {
    print("2")
    a = A()
    a?.makeMeBad()
    a = nil
}
print("Done")
print()

autoreleasepool {
    print("3")
    a = A()
    a?.imGood()
    a = nil
}
print("Done")
print()

