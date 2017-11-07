//: Playground - noun: a place where people can play

import Cocoa

protocol TP: class {
    var test: [String: String] { get set }
}

class Test {
    var test: [String: String] = [:]

    init() {
    }
}

extension Test: TP {
}

let t = Test()

t.test["abc"] = "aaa"

t.test

let p = t as TP

p.test["cba"] = "ccc"

p.test

