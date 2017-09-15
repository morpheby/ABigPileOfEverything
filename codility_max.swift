import Foundation

func maxArray(for A: [Int]) -> [Int] {
    return A.lazy.reduce([]) { (maxArray: [Int], value: Int) -> [Int] in
        if value > maxArray.first ?? Int.min {
            return maxArray + [value]
        } else {
            return maxArray + [maxArray.last!]
        }
    }
}

func maxArrayFast(for A: [Int]) -> [Int] {
    var B: [Int] = Array(repeating: 0, count: A.count)
    B[0] = A[0]
    for i in 1..<A.count {
        B[i] = max(B[i-1], A[i])
    }
    return B
}

func solution(A: [Int]) -> Int {
    let maxLeft = maxArrayFast(for: A)
    let maxRight = maxArrayFast(for: A.reversed()).reversed()
    let diffs = zip(maxLeft, maxRight).map { x,y in abs(x-y) }
    return diffs.max() ?? -1
}

guard let line = readLine()
else {
    print("Input required")
    abort()
}

guard let val = Int(line)
else {
    print("Invalid input")
    abort()
}

let A = (1..<val).map { _ in Int(arc4random()) } // 4
print("Starting up...")

print(solution(A: A))

