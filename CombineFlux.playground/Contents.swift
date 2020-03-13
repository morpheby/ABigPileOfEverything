//: A UIKit based Playground for presenting user interface
  
import UIKit
import Combine
import PlaygroundSupport

struct ViewFactory<T> where T: UIView {
    private let view: T

    init(_ create: () -> T = T.init, _ configure: ((T) -> Void)? = nil) {
        view = create()
        configure?(view)
    }

    func create<U>(_ update: @escaping (T, U) -> Void) -> (U) -> T {
        return { [view] value in
            update(view, value)
            return view
        }
    }
}

extension Publisher {
    func `do`(_ closure: @escaping (Output) -> Void) -> Publishers.Map<Self, Output> {
        return self.map { (value) -> Output in
            closure(value)
            return value
        }
    }
}

extension Publisher where Output: UIView, Failure == Never {
    func attach<S: Publisher>(to view: UIView, show: S) -> AnyCancellable where S.Output == Bool, S.Failure == Never {
        return self
            .combineLatest(show.removeDuplicates())
            .subscribe(on: RunLoop.main)
            .sink { (subview, show) in
                if show {
                    view.addSubview(subview)
                } else {
                    subview.removeFromSuperview()
                }
            }
    }
}

struct EventPublisher: Publisher {

    typealias Output = Void
    typealias Failure = Never

    let source: UIControl
    let event: UIControl.Event

    class EventSubscription: Subscription {

        var demand: Subscribers.Demand = .none
        let subscriber: AnySubscriber<Void, Never>

        init(subsriber: AnySubscriber<Void, Never>) {
            self.subscriber = subsriber
        }

        func request(_ demand: Subscribers.Demand) {
            self.demand = demand
        }

        func cancel() {
        }

        @objc
        func handle(_ sender: UIResponder) {
            guard demand > 0 else { return }
            demand -= 1
            subscriber.receive()
        }

    }

    init(source: UIControl, event: UIControl.Event) {
        self.source = source
        self.event = event
    }

    func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        let s = EventSubscription(subsriber: AnySubscriber(subscriber))
        source.addTarget(s, action: #selector(EventSubscription.handle(_:)), for: event)
        subscriber.receive(subscription: s)
    }
}

extension UIControl {
    func publisher(for event: UIControl.Event) -> EventPublisher {
        return EventPublisher(source: self, event: event)
    }
}

struct State: Equatable {
    var label = "Hello World!"
    var buttonText = "Click me!"
    var introDone = false
}

class MyViewController : UIViewController {
    @Published
    var state: State = State()

    var stateCancellables = Set<AnyCancellable>()

    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let disappearanceAnimator = Deferred { Just(UIViewPropertyAnimator()) }

        $state
            .map(\.label)
            .removeDuplicates()
            .map(ViewFactory<UILabel> { label in
                label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
                label.textColor = .black
            }.create { label, value in
                label.text = value
            })
            .attach(to: view, show: $state.map(\.introDone).map(!))
            .store(in: &stateCancellables)

        $state
            .map(\.buttonText)
            .removeDuplicates()
            .map(ViewFactory<UIButton>({ UIButton(type: .system) }) { button in
                button.publisher(for: .primaryActionTriggered)
                    .map { _ in false }
                    .assign(to: \.state.introDone, on: self)
                    .store(in: &self.stateCancellables)
                button.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
            }.create { button, value in
                button.setTitle(value, for: .normal)
            })
            .attach(to: view, show: $state.map(\.introDone))

        $state
            .map(\.introDone)
            .filter { $0 == false }
            .map { _ in
                Timer.publish(every: 5.0, on: RunLoop.main, in: .default)
                    .autoconnect()
                    .first()
            }
            .switchToLatest()
            .sink { _ in
                self.state.introDone = true
            }
            .store(in: &stateCancellables)

        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
