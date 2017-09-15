
import Cocoa

func blockJump(n: Int) -> (Int, Int) {
    var x = n - 1
    var y = 1
    var z = 1

    while z != 0 {
        let t = (x-z) % (y+1) > 0 ? 1 + (x-z)/(y+1) : (x-1)/(y+1)
        let x1 = x - t
        z += y*t
        x = x1

        while z >= x {
            ++y
            z -= x
        }
        let m = (x,y,z,t)
    }

    return (x, y)
}



println(blockJump(65563*65563))


