import Foundation

public func fastpow(_ p0: Int, _ q0: Int) -> Int {
    precondition(q0 >= 0, "Invalid q value: \(q0)")
    var p = p0
    var q = q0
    var result = 1
    while q != 0 {
        if q % 2 == 0 {
            p *= p
            q /= 2
        } else {
            result *= p
            q -= 1
        }
    }
    return result
}
