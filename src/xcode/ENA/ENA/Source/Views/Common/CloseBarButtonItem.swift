////
// 🦠 Corona-Warn-App
//

import UIKit

@IBDesignable
class CloseBarButtonItem: UIBarButtonItem {

	// MARK: - Init

	init(
		onTap: @escaping () -> Void,
		contrastMode: Bool = false
	) {
		self.onTap = onTap

		super.init()
		let closeButton = UIButton(type: .custom)
		if contrastMode {
			closeButton.setImage(UIImage(named: "Icons - Close - Contrast"), for: .normal)
		} else {
			closeButton.setImage(UIImage(named: "Icons - Close"), for: .normal)
		}
		closeButton.setImage(UIImage(named: "Icons - Close - Tap"), for: .highlighted)
		closeButton.addTarget(self, action: #selector(didTap), for: .primaryActionTriggered)
		customView = closeButton

		accessibilityLabel = AppStrings.AccessibilityLabel.close
		accessibilityIdentifier = AccessibilityIdentifiers.AccessibilityLabel.close
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Internal

	@objc
	func didTap() {
		onTap()
	}

	let onTap: () -> Void

}
