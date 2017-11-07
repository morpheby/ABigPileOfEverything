import Foundation


public struct SortedArray<Element>: RandomAccessCollection {
    public typealias BackingArray = Array<Element>
    private var backingArray: BackingArray
    public typealias SortClosure = ((_ left: Element, _ right: Element) -> Bool)
    private var sortingClosure: SortClosure

    /// A type that represents a position in the collection.
    ///
    /// Valid indices consist of the position of every element and a
    /// "past the end" position that's not valid for use as a subscript
    /// argument.
    public typealias Index = BackingArray.Index

    /// A type that provides the collection's iteration interface and
    /// encapsulates its iteration state.
    ///
    /// By default, a collection conforms to the `Sequence` protocol by
    /// supplying `IndexingIterator` as its associated `Iterator`
    /// type.
    public typealias Iterator = BackingArray.Iterator

    /// The position of the first element in a nonempty array.
    ///
    /// For an instance of `Array`, `startIndex` is always zero. If the array
    /// is empty, `startIndex` is equal to `endIndex`.
    public var startIndex: Int {
        return backingArray.startIndex
    }

    /// The array's "past the end" position---that is, the position one greater
    /// than the last valid subscript argument.
    ///
    /// When you need a range that includes the last element of an array, use the
    /// half-open range operator (`..<`) with `endIndex`. The `..<` operator
    /// creates a range that doesn't include the upper bound, so it's always
    /// safe to use with `endIndex`. For example:
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     if let i = numbers.index(of: 30) {
    ///         print(numbers[i ..< numbers.endIndex])
    ///     }
    ///     // Prints "[30, 40, 50]"
    ///
    /// If the array is empty, `endIndex` is equal to `startIndex`.
    public var endIndex: Int {
        return backingArray.endIndex
    }

    /// Returns the position immediately after the given index.
    ///
    /// The successor of an index must be well defined. For an index `i` into a
    /// collection `c`, calling `c.index(after: i)` returns the same index every
    /// time.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return backingArray.index(after: i)
    }

