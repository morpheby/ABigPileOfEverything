//

protocol MediaProtocol {}
protocol ImageProtocol: MediaProtocol {}

class Image: ImageProtocol {}

func itemToProcess() -> ImageProtocol {
    return Image()
}

//func process<T>(item: T) -> T { // Uncomment this line and comment out the following one to remove the compile-time error
func process<T: MediaProtocol>(item: T) -> T {
    return item
}

let image = itemToProcess()
let processedImage: ImageProtocol = process(image)
