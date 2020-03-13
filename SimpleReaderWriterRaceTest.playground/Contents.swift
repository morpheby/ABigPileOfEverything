import Cocoa

struct UserInfo {
    var id: Int
}

class UserRepository {
    /// Internal in-memory storage of the user information
    private var _userInfo: UserInfo = UserInfo(id: 0)

    /// Access `DispatchQueue` to protect the internal storage
    private var queue = DispatchQueue(label: "by.morphe.userinfo", attributes: .concurrent)

    init() {
    }

    /// Accesible in-memory userInfo preventing the readers-writers problem
    var userInfo: UserInfo {
        get {
            return queue.sync {
                return _userInfo
            }
        }
        set {
            queue.async(flags: .barrier) {
                self._userInfo = newValue
            }
        }
    }
}

let repo = UserRepository()

let queue1 = DispatchQueue(label: "bg1")
let queue2 = DispatchQueue(label: "bg2")

queue1.async {
    print("1: Ready; T = 0")
    let id = repo.userInfo.id
    sleep(2)
    repo.userInfo.id = id + 1
    print("1: Finished; T = 2")

}

queue2.async {
    sleep(1)
    print("2: Ready; T = 1")
    let id = repo.userInfo.id
    sleep(2)
    repo.userInfo.id = id + 1
    print("2: Finished; T = 3")
}

print("3: \(repo.userInfo.id) == 2??; T = 0??") // No synchronization possible

sleep(4)

print("4: \(repo.userInfo.id) == 2??; T = 4")

// Reset
print("5: Reset")
repo.userInfo.id = 0

queue1.sync {
    print("6: Ready")
    let id = repo.userInfo.id
    repo.userInfo.id = id + 1
    print("6: Finished")
}

queue2.sync {
    print("7: Ready")
    let id = repo.userInfo.id
    repo.userInfo.id = id + 1
    print("7: Finished")
}

sleep(1)
print("8: \(repo.userInfo.id) == 2") // No synchronization possible

// Reset
print("9: Reset")
repo.userInfo.id = 0

for _ in 0..<500 {
    queue1.async {
        repo.userInfo.id += 1
        repo.userInfo.id
    }

    queue2.async {
        repo.userInfo.id += 1
        repo.userInfo.id
    }
}
queue1.sync {}
queue2.sync {}
print("10: \(repo.userInfo.id) == 1000") // Obvious race
