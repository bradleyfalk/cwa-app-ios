////
// 🦠 Corona-Warn-App
//

import UIKit
import OpenCombine

/**
	If the ViewController and the FooterViewController are composed inside a TopBottomContainer,
	ViewController that implement this protocol get called if a button gets tapped in the footerViewController
*/
protocol FooterViewHandling {
	var footerView: FooterViewUpdating? { get }
	func didTapFooterViewButton(_ type: FooterViewModel.ButtonType)
}

extension FooterViewHandling where Self: UIViewController {
	var footerView: FooterViewUpdating? {
		return parent as? FooterViewUpdating
	}
}

class FooterViewController: UIViewController {

	// MARK: - Init
	init(
		_ viewModel: FooterViewModel,
		didTapPrimaryButton: @escaping () -> Void = {},
		didTapSecondaryButton: @escaping () -> Void = {}
	) {
		self.viewModel = viewModel
		self.didTapPrimaryButton = didTapPrimaryButton
		self.didTapSecondaryButton = didTapSecondaryButton
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: - Overrides

	override func viewDidLoad() {
		super.viewDidLoad()
		setupPrimaryButton()
		setupSecondaryButton()

		view.backgroundColor = viewModel.backgroundColor

		view.insetsLayoutMarginsFromSafeArea = false
		view.preservesSuperviewLayoutMargins = false
		view.layoutMargins = UIEdgeInsets(
			top: viewModel.topBottomInset,
			left: viewModel.leftRightInset,
			bottom: viewModel.topBottomInset,
			right: viewModel.leftRightInset
		)

		view.addSubview(primaryButton)
		view.addSubview(secondaryButton)

		primaryButton.translatesAutoresizingMaskIntoConstraints = false
		secondaryButton.translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint.activate([
			primaryButton.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
			primaryButton.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
			primaryButton.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
			primaryButton.heightAnchor.constraint(equalToConstant: viewModel.buttonHeight),

			secondaryButton.topAnchor.constraint(equalTo: primaryButton.bottomAnchor, constant: viewModel.spacer),
			secondaryButton.centerXAnchor.constraint(equalTo: primaryButton.centerXAnchor),
			secondaryButton.widthAnchor.constraint(equalTo: primaryButton.widthAnchor),
			secondaryButton.heightAnchor.constraint(equalToConstant: viewModel.buttonHeight)
		])

		// hide and show buttons by alpha to make it animatable

		viewModel.$height
			.receive(on: DispatchQueue.main.ocombine)
			.sink { height in
				let alpha: CGFloat = height > 0.0 ? 1.0 : 0.0
				let animator = UIViewPropertyAnimator(duration: 0.35, curve: .easeInOut) { [weak self] in
					guard let self = self else {
						return
					}
					self.primaryButton.alpha = alpha
					self.secondaryButton.alpha = alpha
				}
				animator.startAnimation()
			}
			.store(in: &subscription)

		// update loading indicators on model change

		viewModel.$isPrimaryLoading
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] show in
				self?.primaryButton.isLoading = show
			}
			.store(in: &subscription)

		viewModel.$isSecondaryLoading
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] show in
				self?.secondaryButton.isLoading = show
			}
			.store(in: &subscription)

		// update enabled state on model change

		viewModel.$isPrimaryButtonEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] isEnabled in
				self?.primaryButton.isEnabled = isEnabled
			}
			.store(in: &subscription)

		viewModel.$isSecondaryButtonEnabled
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] isEnabled in
				self?.secondaryButton.isEnabled = isEnabled
			}
			.store(in: &subscription)

		viewModel.$backgroundColor
			.receive(on: DispatchQueue.main.ocombine)
			.sink { [weak self] color in
				self?.view.backgroundColor = color
			}
			.store(in: &subscription)
	}

	// MARK: - Internal

	let viewModel: FooterViewModel

	// MARK: - Private

	private let didTapPrimaryButton: () -> Void
	private let didTapSecondaryButton: () -> Void

	private let primaryButton: ENAButton = ENAButton(type: .custom)
	private let secondaryButton: ENAButton = ENAButton(type: .custom)
	private var subscription: [AnyCancellable] = []

	private func setupPrimaryButton() {
		if let primaryButtonColor = viewModel.primaryButtonColor {
			primaryButton.color = primaryButtonColor
		}
		primaryButton.setTitle(viewModel.primaryButtonName, for: .normal)
		primaryButton.hasBackground = true
		primaryButton.addTarget(self, action: #selector(didHitPrimaryButton), for: .primaryActionTriggered)
		primaryButton.accessibilityIdentifier = viewModel.primaryIdentifier
		primaryButton.alpha = viewModel.isPrimaryButtonHidden ? 0.0 : 1.0
		primaryButton.isHidden = !viewModel.isPrimaryButtonEnabled
	}

	private func setupSecondaryButton() {
		secondaryButton.setTitle(viewModel.secondaryButtonName, for: .normal)
		secondaryButton.hasBackground = true
		secondaryButton.addTarget(self, action: #selector(didHitSecondaryButton), for: .primaryActionTriggered)
		secondaryButton.accessibilityIdentifier = viewModel.secondaryIdentifier
		secondaryButton.alpha = viewModel.isSecondaryButtonHidden ? 0.0 : 1.0
		secondaryButton.isHidden = !viewModel.isSecondaryButtonEnabled
	}

	@objc
	private func didHitPrimaryButton() {
		guard let footerViewHandler = (parent as? FooterViewUpdating)?.footerViewHandler else {
			didTapPrimaryButton()
			return
		}
		footerViewHandler.didTapFooterViewButton(.primary)
	}

	@objc
	private func didHitSecondaryButton() {
		guard let footerViewHandler = (parent as? FooterViewUpdating)?.footerViewHandler else {
			didTapPrimaryButton()
			return
		}
		footerViewHandler.didTapFooterViewButton(.secondary)
	}
}