    /// Replaces the given index with its successor.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    public func formIndex(after i: inout Int) {
        backingArray.formIndex(after: &i)
    }

    /// Returns the position immediately before the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than
    ///   `startIndex`.
    /// - Returns: The index value immediately before `i`.
    public func index(before i: Int) -> Int {
        return backingArray.index(before: i)
    }

    /// Replaces the given index with its predecessor.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be greater than
    ///   `startIndex`.
    public func formIndex(before i: inout Int) {
        backingArray.formIndex(before: &i)
    }

    /// Returns an index that is the specified distance from the given index.
    ///
    /// The following example obtains an index advanced four positions from an
    /// array's starting index and then prints the element at that position.
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     let i = numbers.index(numbers.startIndex, offsetBy: 4)
    ///     print(numbers[i])
    ///     // Prints "50"
    ///
    /// The value passed as `n` must not offset `i` beyond the bounds of the
    /// collection.
    ///
    /// - Parameters:
    ///   - i: A valid index of the array.
    ///   - n: The distance to offset `i`.
    /// - Returns: An index offset by `n` from the index `i`. If `n` is positive,
    ///   this is the same value as the result of `n` calls to `index(after:)`.
    ///   If `n` is negative, this is the same value as the result of `-n` calls
    ///   to `index(before:)`.
    public func index(_ i: Int, offsetBy n: Int) -> Int {
        return backingArray.index(i, offsetBy: n)
    }

    /// Returns an index that is the specified distance from the given index,
    /// unless that distance is beyond a given limiting index.
    ///
    /// The following example obtains an index advanced four positions from an
    /// array's starting index and then prints the element at that position. The
    /// operation doesn't require going beyond the limiting `numbers.endIndex`
    /// value, so it succeeds.
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     if let i = numbers.index(numbers.startIndex,
    ///                              offsetBy: 4,
    ///                              limitedBy: numbers.endIndex) {
    ///         print(numbers[i])
    ///     }
    ///     // Prints "50"
    ///
    /// The next example attempts to retrieve an index ten positions from
    /// `numbers.startIndex`, but fails, because that distance is beyond the
    /// index passed as `limit`.
    ///
    ///     let j = numbers.index(numbers.startIndex,
    ///                           offsetBy: 10,
    ///                           limitedBy: numbers.endIndex)
    ///     print(j)
    ///     // Prints "nil"
    ///
    /// The value passed as `n` must not offset `i` beyond the bounds of the
    /// collection, unless the index passed as `limit` prevents offsetting
    /// beyond those bounds.
    ///
    /// - Parameters:
    ///   - i: A valid index of the array.
    ///   - n: The distance to offset `i`.
    ///   - limit: A valid index of the collection to use as a limit. If `n > 0`,
    ///     `limit` has no effect if it is less than `i`. Likewise, if `n < 0`,
    ///     `limit` has no effect if it is greater than `i`.
    /// - Returns: An index offset by `n` from the index `i`, unless that index
    ///   would be beyond `limit` in the direction of movement. In that case,
    ///   the method returns `nil`.
    public func index(_ i: Int, offsetBy n: Int, limitedBy limit: Int) -> Int? {
        return backingArray.index(i, offsetBy: n, limitedBy: limit)
    }

    /// Returns the distance between two indices.
    ///
    /// - Parameters:
    ///   - start: A valid index of the collection.
    ///   - end: Another valid index of the collection. If `end` is equal to
    ///     `start`, the result is zero.
    /// - Returns: The distance between `start` and `end`.
    public func distance(from start: Int, to end: Int) -> Int {
        return backingArray.distance(from: start, to: end)
    }

    /// A type that represents the indices that are valid for subscripting the
    /// collection, in ascending order.
    public typealias Indices = BackingArray.Indices

    /// Accesses the element at the specified position.
    ///
    /// The following example uses indexed subscripting to update an array's
    /// second element. After assigning the new value (`"Butler"`) at a specific
    /// position, that value is immediately available at that same position.
    ///
    ///     var streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
    ///     streets[1] = "Butler"
    ///     print(streets[1])
    ///     // Prints "Butler"
    ///
    /// - Parameter index: The position of the element to access. `index` must be
    ///   greater than or equal to `startIndex` and less than `endIndex`.
    ///
    /// - Complexity: Reading an element from an array is O(1). Writing is O(1)
    ///   unless the array's storage is shared with another array, in which case
    ///   writing is O(*n*), where *n* is the length of the array.
    ///   If the array uses a bridged `NSArray` instance as its storage, the
    ///   efficiency is unspecified.
    public subscript(index: Int) -> Element {
        return backingArray[index]
    }

    /// Accesses a contiguous subrange of the array's elements.
    ///
    /// The returned `ArraySlice` instance uses the same indices for the same
    /// elements as the original array. In particular, that slice, unlike an
    /// array, may have a nonzero `startIndex` and an `endIndex` that is not
    /// equal to `count`. Always use the slice's `startIndex` and `endIndex`
    /// properties instead of assuming that its indices start or end at a
    /// particular value.
    ///
    /// This example demonstrates getting a slice of an array of strings, finding
    /// the index of one of the strings in the slice, and then using that index
    /// in the original array.
    ///
    ///     let streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
    ///     let streetsSlice = streets[2 ..< streets.endIndex]
    ///     print(streetsSlice)
    ///     // Prints "["Channing", "Douglas", "Evarts"]"
    ///
    ///     let i = streetsSlice.index(of: "Evarts")    // 4
    ///     print(streets[i!])
    ///     // Prints "Evarts"
    ///
    /// - Parameter bounds: A range of integers. The bounds of the range must be
    ///   valid indices of the array.
    public subscript(bounds: Range<Int>) -> ArraySlice<Element> {
        return backingArray[bounds]
    }

    /// Calls a closure with a pointer to the array's contiguous storage.
    ///
    /// Often, the optimizer can eliminate bounds checks within an array
    /// algorithm, but when that fails, invoking the same algorithm on the
    /// buffer pointer passed into your closure lets you trade safety for speed.
    ///
    /// The following example shows how you can iterate over the contents of the
    /// buffer pointer:
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     let sum = numbers.withUnsafeBufferPointer { buffer -> Int in
    ///         var result = 0
    ///         for i in stride(from: buffer.startIndex, to: buffer.endIndex, by: 2) {
    ///             result += buffer[i]
    ///         }
    ///         return result
    ///     }
    ///     // 'sum' == 9
    ///
    /// The pointer passed as an argument to `body` is valid only during the
    /// execution of `withUnsafeBufferPointer(_:)`. Do not store or return the
    /// pointer for later use.
    ///
    /// - Parameter body: A closure with an `UnsafeBufferPointer` parameter that
    ///   points to the contiguous storage for the array.  If no such storage exists, it is created. If
    ///   `body` has a return value, that value is also used as the return value
    ///   for the `withUnsafeBufferPointer(_:)` method. The pointer argument is
    ///   valid only for the duration of the method's execution.
    /// - Returns: The return value, if any, of the `body` closure parameter.
    public func withUnsafeBufferPointer<R>(_ body: (UnsafeBufferPointer<Element>) throws -> R) rethrows -> R {
        return try backingArray.withUnsafeBufferPointer(body)
    }

    /// Calls the given closure with a pointer to the array's mutable contiguous
    /// storage.
    ///
    /// Often, the optimizer can eliminate bounds checks within an array
    /// algorithm, but when that fails, invoking the same algorithm on the
    /// buffer pointer passed into your closure lets you trade safety for speed.
    ///
    /// The following example shows how modifying the contents of the
    /// `UnsafeMutableBufferPointer` argument to `body` alters the contents of
    /// the array:
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.withUnsafeMutableBufferPointer { buffer in
    ///         for i in stride(from: buffer.startIndex, to: buffer.endIndex - 1, by: 2) {
    ///             buffer.swapAt(i, i + 1)
    ///         }
    ///     }
    ///     print(numbers)
    ///     // Prints "[2, 1, 4, 3, 5]"
    ///
    /// The pointer passed as an argument to `body` is valid only during the
    /// execution of `withUnsafeMutableBufferPointer(_:)`. Do not store or
    /// return the pointer for later use.
    ///
    /// - Warning: Do not rely on anything about the array that is the target of
    ///   this method during execution of the `body` closure; it might not
    ///   appear to have its correct value. Instead, use only the
    ///   `UnsafeMutableBufferPointer` argument to `body`.
    ///
    /// - Parameter body: A closure with an `UnsafeMutableBufferPointer`
    ///   parameter that points to the contiguous storage for the array.
    ///    If no such storage exists, it is created. If `body` has a return value, that value is also
    ///   used as the return value for the `withUnsafeMutableBufferPointer(_:)`
    ///   method. The pointer argument is valid only for the duration of the
    ///   method's execution.
    /// - Returns: The return value, if any, of the `body` closure parameter.
    public mutating func withUnsafeMutableBufferPointer<R>(_ body: (inout UnsafeMutableBufferPointer<Element>) throws -> R) rethrows -> R {
        return try backingArray.withUnsafeMutableBufferPointer(body)
    }

    /// Calls the given closure with a pointer to the underlying bytes of the
    /// array's contiguous storage.
    ///
    /// The array's `Element` type must be a *trivial type*, which can be copied
    /// with just a bit-for-bit copy without any indirection or
    /// reference-counting operations. Generally, native Swift types that do not
    /// contain strong or weak references are trivial, as are imported C structs
    /// and enums.
    ///
    /// The following example copies the bytes of the `numbers` array into a
    /// buffer of `UInt8`:
    ///
    ///     var numbers = [1, 2, 3]
    ///     var byteBuffer: [UInt8] = []
    ///     numbers.withUnsafeBytes {
    ///         byteBuffer.append(contentsOf: $0)
    ///     }
    ///     // byteBuffer == [1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, ...]
    ///
    /// - Parameter body: A closure with an `UnsafeRawBufferPointer` parameter
    ///   that points to the contiguous storage for the array.
    ///    If no such storage exists, it is created. If `body` has a return value, that value is also
    ///   used as the return value for the `withUnsafeBytes(_:)` method. The
    ///   argument is valid only for the duration of the closure's execution.
    /// - Returns: The return value, if any, of the `body` closure parameter.
    public func withUnsafeBytes<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        return try backingArray.withUnsafeBytes(body)
    }

    /// Removes and returns the last element of the array.
    ///
    /// - Returns: The last element of the array if the array is not empty;
    ///   otherwise, `nil`.
    ///
    /// - Complexity: O(*n*) if the array is bridged, where *n* is the length
    ///   of the array; otherwise, O(1).
    public mutating func popLast() -> Element? {
        return backingArray.popLast()
    }

    /// Returns a subsequence containing all but the specified number of final
    /// elements.
    ///
    /// If the number of elements to drop exceeds the number of elements in the
    /// collection, the result is an empty subsequence.
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     print(numbers.dropLast(2))
    ///     // Prints "[1, 2, 3]"
    ///     print(numbers.dropLast(10))
    ///     // Prints "[]"
    ///
    /// - Parameter n: The number of elements to drop off the end of the
    ///   collection. `n` must be greater than or equal to zero.
    /// - Returns: A subsequence that leaves off `n` elements from the end.
    ///
    /// - Complexity: O(*n*), where *n* is the number of elements to drop.
    public func dropLast(_ n: Int) -> ArraySlice<Element> {
        return backingArray.dropLast(n)
    }

    /// Returns a subsequence, up to the given maximum length, containing the
    /// final elements of the collection.
    ///
    /// If the maximum length exceeds the number of elements in the collection,
    /// the result contains the entire collection.
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     print(numbers.suffix(2))
    ///     // Prints "[4, 5]"
    ///     print(numbers.suffix(10))
    ///     // Prints "[1, 2, 3, 4, 5]"
    ///
    /// - Parameter maxLength: The maximum number of elements to return.
    ///   `maxLength` must be greater than or equal to zero.
    /// - Returns: A subsequence terminating at the end of the collection with at
    ///   most `maxLength` elements.
    ///
    /// - Complexity: O(*n*), where *n* is equal to `maxLength`.
    public func suffix(_ maxLength: Int) -> ArraySlice<Element> {
        return backingArray.suffix(maxLength)
    }

    /// Returns an array containing the results of mapping the given closure
    /// over the sequence's elements.
    ///
    /// In this example, `map` is used first to convert the names in the array
    /// to lowercase strings and then to count their characters.
    ///
    ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    ///     let lowercaseNames = cast.map { $0.lowercaseString }
    ///     // 'lowercaseNames' == ["vivien", "marlon", "kim", "karl"]
    ///     let letterCounts = cast.map { $0.count }
    ///     // 'letterCounts' == [6, 6, 3, 4]
    ///
    /// - Parameter transform: A mapping closure. `transform` accepts an
    ///   element of this sequence as its parameter and returns a transformed
    ///   value of the same or of a different type.
    /// - Returns: An array containing the transformed elements of this
    ///   sequence.
    public func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        return try backingArray.map(transform)
    }

    /// Returns a subsequence containing all but the given number of initial
    /// elements.
    ///
    /// If the number of elements to drop exceeds the number of elements in
    /// the collection, the result is an empty subsequence.
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     print(numbers.dropFirst(2))
    ///     // Prints "[3, 4, 5]"
    ///     print(numbers.dropFirst(10))
    ///     // Prints "[]"
    ///
    /// - Parameter n: The number of elements to drop from the beginning of
    ///   the collection. `n` must be greater than or equal to zero.
    /// - Returns: A subsequence starting after the specified number of
    ///   elements.
    ///
    /// - Complexity: O(*n*), where *n* is the number of elements to drop from
    ///   the beginning of the collection.
    public func dropFirst(_ n: Int) -> ArraySlice<Element> {
        return backingArray.dropFirst(n)
    }

    /// Returns a subsequence by skipping elements while `predicate` returns
    /// `true` and returning the remaining elements.
    ///
    /// - Parameter predicate: A closure that takes an element of the
    ///   sequence as its argument and returns `true` if the element should
    ///   be skipped or `false` if it should be included. Once the predicate
    ///   returns `false` it will not be called again.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public func drop(while predicate: (Element) throws -> Bool) rethrows -> ArraySlice<Element> {
        return try backingArray.drop(while: predicate)
    }

    /// Returns a subsequence, up to the specified maximum length, containing
    /// the initial elements of the collection.
    ///
    /// If the maximum length exceeds the number of elements in the collection,
    /// the result contains all the elements in the collection.
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     print(numbers.prefix(2))
    ///     // Prints "[1, 2]"
    ///     print(numbers.prefix(10))
    ///     // Prints "[1, 2, 3, 4, 5]"
    ///
    /// - Parameter maxLength: The maximum number of elements to return.
    ///   `maxLength` must be greater than or equal to zero.
    /// - Returns: A subsequence starting at the beginning of this collection
    ///   with at most `maxLength` elements.
    public func prefix(_ maxLength: Int) -> ArraySlice<Element> {
        return backingArray.prefix(maxLength)
    }

    /// Returns a subsequence containing the initial elements until `predicate`
    /// returns `false` and skipping the remaining elements.
    ///
    /// - Parameter predicate: A closure that takes an element of the
    ///   sequence as its argument and returns `true` if the element should
    ///   be included or `false` if it should be excluded. Once the predicate
    ///   returns `false` it will not be called again.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public func prefix(while predicate: (Element) throws -> Bool) rethrows -> ArraySlice<Element> {
        return try backingArray.prefix(while: predicate)
    }

    /// Returns a subsequence from the start of the collection up to, but not
    /// including, the specified position.
    ///
    /// The resulting subsequence *does not include* the element at the position
    /// `end`. The following example searches for the index of the number `40`
    /// in an array of integers, and then prints the prefix of the array up to,
    /// but not including, that index:
    ///
    ///     let numbers = [10, 20, 30, 40, 50, 60]
    ///     if let i = numbers.index(of: 40) {
    ///         print(numbers.prefix(upTo: i))
    ///     }
    ///     // Prints "[10, 20, 30]"
    ///
    /// Passing the collection's starting index as the `end` parameter results in
    /// an empty subsequence.
    ///
    ///     print(numbers.prefix(upTo: numbers.startIndex))
    ///     // Prints "[]"
    ///
    /// Using the `prefix(upTo:)` method is equivalent to using a partial
    /// half-open range as the collection's subscript. The subscript notation is
    /// preferred over `prefix(upTo:)`.
    ///
    ///     if let i = numbers.index(of: 40) {
    ///         print(numbers[..<i])
    ///     }
    ///     // Prints "[10, 20, 30]"
    ///
    /// - Parameter end: The "past the end" index of the resulting subsequence.
    ///   `end` must be a valid index of the collection.
    /// - Returns: A subsequence up to, but not including, the `end` position.
    ///
    /// - Complexity: O(1)
    public func prefix(upTo end: Int) -> ArraySlice<Element> {
        return backingArray.prefix(upTo: end)
    }

    /// Returns a subsequence from the specified position to the end of the
    /// collection.
    ///
    /// The following example searches for the index of the number `40` in an
    /// array of integers, and then prints the suffix of the array starting at
    /// that index:
    ///
    ///     let numbers = [10, 20, 30, 40, 50, 60]
    ///     if let i = numbers.index(of: 40) {
    ///         print(numbers.suffix(from: i))
    ///     }
    ///     // Prints "[40, 50, 60]"
    ///
    /// Passing the collection's `endIndex` as the `start` parameter results in
    /// an empty subsequence.
    ///
    ///     print(numbers.suffix(from: numbers.endIndex))
    ///     // Prints "[]"
    ///
    /// Using the `suffix(from:)` method is equivalent to using a partial range
    /// from the index as the collection's subscript. The subscript notation is
    /// preferred over `suffix(from:)`.
    ///
    ///     if let i = numbers.index(of: 40) {
    ///         print(numbers[i...])
    ///     }
    ///     // Prints "[40, 50, 60]"
    ///
    /// - Parameter start: The index at which to start the resulting subsequence.
    ///   `start` must be a valid index of the collection.
    /// - Returns: A subsequence starting at the `start` position.
    ///
    /// - Complexity: O(1)
    public func suffix(from start: Int) -> ArraySlice<Element> {
        return backingArray.suffix(from: start)
    }

    /// Returns a subsequence from the start of the collection through the
    /// specified position.
    ///
    /// The resulting subsequence *includes* the element at the position `end`.
    /// The following example searches for the index of the number `40` in an
    /// array of integers, and then prints the prefix of the array up to, and
    /// including, that index:
    ///
    ///     let numbers = [10, 20, 30, 40, 50, 60]
    ///     if let i = numbers.index(of: 40) {
    ///         print(numbers.prefix(through: i))
    ///     }
    ///     // Prints "[10, 20, 30, 40]"
    ///
    /// Using the `prefix(through:)` method is equivalent to using a partial
    /// closed range as the collection's subscript. The subscript notation is
    /// preferred over `prefix(through:)`.
    ///
    ///     if let i = numbers.index(of: 40) {
    ///         print(numbers[...i])
    ///     }
    ///     // Prints "[10, 20, 30, 40]"
    ///
    /// - Parameter end: The index of the last element to include in the
    ///   resulting subsequence. `end` must be a valid index of the collection
    ///   that is not equal to the `endIndex` property.
    /// - Returns: A subsequence up to, and including, the `end` position.
    ///
    /// - Complexity: O(1)
    public func prefix(through position: Int) -> ArraySlice<Element> {
        return backingArray.prefix(through: position)
    }

    /// The last element of the collection.
    ///
    /// If the collection is empty, the value of this property is `nil`.
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     if let lastNumber = numbers.last {
    ///         print(lastNumber)
    ///     }
    ///     // Prints "50"
    public var last: Element? {
        return backingArray.last
    }

    /// Returns the first index in which an element of the collection satisfies
    /// the given predicate.
    ///
    /// You can use the predicate to find an element of a type that doesn't
    /// conform to the `Equatable` protocol or to find an element that matches
    /// particular criteria. Here's an example that finds a student name that
    /// begins with the letter "A":
    ///
    ///     let students = ["Kofi", "Abena", "Peter", "Kweku", "Akosua"]
    ///     if let i = students.index(where: { $0.hasPrefix("A") }) {
    ///         print("\(students[i]) starts with 'A'!")
    ///     }
    ///     // Prints "Abena starts with 'A'!"
    ///
    /// - Parameter predicate: A closure that takes an element as its argument
    ///   and returns a Boolean value that indicates whether the passed element
    ///   represents a match.
    /// - Returns: The index of the first element for which `predicate` returns
    ///   `true`. If no elements in the collection satisfy the given predicate,
    ///   returns `nil`.
    public func index(where predicate: (Element) throws -> Bool) rethrows -> Int? {
        return try backingArray.index(where: predicate)
    }

    public mutating func partition(by belongsInSecondPartition: (Element) throws -> Bool) rethrows -> Int {
        return try backingArray.partition(by: belongsInSecondPartition)
    }

    /// The indices that are valid for subscripting the collection, in ascending
    /// order.
    ///
    /// A collection's `indices` property can hold a strong reference to the
    /// collection itself, causing the collection to be non-uniquely referenced.
    /// If you mutate the collection while iterating over its indices, a strong
    /// reference can cause an unexpected copy of the collection. To avoid the
    /// unexpected copy, use the `index(after:)` method starting with
    /// `startIndex` to produce indices instead.
    ///
    ///     var c = MyFancyCollection([10, 20, 30, 40, 50])
    ///     var i = c.startIndex
    ///     while i != c.endIndex {
    ///         c[i] /= 5
    ///         i = c.index(after: i)
    ///     }
    ///     // c == MyFancyCollection([2, 4, 6, 8, 10])
    public var indices: DefaultRandomAccessIndices<Array<Element>> {
        return backingArray.indices
    }

    /// A sequence containing the same elements as this sequence,
    /// but on which some operations, such as `map` and `filter`, are
    /// implemented lazily.
    public var lazy: LazySequence<Array<Element>> {
        return backingArray.lazy
    }

    /// Creates a new collection containing the specified number of a single,
    /// repeated value.
    ///
    /// Here's an example of creating an array initialized with five strings
    /// containing the letter *Z*.
    ///
    ///     let fiveZs = Array(repeating: "Z", count: 5)
    ///     print(fiveZs)
    ///     // Prints "["Z", "Z", "Z", "Z", "Z"]"
    ///
    /// - Parameters:
    ///   - repeatedValue: The element to repeat.
    ///   - count: The number of times to repeat the value passed in the
    ///     `repeating` parameter. `count` must be zero or greater.
    public init(repeating repeatedValue: Element, count: Int, sortedBy: @escaping SortClosure) {
        backingArray = Array(repeating: repeatedValue, count: count)
        sortingClosure = sortedBy
        backingArray.sort(by: sortingClosure)
    }

    /// Creates a new instance of a collection containing the elements of a
    /// sequence.
    ///
    /// - Parameter elements: The sequence of elements for the new collection.
    public init<S>(_ elements: S, sortedBy: @escaping SortClosure) where S : Sequence, Element == S.Element {
        backingArray = Array(elements)
        sortingClosure = sortedBy
        backingArray.sort(by: sortingClosure)
    }

    /// Adds an element to the end of the collection.
    ///
    /// If the collection does not have sufficient capacity for another element,
    /// additional storage is allocated before appending `newElement`. The
    /// following example adds a new number to an array of integers:
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.append(100)
    ///
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 4, 5, 100]"
    ///
    /// - Parameter newElement: The element to append to the collection.
    ///
    /// - Complexity: O(1) on average, over many additions to the same
    ///   collection.
    public mutating func append(_ newElement: Element) {
        if let insertIndex = (backingArray.index { e -> Bool in
            !self.sortingClosure(e, newElement)
        }) {
            var newIndex = backingArray.index(before: insertIndex)
            if newIndex < backingArray.startIndex {
                newIndex = backingArray.startIndex
            }
            backingArray.insert(newElement, at: newIndex)
        } else {
            backingArray.append(newElement)
        }
    }

    /// Adds the elements of a sequence or collection to the end of this
    /// collection.
    ///
    /// The collection being appended to allocates any additional necessary
    /// storage to hold the new elements.
    ///
    /// The following example appends the elements of a `Range<Int>` instance to
    /// an array of integers:
    ///
    ///     var numbers = [1, 2, 3, 4, 5]
    ///     numbers.append(contentsOf: 10...15)
    ///     print(numbers)
    ///     // Prints "[1, 2, 3, 4, 5, 10, 11, 12, 13, 14, 15]"
    ///
    /// - Parameter newElements: The elements to append to the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the resulting
    ///   collection.
    public mutating func append<S>(contentsOf newElements: S) where S : Sequence, Element == S.Element {
        guard count != 0 else { backingArray.append(contentsOf: newElements) ; return }

        let sorted = newElements.sorted(by: sortingClosure)
        var lastIndex = 0
        for newElement in sorted {
            if let insertIndex = backingArray.dropFirst(lastIndex).index(where: { e -> Bool in
                !self.sortingClosure(e, newElement)
            }) {
                var newIndex = backingArray.index(before: insertIndex)
                if newIndex < backingArray.startIndex {
                    newIndex = backingArray.startIndex
                }
                backingArray.insert(newElement, at: newIndex)
                lastIndex = newIndex
            }
        }
    }

    /// Removes and returns the element at the specified position.
    ///
    /// All the elements following the specified position are moved to close the
    /// gap. This example removes the middle element from an array of
    /// measurements.
    ///
    ///     var measurements = [1.2, 1.5, 2.9, 1.2, 1.6]
    ///     let removed = measurements.remove(at: 2)
    ///     print(measurements)
    ///     // Prints "[1.2, 1.5, 1.2, 1.6]"
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameter position: The position of the element to remove. `position` must be
    ///   a valid index of the collection that is not equal to the collection's
    ///   end index.
    /// - Returns: The removed element.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public mutating func remove(at position: Int) -> Element {
        return backingArray.remove(at: position)
    }

    /// Removes the elements in the specified subrange from the collection.
    ///
    /// All the elements following the specified position are moved to close the
    /// gap. This example removes two elements from the middle of an array of
    /// measurements.
    ///
    ///     var measurements = [1.2, 1.5, 2.9, 1.2, 1.5]
    ///     measurements.removeSubrange(1..<4)
    ///     print(measurements)
    ///     // Prints "[1.2, 1.5]"
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameter bounds: The range of the collection to be removed. The
    ///   bounds of the range must be valid indices of the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public mutating func removeSubrange(_ bounds: Range<Int>) {
        backingArray.removeSubrange(bounds)
    }

    /// Removes the specified number of elements from the beginning of the
    /// collection.
    ///
    ///     var bugs = ["Aphid", "Bumblebee", "Cicada", "Damselfly", "Earwig"]
    ///     bugs.removeFirst(3)
    ///     print(bugs)
    ///     // Prints "["Damselfly", "Earwig"]"
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameter n: The number of elements to remove from the collection.
    ///   `n` must be greater than or equal to zero and must not exceed the
    ///   number of elements in the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public mutating func removeFirst(_ n: Int) {
        backingArray.removeFirst(n)
    }

    /// Removes and returns the first element of the collection.
    ///
    /// The collection must not be empty.
    ///
    ///     var bugs = ["Aphid", "Bumblebee", "Cicada", "Damselfly", "Earwig"]
    ///     bugs.removeFirst()
    ///     print(bugs)
    ///     // Prints "["Bumblebee", "Cicada", "Damselfly", "Earwig"]"
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Returns: The removed element.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public mutating func removeFirst() -> Element {
        return backingArray.removeFirst()
    }

    /// Removes all elements from the collection.
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameter keepCapacity: Pass `true` to request that the collection
    ///   avoid releasing its storage. Retaining the collection's storage can
    ///   be a useful optimization when you're planning to grow the collection
    ///   again. The default value is `false`.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public mutating func removeAll(keepingCapacity keepCapacity: Bool = false) {
        backingArray.removeAll(keepingCapacity: keepCapacity)
    }

    /// Prepares the collection to store the specified number of elements, when
    /// doing so is appropriate for the underlying type.
    ///
    /// If you will be adding a known number of elements to a collection, use
    /// this method to avoid multiple reallocations. A type that conforms to
    /// `RangeReplaceableCollection` can choose how to respond when this method
    /// is called. Depending on the type, it may make sense to allocate more or
    /// less storage than requested or to take no action at all.
    ///
    /// - Parameter n: The requested number of elements to store.
    public mutating func reserveCapacity(_ n: Int) {
        backingArray.reserveCapacity(n)
    }

    /// Removes the elements in the specified subrange from the collection.
    ///
    /// All the elements following the specified position are moved to close the
    /// gap. This example removes two elements from the middle of an array of
    /// measurements.
    ///
    ///     var measurements = [1.2, 1.5, 2.9, 1.2, 1.5]
    ///     measurements.removeSubrange(1..<4)
    ///     print(measurements)
    ///     // Prints "[1.2, 1.5]"
    ///
    /// Calling this method may invalidate any existing indices for use with this
    /// collection.
    ///
    /// - Parameter bounds: The range of the collection to be removed. The
    ///   bounds of the range must be valid indices of the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the collection.
    public mutating func removeSubrange<R>(_ bounds: R) where R : RangeExpression, BackingArray.Index == R.Bound {
        backingArray.removeSubrange(bounds)
    }

    /// Removes and returns the last element of the collection.
    ///
    /// The collection must not be empty.
    ///
    /// Calling this method may invalidate all saved indices of this
    /// collection. Do not rely on a previously stored index value after
    /// altering a collection with any operation that can change its length.
    ///
    /// - Returns: The last element of the collection.
    ///
    /// - Complexity: O(1)
    public mutating func removeLast() -> Element {
        return backingArray.removeLast()
    }

    /// Removes the specified number of elements from the end of the
    /// collection.
    ///
    /// Attempting to remove more elements than exist in the collection
    /// triggers a runtime error.
    ///
    /// Calling this method may invalidate all saved indices of this
    /// collection. Do not rely on a previously stored index value after
    /// altering a collection with any operation that can change its length.
    ///
    /// - Parameter n: The number of elements to remove from the collection.
    ///   `n` must be greater than or equal to zero and must not exceed the
    ///   number of elements in the collection.
    ///
    /// - Complexity: O(*n*), where *n* is the specified number of elements.
    public mutating func removeLast(_ n: Int) {
        backingArray.removeLast(n)
    }

    /// Returns a view presenting the elements of the collection in reverse
    /// order.
    ///
    /// You can reverse a collection without allocating new space for its
    /// elements by calling this `reversed()` method. A
    /// `ReversedRandomAccessCollection` instance wraps an underlying collection
    /// and provides access to its elements in reverse order. This example
    /// prints the elements of an array in reverse order:
    ///
    ///     let numbers = [3, 5, 7]
    ///     for number in numbers.reversed() {
    ///         print(number)
    ///     }
    ///     // Prints "7"
    ///     // Prints "5"
    ///     // Prints "3"
    ///
    /// If you need a reversed collection of the same type, you may be able to
    /// use the collection's sequence-based or collection-based initializer. For
    /// example, to get the reversed version of an array, initialize a new
    /// `Array` instance from the result of this `reversed()` method.
    ///
    ///     let reversedNumbers = Array(numbers.reversed())
    ///     print(reversedNumbers)
    ///     // Prints "[7, 5, 3]"
    ///
    /// - Complexity: O(1)
    public func reversed() -> ReversedRandomAccessCollection<Array<Element>> {
        return backingArray.reversed()
    }

    /// Calls the given closure on each element in the sequence in the same order
    /// as a `for`-`in` loop.
    ///
    /// The two loops in the following example produce the same output:
    ///
    ///     let numberWords = ["one", "two", "three"]
    ///     for word in numberWords {
    ///         print(word)
    ///     }
    ///     // Prints "one"
    ///     // Prints "two"
    ///     // Prints "three"
    ///
    ///     numberWords.forEach { word in
    ///         print(word)
    ///     }
    ///     // Same as above
    ///
    /// Using the `forEach` method is distinct from a `for`-`in` loop in two
    /// important ways:
    ///
    /// 1. You cannot use a `break` or `continue` statement to exit the current
    ///    call of the `body` closure or skip subsequent calls.
    /// 2. Using the `return` statement in the `body` closure will exit only from
    ///    the current call to `body`, not from any outer scope, and won't skip
    ///    subsequent calls.
    ///
    /// - Parameter body: A closure that takes an element of the sequence as a
    ///   parameter.
    public func forEach(_ body: (Element) throws -> Void) rethrows {
        try backingArray.forEach(body)
    }

    /// Returns the first element of the sequence that satisfies the given
    /// predicate.
    ///
    /// The following example uses the `first(where:)` method to find the first
    /// negative number in an array of integers:
    ///
    ///     let numbers = [3, 7, 4, -2, 9, -6, 10, 1]
    ///     if let firstNegative = numbers.first(where: { $0 < 0 }) {
    ///         print("The first negative number is \(firstNegative).")
    ///     }
    ///     // Prints "The first negative number is -2."
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence as
    ///   its argument and returns a Boolean value indicating whether the
    ///   element is a match.
    /// - Returns: The first element of the sequence that satisfies `predicate`,
    ///   or `nil` if there is no element that satisfies `predicate`.
    public func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        return try backingArray.first(where: predicate)
    }

    /// Returns a subsequence containing all but the first element of the
    /// sequence.
    ///
    /// The following example drops the first element from an array of integers.
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     print(numbers.dropFirst())
    ///     // Prints "[2, 3, 4, 5]"
    ///
    /// If the sequence has no elements, the result is an empty subsequence.
    ///
    ///     let empty: [Int] = []
    ///     print(empty.dropFirst())
    ///     // Prints "[]"
    ///
    /// - Returns: A subsequence starting after the first element of the
    ///   sequence.
    ///
    /// - Complexity: O(1)
    public func dropFirst() -> ArraySlice<Element> {
        return backingArray.dropFirst()
    }

    /// Returns a subsequence containing all but the last element of the
    /// sequence.
    ///
    /// The sequence must be finite.
    ///
    ///     let numbers = [1, 2, 3, 4, 5]
    ///     print(numbers.dropLast())
    ///     // Prints "[1, 2, 3, 4]"
    ///
    /// If the sequence has no elements, the result is an empty subsequence.
    ///
    ///     let empty: [Int] = []
    ///     print(empty.dropLast())
    ///     // Prints "[]"
    ///
    /// - Returns: A subsequence leaving off the last element of the sequence.
    ///
    /// - Complexity: O(*n*), where *n* is the length of the sequence.
    public func dropLast() -> ArraySlice<Element> {
        return backingArray.dropLast()
    }

    /// Returns a sequence of pairs (*n*, *x*), where *n* represents a
    /// consecutive integer starting at zero, and *x* represents an element of
    /// the sequence.
    ///
    /// This example enumerates the characters of the string "Swift" and prints
    /// each character along with its place in the string.
    ///
    ///     for (n, c) in "Swift".enumerated() {
    ///         print("\(n): '\(c)'")
    ///     }
    ///     // Prints "0: 'S'"
    ///     // Prints "1: 'w'"
    ///     // Prints "2: 'i'"
    ///     // Prints "3: 'f'"
    ///     // Prints "4: 't'"
    ///
    /// When you enumerate a collection, the integer part of each pair is a counter
    /// for the enumeration, but is not necessarily the index of the paired value.
    /// These counters can be used as indices only in instances of zero-based,
    /// integer-indexed collections, such as `Array` and `ContiguousArray`. For
    /// other collections the counters may be out of range or of the wrong type
    /// to use as an index. To iterate over the elements of a collection with its
    /// indices, use the `zip(_:_:)` function.
    ///
    /// This example iterates over the indices and elements of a set, building a
    /// list consisting of indices of names with five or fewer letters.
    ///
    ///     let names: Set = ["Sofia", "Camilla", "Martina", "Mateo", "Nicolás"]
    ///     var shorterIndices: [SetIndex<String>] = []
    ///     for (i, name) in zip(names.indices, names) {
    ///         if name.count <= 5 {
    ///             shorterIndices.append(i)
    ///         }
    ///     }
    ///
    /// Now that the `shorterIndices` array holds the indices of the shorter
    /// names in the `names` set, you can use those indices to access elements in
    /// the set.
    ///
    ///     for i in shorterIndices {
    ///         print(names[i])
    ///     }
    ///     // Prints "Sofia"
    ///     // Prints "Mateo"
    ///
    /// - Returns: A sequence of pairs enumerating the sequence.
    public func enumerated() -> EnumeratedSequence<Array<Element>> {
        return backingArray.enumerated()
    }

    /// Returns the minimum element in the sequence, using the given predicate as
    /// the comparison between elements.
    ///
    /// The predicate must be a *strict weak ordering* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
    /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
    ///   both `true`, then `areInIncreasingOrder(a, c)` is also
    ///   `true`. (Transitive comparability)
    /// - Two elements are *incomparable* if neither is ordered before the other
    ///   according to the predicate. If `a` and `b` are incomparable, and `b`
    ///   and `c` are incomparable, then `a` and `c` are also incomparable.
    ///   (Transitive incomparability)
    ///
    /// This example shows how to use the `min(by:)` method on a
    /// dictionary to find the key-value pair with the lowest value.
    ///
    ///     let hues = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     let leastHue = hues.min { a, b in a.value < b.value }
    ///     print(leastHue)
    ///     // Prints "Optional(("Coral", 16))"
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns `true`
    ///   if its first argument should be ordered before its second
    ///   argument; otherwise, `false`.
    /// - Returns: The sequence's minimum element, according to
    ///   `areInIncreasingOrder`. If the sequence has no elements, returns
    ///   `nil`.
    @warn_unqualified_access
    public func min(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        return try backingArray.min(by: areInIncreasingOrder)
    }

    /// Returns the maximum element in the sequence, using the given predicate
    /// as the comparison between elements.
    ///
    /// The predicate must be a *strict weak ordering* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
    /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
    ///   both `true`, then `areInIncreasingOrder(a, c)` is also
    ///   `true`. (Transitive comparability)
    /// - Two elements are *incomparable* if neither is ordered before the other
    ///   according to the predicate. If `a` and `b` are incomparable, and `b`
    ///   and `c` are incomparable, then `a` and `c` are also incomparable.
    ///   (Transitive incomparability)
    ///
    /// This example shows how to use the `max(by:)` method on a
    /// dictionary to find the key-value pair with the highest value.
    ///
    ///     let hues = ["Heliotrope": 296, "Coral": 16, "Aquamarine": 156]
    ///     let greatestHue = hues.max { a, b in a.value < b.value }
    ///     print(greatestHue)
    ///     // Prints "Optional(("Heliotrope", 296))"
    ///
    /// - Parameter areInIncreasingOrder:  A predicate that returns `true` if its
    ///   first argument should be ordered before its second argument;
    ///   otherwise, `false`.
    /// - Returns: The sequence's maximum element if the sequence is not empty;
    ///   otherwise, `nil`.
    @warn_unqualified_access
    public func max(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Element? {
        return try backingArray.max(by: areInIncreasingOrder)
    }

    /// Returns a Boolean value indicating whether the sequence precedes another
    /// sequence in a lexicographical (dictionary) ordering, using the given
    /// predicate to compare elements.
    ///
    /// The predicate must be a *strict weak ordering* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areInIncreasingOrder(a, a)` is always `false`. (Irreflexivity)
    /// - If `areInIncreasingOrder(a, b)` and `areInIncreasingOrder(b, c)` are
    ///   both `true`, then `areInIncreasingOrder(a, c)` is also
    ///   `true`. (Transitive comparability)
    /// - Two elements are *incomparable* if neither is ordered before the other
    ///   according to the predicate. If `a` and `b` are incomparable, and `b`
    ///   and `c` are incomparable, then `a` and `c` are also incomparable.
    ///   (Transitive incomparability)
    ///
    /// - Parameters:
    ///   - other: A sequence to compare to this sequence.
    ///   - areInIncreasingOrder:  A predicate that returns `true` if its first
    ///     argument should be ordered before its second argument; otherwise,
    ///     `false`.
    /// - Returns: `true` if this sequence precedes `other` in a dictionary
    ///   ordering as ordered by `areInIncreasingOrder`; otherwise, `false`.
    ///
    /// - Note: This method implements the mathematical notion of lexicographical
    ///   ordering, which has no connection to Unicode.  If you are sorting
    ///   strings to present to the end user, use `String` APIs that perform
    ///   localized comparison instead.
    public func lexicographicallyPrecedes<OtherSequence>(_ other: OtherSequence, by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Bool where OtherSequence : Sequence, Element == OtherSequence.Element {
        return try backingArray.lexicographicallyPrecedes(other, by: areInIncreasingOrder)
    }

    /// Returns a Boolean value indicating whether the sequence contains an
    /// element that satisfies the given predicate.
    ///
    /// You can use the predicate to check for an element of a type that
    /// doesn't conform to the `Equatable` protocol, such as the
    /// `HTTPResponse` enumeration in this example.
    ///
    ///     enum HTTPResponse {
    ///         case ok
    ///         case error(Int)
    ///     }
    ///
    ///     let lastThreeResponses: [HTTPResponse] = [.ok, .ok, .error(404)]
    ///     let hadError = lastThreeResponses.contains { element in
    ///         if case .error = element {
    ///             return true
    ///         } else {
    ///             return false
    ///         }
    ///     }
    ///     // 'hadError' == true
    ///
    /// Alternatively, a predicate can be satisfied by a range of `Equatable`
    /// elements or a general condition. This example shows how you can check an
    /// array for an expense greater than $100.
    ///
    ///     let expenses = [21.37, 55.21, 9.32, 10.18, 388.77, 11.41]
    ///     let hasBigPurchase = expenses.contains { $0 > 100 }
    ///     // 'hasBigPurchase' == true
    ///
    /// - Parameter predicate: A closure that takes an element of the sequence
    ///   as its argument and returns a Boolean value that indicates whether
    ///   the passed element represents a match.
    /// - Returns: `true` if the sequence contains an element that satisfies
    ///   `predicate`; otherwise, `false`.
    public func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try backingArray.contains(where: predicate)
    }

    /// Returns the result of combining the elements of the sequence using the
    /// given closure.
    ///
    /// Use the `reduce(_:_:)` method to produce a single value from the elements
    /// of an entire sequence. For example, you can use this method on an array
    /// of numbers to find their sum or product.
    ///
    /// The `nextPartialResult` closure is called sequentially with an
    /// accumulating value initialized to `initialResult` and each element of
    /// the sequence. This example shows how to find the sum of an array of
    /// numbers.
    ///
    ///     let numbers = [1, 2, 3, 4]
    ///     let numberSum = numbers.reduce(0, { x, y in
    ///         x + y
    ///     })
    ///     // numberSum == 10
    ///
    /// When `numbers.reduce(_:_:)` is called, the following steps occur:
    ///
    /// 1. The `nextPartialResult` closure is called with `initialResult`---`0`
    ///    in this case---and the first element of `numbers`, returning the sum:
    ///    `1`.
    /// 2. The closure is called again repeatedly with the previous call's return
    ///    value and each element of the sequence.
    /// 3. When the sequence is exhausted, the last value returned from the
    ///    closure is returned to the caller.
    ///
    /// If the sequence has no elements, `nextPartialResult` is never executed
    /// and `initialResult` is the result of the call to `reduce(_:_:)`.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value.
    ///     `initialResult` is passed to `nextPartialResult` the first time the
    ///     closure is executed.
    ///   - nextPartialResult: A closure that combines an accumulating value and
    ///     an element of the sequence into a new accumulating value, to be used
    ///     in the next call of the `nextPartialResult` closure or returned to
    ///     the caller.
    /// - Returns: The final accumulated value. If the sequence has no elements,
    ///   the result is `initialResult`.
    public func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        return try backingArray.reduce(initialResult, nextPartialResult)
    }

    /// Returns the result of combining the elements of the sequence using the
    /// given closure.
    ///
    /// Use the `reduce(into:_:)` method to produce a single value from the
    /// elements of an entire sequence. For example, you can use this method on an
    /// array of integers to filter adjacent equal entries or count frequencies.
    ///
    /// This method is preferred over `reduce(_:_:)` for efficiency when the
    /// result is a copy-on-write type, for example an Array or a Dictionary.
    ///
    /// The `updateAccumulatingResult` closure is called sequentially with a
    /// mutable accumulating value initialized to `initialResult` and each element
    /// of the sequence. This example shows how to build a dictionary of letter
    /// frequencies of a string.
    ///
    ///     let letters = "abracadabra"
    ///     let letterCount = letters.reduce(into: [:]) { counts, letter in
    ///         counts[letter, default: 0] += 1
    ///     }
    ///     // letterCount == ["a": 5, "b": 2, "r": 2, "c": 1, "d": 1]
    ///
    /// When `letters.reduce(into:_:)` is called, the following steps occur:
    ///
    /// 1. The `updateAccumulatingResult` closure is called with the initial
    ///    accumulating value---`[:]` in this case---and the first character of
    ///    `letters`, modifying the accumulating value by setting `1` for the key
    ///    `"a"`.
    /// 2. The closure is called again repeatedly with the updated accumulating
    ///    value and each element of the sequence.
    /// 3. When the sequence is exhausted, the accumulating value is returned to
    ///    the caller.
    ///
    /// If the sequence has no elements, `updateAccumulatingResult` is never
    /// executed and `initialResult` is the result of the call to
    /// `reduce(into:_:)`.
    ///
    /// - Parameters:
    ///   - initialResult: The value to use as the initial accumulating value.
    ///   - updateAccumulatingResult: A closure that updates the accumulating
    ///     value with an element of the sequence.
    /// - Returns: The final accumulated value. If the sequence has no elements,
    ///   the result is `initialResult`.
    public func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (inout Result, Element) throws -> ()) rethrows -> Result {
        return try backingArray.reduce(into: initialResult, updateAccumulatingResult)
    }

    public func flatMap(_ transform: (Element) throws -> String?) rethrows -> [String] {
        return try backingArray.flatMap(transform)
    }
}

