import Cocoa

var encodedObjectWithValue = """
{
    "something": "abc"
}
""".data(using: .utf8)!

var encodedObjectWithNull = """
{
"something": null
}
""".data(using: .utf8)!

var encodedObjectWithoutValues = """
{
}
""".data(using: .utf8)!


struct ObjectWithDefaultCoder: Decodable {
    var something: String?
}

struct ObjectWithCustomCoderAndDecodeIfPresent: Decodable {
    var something: String?

    init(with coder: Decoder) throws {
        let container = try coder.container(keyedBy: CodingKeys.self)

        something = try container.decodeIfPresent(String.self, forKey: .something)
    }
}

struct ObjectWithCustomCoderAndNilDecoding: Decodable {
    var something: String?

    init(with coder: Decoder) throws {
        let container = try coder.container(keyedBy: CodingKeys.self)

        something = try container.decodeNil(forKey: .something) ? nil : try container.decode(String.self, forKey: .something)
    }
}

struct ObjectWithCustomCoderAndOptionalDecoding: Decodable {
    var something: String?

    init(with coder: Decoder) throws {
        let container = try coder.container(keyedBy: CodingKeys.self)

        something = try container.decode(String?.self, forKey: .something)
    }
}

let normalDecoder = JSONDecoder()

do {
    try normalDecoder.decode(ObjectWithDefaultCoder.self, from: encodedObjectWithValue)
} catch {
    print(error)
}

do {
    try normalDecoder.decode(ObjectWithDefaultCoder.self, from: encodedObjectWithNull)
} catch {
    print(error)
}

do {
    try normalDecoder.decode(ObjectWithDefaultCoder.self, from: encodedObjectWithoutValues)
} catch {
    print(error)
}

do {
    try normalDecoder.decode(ObjectWithCustomCoderAndDecodeIfPresent.self, from: encodedObjectWithValue)
} catch {
    print(error)
}

do {
    try normalDecoder.decode(ObjectWithCustomCoderAndDecodeIfPresent.self, from: encodedObjectWithNull)
} catch {
    print(error)
}

do {
    try normalDecoder.decode(ObjectWithCustomCoderAndDecodeIfPresent.self, from: encodedObjectWithoutValues)
} catch {
    print(error)
}

do {
    try normalDecoder.decode(ObjectWithCustomCoderAndNilDecoding.self, from: encodedObjectWithValue)
} catch {
    print(error)
}

do {
    try normalDecoder.decode(ObjectWithCustomCoderAndNilDecoding.self, from: encodedObjectWithNull)
} catch {
    print(error)
}

do {
    try normalDecoder.decode(ObjectWithCustomCoderAndNilDecoding.self, from: encodedObjectWithoutValues)
} catch {
    print(error)
}

do {
    try normalDecoder.decode(ObjectWithCustomCoderAndOptionalDecoding.self, from: encodedObjectWithValue)
} catch {
    print(error)
}

do {
    try normalDecoder.decode(ObjectWithCustomCoderAndOptionalDecoding.self, from: encodedObjectWithNull)
} catch {
    print(error)
}

do {
    try normalDecoder.decode(ObjectWithCustomCoderAndOptionalDecoding.self, from: encodedObjectWithoutValues)
} catch {
    print(error)
}

