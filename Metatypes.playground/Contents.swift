//: Playground - noun: a place where people can play

import Cocoa

var str = "Hello, playground"

protocol A {
    init()
}

class B: A {
    required init() { }
}

struct C: A { }

var one: String.Type = String.self
//var two: A.Type = A.self
var three: A.Type = B.self
var four: A.Type = C.self
var five: A.Protocol = A.self
//var six: A.Protocol = B.self
//var seven: A.Protocol = C.self


func f1<T>(_ t: T.Type) where T: A {
    let o = t.init()
    print("Type: \(t), Generic type: \(T.self), object: \(o), object type: \(type(of: o))")
}

func f4(_ t: A.Protocol) {
    print("Type: \(t)")
}

func f2(_ t: A.Type) {
//    f1(t)
//    f1(three)
    f1(B.self)
    //? f1(A.self)
//    f4(t)
//    f4(three)
//    f4(B.self)
    f4(A.self)
}

func f3(_ t: A.Protocol) {
    //? f1(t)
//    f1(three)
    f1(B.self)
    //? f1(A.self)
    f4(t)
//    f4(three)
//    f4(B.self)
    f4(A.self)
}

f2(B.self)
f3(A.self)