/// Augment `self` with lazy methods such as `map`, `filter`, etc.
extension SortedArray {

    /// A view onto this collection that provides lazy implementations of
    /// normally eager operations, such as `map` and `filter`.
    ///
    /// Use the `lazy` property when chaining operations to prevent
    /// intermediate operations from allocating storage, or when you only
    /// need a part of the final collection to avoid unnecessary computation.
    public var lazy: LazyBidirectionalCollection<Array<Element>> {
        return backingArray.lazy
    }
}

extension SortedArray {

    /// A Boolean value indicating whether the collection is empty.
    ///
    /// When you need to check whether your collection is empty, use the
    /// `isEmpty` property instead of checking that the `count` property is
    /// equal to zero. For collections that don't conform to
    /// `RandomAccessCollection`, accessing the `count` property iterates
    /// through the elements of the collection.
    ///
    ///     let horseName = "Silver"
    ///     if horseName.isEmpty {
    ///         print("I've been through the desert on a horse with no name.")
    ///     } else {
    ///         print("Hi ho, \(horseName)!")
    ///     }
    ///     // Prints "Hi ho, Silver!")
    ///
    /// - Complexity: O(1)
    public var isEmpty: Bool {
        return backingArray.isEmpty
    }

    /// The first element of the collection.
    ///
    /// If the collection is empty, the value of this property is `nil`.
    ///
    ///     let numbers = [10, 20, 30, 40, 50]
    ///     if let firstNumber = numbers.first {
    ///         print(firstNumber)
    ///     }
    ///     // Prints "10"
    public var first: Element? {
        return backingArray.first
    }

