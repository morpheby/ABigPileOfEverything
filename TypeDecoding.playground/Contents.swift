import Cocoa

let connectedJSON = """
{
        "event": "connected",
        "string": "abc"
}
""".data(using: .utf8)!

let disconnectedJSON = """
{
    "event": "disconnected",
    "number": 123,
    "trueValue": true
}
""".data(using: .utf8)!

struct Event: Codable {
    private enum NestedEventType: Codable {
        case connected(Connected)
        case disconnected(Disconnected)
    }

    struct Connected {
        var string: String
    }

    struct Disconnected {
        var number: Int
        var trueValue: Bool
    }
}



let decoder = JSONDecoder()
let event1 = try! decoder.decode(EventData.self, from: connectedJSON)
let event2 = try! decoder.decode(EventData.self, from: disconnectedJSON)

dump(event1.value)
dump(event2.value)
