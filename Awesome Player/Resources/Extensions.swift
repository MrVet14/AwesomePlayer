import Foundation
import UIKit

extension UIView {
	var width: CGFloat {
		return frame.size.width
	}

	var height: CGFloat {
		return frame.size.height
	}

	var left: CGFloat {
		return frame.origin.x
	}

	var right: CGFloat {
		return left + width
	}

	var top: CGFloat {
		return frame.origin.y
	}

	var bottom: CGFloat {
		return top + height
	}
}

extension UIView {
	func fadeTransition(_ duration:CFTimeInterval) {
		let animation = CATransition()
		animation.timingFunction = CAMediaTimingFunction(name:
			CAMediaTimingFunctionName.easeInEaseOut)
		animation.type = CATransitionType.fade
		animation.duration = duration
		layer.add(animation, forKey: CATransitionType.fade.rawValue)
	}
}