    /// A value less than or equal to the number of elements in the collection.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*n*), where *n* is the length
    ///   of the collection.
    public var underestimatedCount: Int {
        return backingArray.underestimatedCount
    }

    /// The number of elements in the collection.
    ///
    /// To check whether a collection is empty, use its `isEmpty` property
    /// instead of comparing `count` to zero. Unless the collection guarantees
    /// random-access performance, calculating `count` can be an O(*n*)
    /// operation.
    ///
    /// - Complexity: O(1) if the collection conforms to
    ///   `RandomAccessCollection`; otherwise, O(*n*), where *n* is the length
    ///   of the collection.
    public var count: Int {
        return backingArray.count
    }
}

/// Supply the default `makeIterator()` method for `Collection` models
/// that accept the default associated `Iterator`,
/// `IndexingIterator<Self>`.
extension SortedArray {

    /// Returns an iterator over the elements of the collection.
    public func makeIterator() -> IndexingIterator<Array<Element>> {
        return backingArray.makeIterator()
    }
}

extension SortedArray : Encodable {

    /// Encodes this value into the given encoder.
    ///
    /// If the value fails to encode anything, `encoder` will encode an empty
    /// keyed container in its place.
    ///
    /// This function throws an error if any values are invalid for the given
    /// encoder's format.
    ///
    /// - Parameter encoder: The encoder to write data to.
    public func encode(to encoder: Encoder) throws {
        try backingArray.encode(to: encoder)
    }
}

