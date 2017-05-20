import ReactiveSwift
import Result
import UIKit

extension Reactive where Base: UIBarButtonItem {
	/// The current associated action of `self`.
	private var presses: Signal<(), NoError> {
		return associatedValue { base in
			let (signal, observer) = Signal<(), NoError>.pipe()
			let target = CocoaTarget(observer, transform: { _ in })
			base.target = target
			base.action = #selector(target.sendNext(_:))

			return signal
		}
	}

	/// The action to be triggered when the button is pressed. It also controls
	/// the enabled state of the button.
	public var pressed: ControlBindable<()> {
		return ControlBindable(control: base,
		                       setEnabled: { $0.isEnabled = $1 },
		                       setValue: { _ in },
		                       values: { ($0 as! Base).reactive.presses })
	}
}
