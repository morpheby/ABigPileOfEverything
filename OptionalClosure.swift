
class A {
  func test() {}
}

var f: (() -> Void)?

let x = A()

f = x.test

f = { [weak x] in x?.test() }