extension SortedArray : CustomReflectable {

    /// A mirror that reflects the array.
    public var customMirror: Mirror {
        return backingArray.customMirror
    }
}

extension SortedArray : CustomStringConvertible, CustomDebugStringConvertible {

    /// A textual representation of the array and its elements.
    public var description: String {
        return backingArray.description
    }

    /// A textual representation of the array and its elements, suitable for
    /// debugging.
    public var debugDescription: String {
        return backingArray.debugDescription
    }
}

extension SortedArray where Element : Collection {

    /// Returns the elements of this collection of collections, concatenated.
    ///
    /// In this example, an array of three ranges is flattened so that the
    /// elements of each range can be iterated in turn.
    ///
    ///     let ranges = [0..<3, 8..<10, 15..<17]
    ///
    ///     // A for-in loop over 'ranges' accesses each range:
    ///     for range in ranges {
    ///       print(range)
    ///     }
    ///     // Prints "0..<3"
    ///     // Prints "8..<10"
    ///     // Prints "15..<17"
    ///
    ///     // Use 'joined()' to access each element of each range:
    ///     for index in ranges.joined() {
    ///         print(index, terminator: " ")
    ///     }
    ///     // Prints: "0 1 2 8 9 15 16"
    ///
    /// - Returns: A flattened view of the elements of this
    ///   collection of collections.
    public func joined() -> FlattenCollection<Array<Element>> {
        return backingArray.joined()
    }
}

