public func solution(inout A : [Int]) -> Int {
    // write your code in Swift 2.2 (Linux)
       
    let leftSums = A.reduce(([0], 0)) { (res: ([Int64], Int64), x: Int) in
        let (arr, sum) = res
        return (arr + [(sum + x)], sum + x)
    }.0.dropLast()
    
    let rightSums = A.reverse().reduce(([0], 0)) { (res: ([Int64], Int64), x: Int) in
        let (arr, sum) = res
        return (arr + [(sum + x)], sum + x)
    }.0.reverse().dropFirst()
    
    let eqs = zip(leftSums, rightSums).enumerate().map { (i: Int, pair: (Int64, Int64)) -> Int in
        if case let (x,y) = pair where x == y {
            return i
        } else {
            return -1
        }
    }
    
    return eqs.filter{$0>=0}.first ?? -1
}
