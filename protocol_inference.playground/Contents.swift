//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

class C {
    let s: String
    required init(s: String) {
        self.s = s
    }
}

protocol D {
    var x: String { get set }
}

class V: C, D {
    var x: String = "123"
}

typealias X = C & D

protocol A {
    func f<T>(_ type: T.Type, s: String) -> T where T: C, T: D
//    func f<T: C>(_ type: T.Type, s: String) -> T
//    func f<T: X>(_ type: T.Type, s: String) -> T
//    func f(_ type: X.Type, s: String) -> X
}

class B {
    func f<T>(_ type: T.Type, s: String) -> T where T: C, T: D {
//    func f<T: C>(_ type: T.Type, s: String) -> T {
//    func f<T: X>(_ type: T.Type, s: String) -> T {
//    func f(_ type: X.Type, s: String) -> X {
        return type.init(s: s)
    }

//    func f(_ type: X.Type, s: String) -> X {
//        return type.init(s: s)
//    }
}

//let x = B().f(C.self, s: "Test")
//x.s

let t: X.Type = V.self

let x: C = B().f(t, s: "Test")
//x.s
//x.x
//
//type(of: V(s: "11") as X)
//type(of: X.self)
//type(of: V.self)
//type(of: V.self as X.Type)
//V.self
//X.self
//V.self as X.Type
//
//var a: X.Type = V.self
//debugPrint(a as Any)
//debugPrint(type(of: a) as Any)
//
//debugPrint(X.Type.self as Any)
//debugPrint(X.Protocol.self as Any)
//