extension SortedArray where Element : BidirectionalCollection {

    /// Returns the elements of this collection of collections, concatenated.
    ///
    /// In this example, an array of three ranges is flattened so that the
    /// elements of each range can be iterated in turn.
    ///
    ///     let ranges = [0..<3, 8..<10, 15..<17]
    ///
    ///     // A for-in loop over 'ranges' accesses each range:
    ///     for range in ranges {
    ///       print(range)
    ///     }
    ///     // Prints "0..<3"
    ///     // Prints "8..<10"
    ///     // Prints "15..<17"
    ///
    ///     // Use 'joined()' to access each element of each range:
    ///     for index in ranges.joined() {
    ///         print(index, terminator: " ")
    ///     }
    ///     // Prints: "0 1 2 8 9 15 16"
    ///
    /// - Returns: A flattened view of the elements of this
    ///   collection of collections.
    public func joined() -> FlattenBidirectionalCollection<Array<Element>> {
        return backingArray.joined()
    }
}

extension SortedArray where Element: Equatable {

    /// Returns the first index where the specified value appears in the
    /// collection.
    ///
    /// After using `index(of:)` to find the position of a particular element in
    /// a collection, you can use it to access the element by subscripting. This
    /// example shows how you can modify one of the names in an array of
    /// students.
    ///
    ///     var students = ["Ben", "Ivy", "Jordell", "Maxime"]
    ///     if let i = students.index(of: "Maxime") {
    ///         students[i] = "Max"
    ///     }
    ///     print(students)
    ///     // Prints "["Ben", "Ivy", "Jordell", "Max"]"
    ///
    /// - Parameter element: An element to search for in the collection.
    /// - Returns: The first index where `element` is found. If `element` is not
    ///   found in the collection, returns `nil`.
    public func index(of element: Element) -> Int? {
        return backingArray.index(of: element)
    }

