import Cocoa


public protocol Visible {
    func getMyStuff() -> Bool
}

protocol Hidden {
    var something: Bool { get }
}

extension Visible where Self: Hidden {
    public func getMyStuff() -> Bool {
        return something
    }
}

public struct My: Visible, Hidden {

}
