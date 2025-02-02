////
// 🦠 Corona-Warn-App
//

import XCTest
@testable import ENA

class DiaryOverviewDayCellModelTests: XCTestCase {

	func testGIVEN_NoEncounterDay_WHEN_getTitle_THEN_TextsAreNilAndAnEmptyImage() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .none, minimumDistinctEncountersWithHighRisk: 0)

		// WHEN
		let showExposureHistory = cellViewModel.hideExposureHistory
		let title = cellViewModel.exposureHistoryTitle
		let image = cellViewModel.exposureHistoryImage
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertTrue(showExposureHistory)
		XCTAssertNil(title)
		XCTAssertNil(image)
		XCTAssertNil(detail)
	}

	func testGIVEN_LowEncounterDayWithoutEntries_WHEN_getTitleAndImage_THEN_LowAlterTextAndImage() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .encounter(.low), minimumDistinctEncountersWithHighRisk: 0)

		// WHEN
		let showExposureHistory = cellViewModel.hideExposureHistory
		let title = cellViewModel.exposureHistoryTitle
		let image = cellViewModel.exposureHistoryImage

		// THEN
		XCTAssertFalse(showExposureHistory)
		XCTAssertEqual(title, AppStrings.ContactDiary.Overview.lowRiskTitle)
		XCTAssertEqual(image, UIImage(imageLiteralResourceName: "Icons_Attention_low"))
	}

	func testGIVEN_HighEncounterDayWithoutEntries_WHEN_getTitleAndImage_THEN_HighAlterTextAndImage() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .encounter(.high), minimumDistinctEncountersWithHighRisk: 1)

		// WHEN
		let showExposureHistory = cellViewModel.hideExposureHistory
		let title = cellViewModel.exposureHistoryTitle
		let image = cellViewModel.exposureHistoryImage

		// THEN
		XCTAssertFalse(showExposureHistory)
		XCTAssertEqual(title, AppStrings.ContactDiary.Overview.increasedRiskTitle)
		XCTAssertEqual(image, UIImage(imageLiteralResourceName: "Icons_Attention_high"))
	}

	func testGIVEN_LowEncounterDayWithoutEntries_WHEN_getDetail_THEN_isShorterDetailText() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .encounter(.low), minimumDistinctEncountersWithHighRisk: 0)

		// WHEN
		let showExposureHistory = cellViewModel.hideExposureHistory
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertFalse(showExposureHistory)
		XCTAssertEqual(detail, AppStrings.ContactDiary.Overview.riskTextStandardCause)
	}

	func testGIVEN_LowEncounterDayWithEntries_WHEN_getDetail_THEN_isLongerDetailText() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: [
				.contactPerson(
					DiaryContactPerson(
						id: 0,
						name: "Thomas Mesow",
						encounter: ContactPersonEncounter(
							id: 0,
							date: "2021-01-14",
							contactPersonId: 0
						)
					)
				),
				.location(
					DiaryLocation(
						id: 1,
						name: "Supermarkt",
						traceLocationGUID: nil,
						visit: LocationVisit(
							id: 0,
							date: "2021-01-14",
							locationId: 1,
							checkinId: nil
						)
					)
				)
			]
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .encounter(.low), minimumDistinctEncountersWithHighRisk: 0)

		// WHEN
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertEqual(detail, [AppStrings.ContactDiary.Overview.riskTextStandardCause, AppStrings.ContactDiary.Overview.riskTextDisclaimer].joined(separator: "\n"))
	}
	
	func testGIVEN_HighEncounterDayWithEntries_WHEN_zero_minimumDistinctEncountersWithHighRisk_THEN_TextLowRiskEncounters() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: [
				.contactPerson(DiaryContactPerson(id: 0, name: "Thomas Mesow", encounter: ContactPersonEncounter(id: 0, date: "2021-01-14", contactPersonId: 0))),
				.location(DiaryLocation(id: 1, name: "Supermarkt", traceLocationGUID: nil, visit: LocationVisit(id: 1, date: "2021-01-14", locationId: 1, checkinId: nil)))
			]
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .encounter(.high), minimumDistinctEncountersWithHighRisk: 0)

		// WHEN
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertEqual(detail, [AppStrings.ContactDiary.Overview.riskTextLowRiskEncountersCause, AppStrings.ContactDiary.Overview.riskTextDisclaimer].joined(separator: "\n"))
	}
	
	func testGIVEN_HighEncounterDayWithoutEntries_WHEN_zero_minimumDistinctEncountersWithHighRisk_THEN_TextLowRiskEncounters() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .encounter(.high), minimumDistinctEncountersWithHighRisk: 0)

		// WHEN
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertEqual(detail, AppStrings.ContactDiary.Overview.riskTextLowRiskEncountersCause)
	}
	
	func testGIVEN_HighEncounterDayWithEntries_WHEN_one_minimumDistinctEncountersWithHighRisk_THEN_TextStandard() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: [
				.contactPerson(DiaryContactPerson(id: 0, name: "Thomas Mesow", encounter: ContactPersonEncounter(id: 0, date: "2021-01-14", contactPersonId: 0))),
				.location(DiaryLocation(id: 1, name: "Supermarkt", traceLocationGUID: nil, visit: LocationVisit(id: 1, date: "2021-01-14", locationId: 1, checkinId: nil)))
			]
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .encounter(.high), minimumDistinctEncountersWithHighRisk: 1)

		// WHEN
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertEqual(detail, [AppStrings.ContactDiary.Overview.riskTextStandardCause, AppStrings.ContactDiary.Overview.riskTextDisclaimer].joined(separator: "\n"))
	}
	
	func testGIVEN_HighEncounterDayWithoutEntries_WHEN_multiple_minimumDistinctEncountersWithHighRisk_THEN_TextStandard() {
		// GIVEN
		let diaryDay = DiaryDay(
			dateString: "2021-01-14",
			entries: []
		)
		let cellViewModel = DiaryOverviewDayCellModel(diaryDay, historyExposure: .encounter(.high), minimumDistinctEncountersWithHighRisk: 2)

		// WHEN
		let detail = cellViewModel.exposureHistoryDetail

		// THEN
		XCTAssertEqual(detail, AppStrings.ContactDiary.Overview.riskTextStandardCause)
	}

	func testGIVEN_PersonEncounter_THEN_CorrectEntryDetailTextIsReturned() {
		// GIVEN
		let personEncounter = ContactPersonEncounter(
			id: 0,
			date: "2021-01-14",
			contactPersonId: 0,
			duration: .moreThan15Minutes,
			maskSituation: .withMask,
			setting: .inside,
			circumstances: ""
		)
		let cellViewModel = DiaryOverviewDayCellModel(DiaryDay(dateString: "", entries: []), historyExposure: .encounter(.low), minimumDistinctEncountersWithHighRisk: 0)
		let detailText = cellViewModel.entryDetailTextFor(personEncounter: personEncounter)

		XCTAssertEqual(detailText, "\(AppStrings.ContactDiary.Overview.PersonEncounter.durationMoreThan15Minutes), \(AppStrings.ContactDiary.Overview.PersonEncounter.maskSituationWithMask), \(AppStrings.ContactDiary.Overview.PersonEncounter.settingInside)")
	}

	func testGIVEN_LocationVisit_THEN_CorrectEntryDetailTextIsReturned() {
		// GIVEN
		let locationVisit = LocationVisit(id: 0, date: "2021-01-14", locationId: 0, durationInMinutes: 3 * 60 + 42, circumstances: "", checkinId: nil)
		let cellViewModel = DiaryOverviewDayCellModel(DiaryDay(dateString: "", entries: []), historyExposure: .encounter(.low), minimumDistinctEncountersWithHighRisk: 0)
		let detailText = cellViewModel.entryDetailTextFor(locationVisit: locationVisit)

		XCTAssertEqual(detailText, "03:42 \(AppStrings.ContactDiary.Overview.LocationVisit.abbreviationHours)")
	}
}
