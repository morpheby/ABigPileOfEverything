//: Playground - noun: a place where people can play

import Cocoa

public protocol TypeChecking {
    func accepts(type: Any.Type) -> Bool
}

public struct TypeChecker<T>: TypeChecking {
    public init(_: T.Type) { }
    public func accepts(type: Any.Type) -> Bool {
        return type as? T.Type != nil
    }
}

class A { init() {} }
class B: A { }
class C: B { }
class D: B { }

let checkA: TypeChecking = TypeChecker(A.self)
let checkB: TypeChecking = TypeChecker(B.self)
let checkC: TypeChecking = TypeChecker(C.self)
let checkD: TypeChecking = TypeChecker(D.self)

let objectA: A = A()
let objectB: A = B()
let objectC: A = C()
let objectD: A = D()

checkA.accepts(type: type(of: objectA))
checkA.accepts(type: type(of: objectB))
checkA.accepts(type: type(of: objectC))
checkA.accepts(type: type(of: objectD))

checkB.accepts(type: type(of: objectA))
checkB.accepts(type: type(of: objectB))
checkB.accepts(type: type(of: objectC))
checkB.accepts(type: type(of: objectD))

checkC.accepts(type: type(of: objectA))
checkC.accepts(type: type(of: objectB))
checkC.accepts(type: type(of: objectC))
checkC.accepts(type: type(of: objectD))

checkD.accepts(type: type(of: objectA))
checkD.accepts(type: type(of: objectB))
checkD.accepts(type: type(of: objectC))
checkD.accepts(type: type(of: objectD))