    /// Returns the longest possible subsequences of the collection, in order,
    /// that don't contain elements satisfying the given predicate.
    ///
    /// The resulting array consists of at most `maxSplits + 1` subsequences.
    /// Elements that are used to split the sequence are not returned as part of
    /// any subsequence.
    ///
    /// The following examples show the effects of the `maxSplits` and
    /// `omittingEmptySubsequences` parameters when splitting a string using a
    /// closure that matches spaces. The first use of `split` returns each word
    /// that was originally separated by one or more spaces.
    ///
    ///     let line = "BLANCHE:   I don't want realism. I want magic!"
    ///     print(line.split(whereSeparator: { $0 == " " }))
    ///     // Prints "["BLANCHE:", "I", "don\'t", "want", "realism.", "I", "want", "magic!"]"
    ///
    /// The second example passes `1` for the `maxSplits` parameter, so the
    /// original string is split just once, into two new strings.
    ///
    ///     print(line.split(maxSplits: 1, whereSeparator: { $0 == " " }))
    ///     // Prints "["BLANCHE:", "  I don\'t want realism. I want magic!"]"
    ///
    /// The final example passes `false` for the `omittingEmptySubsequences`
    /// parameter, so the returned array contains empty strings where spaces
    /// were repeated.
    ///
    ///     print(line.split(omittingEmptySubsequences: false, whereSeparator: { $0 == " " }))
    ///     // Prints "["BLANCHE:", "", "", "I", "don\'t", "want", "realism.", "I", "want", "magic!"]"
    ///
    /// - Parameters:
    ///   - maxSplits: The maximum number of times to split the collection, or
    ///     one less than the number of subsequences to return. If
    ///     `maxSplits + 1` subsequences are returned, the last one is a suffix
    ///     of the original collection containing the remaining elements.
    ///     `maxSplits` must be greater than or equal to zero. The default value
    ///     is `Int.max`.
    ///   - omittingEmptySubsequences: If `false`, an empty subsequence is
    ///     returned in the result for each pair of consecutive elements
    ///     satisfying the `isSeparator` predicate and for each element at the
    ///     start or end of the collection satisfying the `isSeparator`
    ///     predicate. The default value is `true`.
    ///   - isSeparator: A closure that takes an element as an argument and
    ///     returns a Boolean value indicating whether the collection should be
    ///     split at that element.
    /// - Returns: An array of subsequences, split from this collection's
    ///   elements.
    public func split(maxSplits: Int = Int.max, omittingEmptySubsequences: Bool = true, whereSeparator isSeparator: (Element) throws -> Bool) rethrows -> [ArraySlice<Element>] {
        return try backingArray.split(maxSplits: maxSplits, omittingEmptySubsequences: omittingEmptySubsequences, whereSeparator: isSeparator)
    }

