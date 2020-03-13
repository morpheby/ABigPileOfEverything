
func funnyThing() {
  hereWeGo: for i in 0..<100 {
    print(":", terminator: "")
    for j in 0..<100 {
      print(".", terminator: "")
      if i + j == 154 {
        print("\nbreaking…")
        break hereWeGo
      }
    }
  }
  print("Done")
}

funnyThing()
