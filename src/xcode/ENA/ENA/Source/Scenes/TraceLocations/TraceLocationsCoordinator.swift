//
// 🦠 Corona-Warn-App
//

import UIKit

class TraceLocationsCoordinator {
	
	// MARK: - Init
	
	init(
		store: Store,
		eventStore: EventStoringProviding,
		parentNavigationController: UINavigationController
	) {
		self.store = store
		self.eventStore = eventStore
		self.parentNavigationController = parentNavigationController
	}
	
	// MARK: - Internal
	
	func start() {
		parentNavigationController?.pushViewController(overviewScreen, animated: true)
		
		eventStore.createTraceLocation(tmpTraceLocation)
		eventStore.createTraceLocation(tmpTraceLocation1)
		eventStore.createTraceLocation(tmpTraceLocation2)
		eventStore.createTraceLocation(tmpTraceLocation3)
		
		#if DEBUG
		if isUITesting {
			if let TraceLocationsInfoScreenShown = UserDefaults.standard.string(forKey: "TraceLocationsInfoScreenShown") {
				store.traceLocationsInfoScreenShown = (TraceLocationsInfoScreenShown != "NO")
			}
		}
		#endif
		
		if !infoScreenShown {
			showInfoScreen()
		}
	}
	
	// MARK: - Private
	
	private let store: Store
	private let eventStore: EventStoringProviding

	private var tmpTraceLocation = TraceLocation(guid: "0", version: 0, type: .locationTypeUnspecified, description: "Event in the past", address: "Street 1, 12345 City", startDate: Date(timeIntervalSince1970: 1506432400), endDate: Date(timeIntervalSince1970: 1615805862), defaultCheckInLengthInMinutes: 30, byteRepresentation: Data(), signature: "")
	private var tmpTraceLocation1 = TraceLocation(guid: "1", version: 0, type: .locationTypeUnspecified, description: "Current single-day event", address: "Street 2, 12345 City", startDate: Date(timeIntervalSince1970: 1616803862), endDate: Date(timeIntervalSince1970: 1616805862), defaultCheckInLengthInMinutes: 30, byteRepresentation: Data(), signature: "")
	private var tmpTraceLocation2 = TraceLocation(guid: "2", version: 0, type: .locationTypeUnspecified, description: "Current multi-day event", address: "Street 3, 12345 City", startDate: Date(timeIntervalSince1970: 1616803862), endDate: Date(timeIntervalSince1970: 1616903862), defaultCheckInLengthInMinutes: 30, byteRepresentation: Data(), signature: "")
	private var tmpTraceLocation3 = TraceLocation(guid: "3", version: 0, type: .locationTypeUnspecified, description: "Location", address: "Street 4, 12345 City", startDate: nil, endDate: nil, defaultCheckInLengthInMinutes: 30, byteRepresentation: Data(), signature: "")

	private weak var parentNavigationController: UINavigationController?
	
	private var traceLocationDetailsNavigationController: UINavigationController!
	private var traceLocationAddingNavigationController: UINavigationController!
	
	private var infoScreenShown: Bool {
		get { store.traceLocationsInfoScreenShown }
		set { store.traceLocationsInfoScreenShown = newValue }
	}
	
	// MARK: Show Screens
	
