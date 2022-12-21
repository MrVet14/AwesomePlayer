import Foundation

class LoadAllTheLikedSongsHelper {
	static let shared = LoadAllTheLikedSongsHelper()

	private init() {}

	var allTheSongsToLoad: [String] = []
	var aBatchToLoad: [String] = []

	func getData(
		_ ids: [String],
		completion: @escaping (([Song]) -> Void)
	) {
		allTheSongsToLoad = ids
		// Костыль, но работает, попозже обязательно переделаю
		var numberOfCallsNeededToFinishTask: Int {
			return ids.count / 50
		}

		var numberOfTimesMethodRan = 0
		makeAPICall { result, success in
			if success {
				if numberOfTimesMethodRan == numberOfCallsNeededToFinishTask {
					completion(result)
				}
			}
			numberOfTimesMethodRan += 1
		}
	}

	// MARK: Breaking all the songs, making calls to API & returning results as solid array
	func makeAPICall(completion: @escaping (([Song], Bool) -> Void)) {
		var songDataToPassBack: [Song] = []

		repeat {
			aBatchToLoad.removeAll()

			if allTheSongsToLoad.count > 50 {
				while aBatchToLoad.count < 50 {
					aBatchToLoad.append(allTheSongsToLoad[0])
					allTheSongsToLoad.removeFirst()
				}
			} else {
				aBatchToLoad = allTheSongsToLoad
				allTheSongsToLoad.removeAll()
			}

			APICaller.shared.loadSongs(aBatchToLoad) { [weak self] result in
				switch result {
				case .success(let data):
					songDataToPassBack += data.tracks
					if self!.allTheSongsToLoad.isEmpty {
						completion(songDataToPassBack, true)
					} else {
						completion([], false)
					}

				case .failure(let error):
					print(error.localizedDescription)
				}
			}
		} while !allTheSongsToLoad.isEmpty
	}
}
