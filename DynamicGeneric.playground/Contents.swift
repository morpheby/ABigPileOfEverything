//: Playground - noun: a place where people can play

import Cocoa

struct Test<T> {
    var x: T

    func test() {
        debugPrint(type(of: T.self))
        debugPrint(T.self)
    }

    init(x: T) {
        self.x = x
    }
}

var a: NSObject.Type

a = NSString.self

let v = a.init()

let x: Test<NSObject> = Test(x: v)
//let x: Test<a> = Test(x: v)

type(of: x)
x.x

x.test()
// It's definetely not dynamic...

func test1(t: inout Any) {
    guard var p = t as? Test<String> else { fatalError() }
    p.x = "Abc"

    t = p
}

var t1 = Test(x: "aaa")
t1.x

var t2 = t1 as Any

test1(t: &t2)
(t2 as! Test<String>).x
t1.x

t1.x = "bbb"
(t2 as! Test<String>).x

public struct VariableBinding<Matcher, Variable> {
    public var type: Any.Type {
        return liftedType(Variable.self)
    }

    private func liftedType<T>(_ type: ImplicitlyUnwrappedOptional<T>.Type) -> Any.Type {
        return T.self
    }

    private func liftedType<T>(_ type: T.Type) -> Any.Type {
        return T.self
    }
}

let uu: VariableBinding<Int, String> = VariableBinding()
uu.type

let vv: VariableBinding<Int, ImplicitlyUnwrappedOptional<Int>> = VariableBinding()
vv.type

