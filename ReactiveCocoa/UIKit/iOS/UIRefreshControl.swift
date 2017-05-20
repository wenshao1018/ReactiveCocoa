import ReactiveSwift
import enum Result.NoError
import UIKit

extension Reactive where Base: UIRefreshControl {
	/// Sets whether the refresh control should be refreshing.
	public var isRefreshing: BindingTarget<Bool> {
		return makeBindingTarget { $1 ? $0.beginRefreshing() : $0.endRefreshing() }
	}

	/// Sets the attributed title of the refresh control.
	public var attributedTitle: BindingTarget<NSAttributedString?> {
		return makeBindingTarget { $0.attributedTitle = $1 }
	}

	/// The action to be triggered when the refresh control is refreshed. It
	/// also controls the enabled and refreshing states of the refresh control.
	public var refresh: ControlBindable<()> {
		return makeControlBindable(setValue: { _ in },
		                           values: { $0.controlEvents(.valueChanged).map { _ in } })
	}
}
