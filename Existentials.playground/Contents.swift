import Cocoa

protocol MyProtocol {
    init()

    func something() -> String

    static var meta: String { get }
}

extension MyProtocol {
    static var x: String { return "hiya" }
}

protocol MyOtherProtocol: MyProtocol {
    func another() -> Bool
}

class MyClass: MyProtocol {
    required init() {

    }

    static var meta: String { return "meta1" }

    func something() -> String {
        return "aabbcc"
    }
}

class MySecondClass: MyClass, MyOtherProtocol {

    func another() -> Bool {
        return true
    }
}

class MyThirdClass: MyProtocol {
    required init() {

    }

    class var meta: String { return "Meta2" }

    func something() -> String {
        return "ccaabb"
    }
}

class MyFourthClass: MyThirdClass {
    override class var meta: String { return "Meta3" }
}

func createObject(of type: MyProtocol.Type) -> MyProtocol {
    return type.init()
}


let x = createObject(of: MyClass.self)

x.something()

let b: MyOtherProtocol.Type = MySecondClass.self

let y = b.init()

y.another()


let c: MyProtocol.Protocol = MyProtocol.self




