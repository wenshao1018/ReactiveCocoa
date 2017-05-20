import ReactiveSwift
import Result

infix operator <~>: BindingPrecedence

// `ControlBindable` need not conform to `BindingSource`, since the expected public
// APIs for observing user interactions are still the signals named with plural nouns.

public struct ControlBindable<Value>: BindingTargetProvider {
	fileprivate weak var control: NSObject?
	fileprivate let setEnabled: (NSObject, Bool) -> Void
	fileprivate let setValue: (NSObject, Value) -> Void
	fileprivate let values: (NSObject) -> Signal<Value, NoError>

	public var bindingTarget: BindingTarget<Value> {
		let lifetime = control?.reactive.lifetime ?? .empty
		return BindingTarget(on: UIScheduler(), lifetime: lifetime) { [weak control, setValue] value in
			if let control = control {
				setValue(control, value)
			}
		}
	}

	public init<Control: NSObject>(
		control: Control,
		setEnabled: @escaping (Control, Bool) -> Void,
		setValue: @escaping (Control, Value) -> Void,
		values: @escaping (NSObject) -> Signal<Value, NoError>
	) {
		self.control = control
		self.setEnabled = { setEnabled($0 as! Control, $1) }
		self.setValue = { setValue($0 as! Control, $1) }
		self.values = { values($0 as! Control) }
	}
}

// MARK: Property bidirectional binding

extension MutablePropertyProtocol {
	public static func <~>(property: Self, bindable: ControlBindable<Value>) -> Disposable? {
		return nil
	}
}

extension ControlBindable {
	public static func <~> <P: MutablePropertyProtocol>(bindable: ControlBindable, property: P) -> Disposable? where P.Value == Value {
		return property <~> bindable
	}
}

// MARK: Action bidirectional binding

extension Action {
	public static func <~>(action: Action, bindable: ControlBindable<Input>) -> Disposable? {
		return nil
	}
}

extension Action where Input == () {
	public static func <~> <Value>(action: Action, bindable: ControlBindable<Value>) -> Disposable? {
		return nil
	}

	public static func <~> (action: Action, bindable: ControlBindable<()>) -> Disposable? {
		return nil
	}
}

extension ControlBindable {
	public static func <~> <Output, Error>(bindable: ControlBindable, action: Action<Value, Output, Error>) -> Disposable? {
		return action <~> bindable
	}

	public static func <~> <Output, Error>(bindable: ControlBindable, action: Action<(), Output, Error>) -> Disposable? {
		return action <~> bindable
	}
}

extension ControlBindable where Value == () {
	public static func <~> <Output, Error>(bindable: ControlBindable, action: Action<(), Output, Error>) -> Disposable? {
		return action <~> bindable
	}
}