    /// Returns a Boolean value indicating whether the initial elements of the
    /// sequence are equivalent to the elements in another sequence, using
    /// the given predicate as the equivalence test.
    ///
    /// The predicate must be a *equivalence relation* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areEquivalent(a, a)` is always `true`. (Reflexivity)
    /// - `areEquivalent(a, b)` implies `areEquivalent(b, a)`. (Symmetry)
    /// - If `areEquivalent(a, b)` and `areEquivalent(b, c)` are both `true`, then
    ///   `areEquivalent(a, c)` is also `true`. (Transitivity)
    ///
    /// - Parameters:
    ///   - possiblePrefix: A sequence to compare to this sequence.
    ///   - areEquivalent: A predicate that returns `true` if its two arguments
    ///     are equivalent; otherwise, `false`.
    /// - Returns: `true` if the initial elements of the sequence are equivalent
    ///   to the elements of `possiblePrefix`; otherwise, `false`. If
    ///   `possiblePrefix` has no elements, the return value is `true`.
    public func starts<PossiblePrefix>(with possiblePrefix: PossiblePrefix, by areEquivalent: (Element, Element) throws -> Bool) rethrows -> Bool where PossiblePrefix : Sequence, Element == PossiblePrefix.Element {
        return try backingArray.starts(with: possiblePrefix, by: areEquivalent)
    }

    /// Returns a Boolean value indicating whether this sequence and another
    /// sequence contain equivalent elements in the same order, using the given
    /// predicate as the equivalence test.
    ///
    /// At least one of the sequences must be finite.
    ///
    /// The predicate must be a *equivalence relation* over the elements. That
    /// is, for any elements `a`, `b`, and `c`, the following conditions must
    /// hold:
    ///
    /// - `areEquivalent(a, a)` is always `true`. (Reflexivity)
    /// - `areEquivalent(a, b)` implies `areEquivalent(b, a)`. (Symmetry)
    /// - If `areEquivalent(a, b)` and `areEquivalent(b, c)` are both `true`, then
    ///   `areEquivalent(a, c)` is also `true`. (Transitivity)
    ///
    /// - Parameters:
    ///   - other: A sequence to compare to this sequence.
    ///   - areEquivalent: A predicate that returns `true` if its two arguments
    ///     are equivalent; otherwise, `false`.
    /// - Returns: `true` if this sequence and `other` contain equivalent items,
    ///   using `areEquivalent` as the equivalence test; otherwise, `false.`
    public func elementsEqual<OtherSequence>(_ other: OtherSequence, by areEquivalent: (Element, Element) throws -> Bool) rethrows -> Bool where OtherSequence : Sequence, Element == OtherSequence.Element {
        return try backingArray.elementsEqual(other, by: areEquivalent)
    }
}

extension SortedArray where Element : StringProtocol {

    /// Returns a new string by concatenating the elements of the sequence,
    /// adding the given separator between each element.
    ///
    /// The following example shows how an array of strings can be joined to a
    /// single, comma-separated string:
    ///
    ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    ///     let list = cast.joined(separator: ", ")
    ///     print(list)
    ///     // Prints "Vivien, Marlon, Kim, Karl"
    ///
    /// - Parameter separator: A string to insert between each of the elements
    ///   in this sequence. The default separator is an empty string.
    /// - Returns: A single, concatenated string.
    public func joined(separator: String = " ") -> String {
        return backingArray.joined(separator: separator)
    }
}

extension SortedArray where Element : Sequence {

    /// Returns the elements of this sequence of sequences, concatenated.
    ///
    /// In this example, an array of three ranges is flattened so that the
    /// elements of each range can be iterated in turn.
    ///
    ///     let ranges = [0..<3, 8..<10, 15..<17]
    ///
    ///     // A for-in loop over 'ranges' accesses each range:
    ///     for range in ranges {
    ///       print(range)
    ///     }
    ///     // Prints "0..<3"
    ///     // Prints "8..<10"
    ///     // Prints "15..<17"
    ///
    ///     // Use 'joined()' to access each element of each range:
    ///     for index in ranges.joined() {
    ///         print(index, terminator: " ")
    ///     }
    ///     // Prints: "0 1 2 8 9 15 16"
    ///
    /// - Returns: A flattened view of the elements of this
    ///   sequence of sequences.
    public func joined() -> FlattenSequence<Array<Element>> {
        return backingArray.joined()
    }

    /// Returns the concatenated elements of this sequence of sequences,
    /// inserting the given separator between each element.
    ///
    /// This example shows how an array of `[Int]` instances can be joined, using
    /// another `[Int]` instance as the separator:
    ///
    ///     let nestedNumbers = [[1, 2, 3], [4, 5, 6], [7, 8, 9]]
    ///     let joined = nestedNumbers.joined(separator: [-1, -2])
    ///     print(Array(joined))
    ///     // Prints "[1, 2, 3, -1, -2, 4, 5, 6, -1, -2, 7, 8, 9]"
    ///
    /// - Parameter separator: A sequence to insert between each of this
    ///   sequence's elements.
    /// - Returns: The joined sequence of elements.
    public func joined<Separator>(separator: Separator) -> JoinedSequence<Array<Element>> where Separator : Sequence, Separator.Element == Element.Element {
        return backingArray.joined(separator: separator)
    }
}

extension SortedArray where Element == String {

    /// Returns a new string by concatenating the elements of the sequence,
    /// adding the given separator between each element.
    ///
    /// The following example shows how an array of strings can be joined to a
    /// single, comma-separated string:
    ///
    ///     let cast = ["Vivien", "Marlon", "Kim", "Karl"]
    ///     let list = cast.joined(separator: ", ")
    ///     print(list)
    ///     // Prints "Vivien, Marlon, Kim, Karl"
    ///
    /// - Parameter separator: A string to insert between each of the elements
    ///   in this sequence. The default separator is an empty string.
    /// - Returns: A single, concatenated string.
    public func joined(separator: String = " ") -> String {
        return backingArray.joined(separator: separator)
    }
}

extension SortedArray {
    /// Returns `true` if these arrays contain the same elements.
    public static func ==<Element>(lhs: SortedArray<Element>, rhs: SortedArray<Element>) -> Bool where Element : Equatable {
        return lhs.backingArray == rhs.backingArray
    }

    /// Returns `true` if the arrays do not contain the same elements.
    public static func !=<Element>(lhs: SortedArray<Element>, rhs: SortedArray<Element>) -> Bool where Element : Equatable {
        return lhs.backingArray != rhs.backingArray
    }
}