	private lazy var overviewScreen: UIViewController = {
		let traceLocationsOverviewViewController = TraceLocationsOverviewViewController(
			viewModel: TraceLocationsOverviewViewModel(
				store: eventStore,
				onEntryCellTap: { [weak self] traceLocation in
					self?.showTraceLocationDetailsScreen(traceLocation: traceLocation)
				},
				onEntryCellButtonTap: { [weak self] traceLocation in
					self?.showCheckInScreen(traceLocation: traceLocation)
				}
			),
			onInfoButtonTap: { [weak self] in
				self?.showInfoScreen()
			},
			onAddEntryCellTap: { [weak self] in
				self?.showTraceLocationTypeSelectionScreen()
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TraceLocations.Overview.deleteAllButtonTitle,
				isSecondaryButtonEnabled: false,
				isPrimaryButtonHidden: true,
				isSecondaryButtonHidden: true,
				primaryButtonColor: .systemRed
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: traceLocationsOverviewViewController,
			bottomController: footerViewController
		)
		
		return topBottomContainerViewController
	}()
	
	private func showInfoScreen() {
		// Promise the navigation view controller will be available,
		// this is needed to resolve an inset issue with large titles
		var navigationController: UINavigationController!
		let traceLocationsInfoViewController = TraceLocationsInfoViewController(
			viewModel: TraceLocationsInfoViewModel(
				presentDisclaimer: {
					let detailViewController = HTMLViewController(model: AppInformationModel.privacyModel)
					detailViewController.title = AppStrings.AppInformation.privacyTitle
					// hides the footer view as well
					detailViewController.hidesBottomBarWhenPushed = true
					navigationController.pushViewController(detailViewController, animated: true)
				}
			),
			onDismiss: {
				navigationController.dismiss(animated: true)
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TraceLocations.Information.primaryButtonTitle,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true
			),
			didTapPrimaryButton: {
				navigationController.dismiss(animated: true)
			}
		)
		
		let topBottomLayoutViewController = TopBottomContainerViewController(
			topController: traceLocationsInfoViewController,
			bottomController: footerViewController
		)
		navigationController = UINavigationController(rootViewController: topBottomLayoutViewController)
		
		parentNavigationController?.present(navigationController, animated: true) {
			self.infoScreenShown = true
		}
	}
	
	private func showTraceLocationDetailsScreen(traceLocation: TraceLocation) {
		let traceLocationDetailsViewController = TraceLocationDetailsViewController(
			viewModel: TraceLocationDetailsViewModel(traceLocation: traceLocation),
			onPrintVersionButtonTap: { [weak self] traceLocation in
				self?.showPrintVersionScreen(traceLocation: traceLocation)
			},
			onDuplicateButtonTap: { [weak self] traceLocation in
				guard let self = self else { return }
				
				self.showTraceLocationConfigurationScreen(
					on: self.traceLocationDetailsNavigationController,
					mode: .duplicate(traceLocation)
				)
			},
			onDismiss: { [weak self] in
				self?.traceLocationDetailsNavigationController.dismiss(animated: true)
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TraceLocations.Details.printVersionButtonTitle,
				secondaryButtonName: AppStrings.TraceLocations.Details.duplicateButtonTitle,
				isPrimaryButtonHidden: false,
				isSecondaryButtonHidden: false
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: traceLocationDetailsViewController,
			bottomController: footerViewController
		)
		
		traceLocationDetailsNavigationController = UINavigationController(rootViewController: topBottomContainerViewController)
		parentNavigationController?.present(traceLocationDetailsNavigationController, animated: true)
	}
	
	private func showPrintVersionScreen(traceLocation: TraceLocation) {
		let viewController = TraceLocationPrintVersionViewController(
			viewModel: TraceLocationPrintVersionViewModel(traceLocation: traceLocation)
		)
		
		traceLocationDetailsNavigationController.pushViewController(viewController, animated: true)
	}
	
	private func showTraceLocationTypeSelectionScreen() {
		
		let locations: [TraceLocationType] = [
			.locationTypePermanentRetail,
			.locationTypePermanentFoodService,
			.locationTypePermanentCraft,
			.locationTypePermanentWorkplace,
			.locationTypePermanentEducationalInstitution,
			.locationTypePermanentPublicBuilding,
			.locationTypePermanentOther
		]
		
		let events: [TraceLocationType] = [
			.locationTypeTemporaryCulturalEvent,
			.locationTypeTemporaryClubActivity,
			.locationTypeTemporaryPrivateEvent,
			.locationTypeTemporaryWorshipService,
			.locationTypeTemporaryOther
		]
		
		let traceLocationTypeSelectionViewController = TraceLocationTypeSelectionViewController(
			viewModel: TraceLocationTypeSelectionViewModel([
				.location: locations,
				.event: events
			],
			onTraceLocationTypeSelection: { [weak self] traceLocationType in
				guard let self = self else { return }
				
				self.showTraceLocationConfigurationScreen(
					on: self.traceLocationAddingNavigationController,
					mode: .new(traceLocationType)
				)
			}
			),
			onDismiss: { [weak self] in
				self?.traceLocationAddingNavigationController.dismiss(animated: true)
			}
		)
		
		traceLocationAddingNavigationController = UINavigationController(rootViewController: traceLocationTypeSelectionViewController)
		traceLocationAddingNavigationController.navigationBar.prefersLargeTitles = true
		parentNavigationController?.present(traceLocationAddingNavigationController, animated: true)
	}
	
	private func showTraceLocationConfigurationScreen(on navigationController: UINavigationController, mode: TraceLocationConfigurationViewModel.Mode) {
		let traceLocationConfigurationViewController = TraceLocationConfigurationViewController(
			viewModel: TraceLocationConfigurationViewModel(mode: mode),
			onDismiss: {
				navigationController.dismiss(animated: true)
			}
		)
		
		let footerViewController = FooterViewController(
			FooterViewModel(
				primaryButtonName: AppStrings.TraceLocations.Configuration.primaryButtonTitle,
				primaryIdentifier: AccessibilityIdentifiers.ExposureSubmission.primaryButton,
				isSecondaryButtonEnabled: false,
				isSecondaryButtonHidden: true
			)
		)
		
		let topBottomContainerViewController = TopBottomContainerViewController(
			topController: traceLocationConfigurationViewController,
			bottomController: footerViewController
		)
		
		navigationController.pushViewController(topBottomContainerViewController, animated: true)
	}
	
	private func showCheckInScreen(traceLocation: TraceLocation) {
		// Show checkin screen here, for testing purposes we are temporarily directly checking in
		eventStore.createCheckin(
			Checkin(
				id: 0,
				traceLocationGUID: traceLocation.guid,
				traceLocationGUIDHash: Data(),
				traceLocationVersion: traceLocation.version,
				traceLocationType: traceLocation.type,
				traceLocationDescription: traceLocation.description,
				traceLocationAddress: traceLocation.address,
				traceLocationStartDate: traceLocation.startDate,
				traceLocationEndDate: traceLocation.endDate,
				traceLocationDefaultCheckInLengthInMinutes: traceLocation.defaultCheckInLengthInMinutes,
				traceLocationSignature: traceLocation.signature,
				checkinStartDate: Date(),
				checkinEndDate: Date(timeIntervalSinceNow: 4500),
				checkinCompleted: false,
				createJournalEntry: false
			)
		)
	}
	
}
