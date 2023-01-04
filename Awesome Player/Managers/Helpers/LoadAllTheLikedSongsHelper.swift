import Foundation

class LoadAllTheLikedSongsHelper {
	static let shared = LoadAllTheLikedSongsHelper()

	private init() {}

	let apiLimit = APIConstants.loadSongsAPILimit
	var allTheSongsToLoad: [String] = []
	var aBatchToLoad: [String] = []

	func getData(
		_ ids: [String],
		completion: @escaping (([Song]) -> Void)
	) {
		allTheSongsToLoad = ids
		var numberOfCallsNeededToFinishTask: Int {
			return ids.count / apiLimit
		}

		var numberOfTimesMethodRan = 0
		makeAPICall { result in
			if !result.isEmpty {
				if numberOfTimesMethodRan == numberOfCallsNeededToFinishTask {
					completion(result)
				}
			}
			numberOfTimesMethodRan += 1
		}
	}

	// MARK: Breaking all the songs, making calls to API & returning results as solid array
	func makeAPICall(completion: @escaping (([Song]) -> Void)) {
		var songDataToPassBack: [Song] = []

		repeat {
			aBatchToLoad.removeAll()

			if allTheSongsToLoad.count > apiLimit {
				while aBatchToLoad.count < apiLimit {
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
					guard let self = self else {
						return
					}
					if self.allTheSongsToLoad.isEmpty {
						completion(songDataToPassBack)
					} else {
						completion([])
					}

				case .failure(let error):
					print(error.localizedDescription)
				}
			}
		} while !allTheSongsToLoad.isEmpty
	}
}
