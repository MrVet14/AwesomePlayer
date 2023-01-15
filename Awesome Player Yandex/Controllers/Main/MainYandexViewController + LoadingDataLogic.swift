import UIKit

enum MainViewSectionType {
	case recommendedSongs(viewModels: [SongCellViewModel])
}

extension MainViewController {
	// MARK: Getting Data Form API & Firebase, then storing & retrieving it from Realm
	func loadTheData() {
//		let group = DispatchGroup()

		loadingAllNotSuperUrgentStuff()
	}

	// MARK: Loading Data that not used immediately
	func loadingAllNotSuperUrgentStuff() {
	}

	// MARK: Updating Song Data
	func getUpdatedDataFromDB(completion: @escaping (() -> Void)) {
	}

	// MARK: Creating or updating ViewModels
	@objc
	func configureModels() {
	}
}
