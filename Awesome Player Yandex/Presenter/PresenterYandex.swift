import Foundation

extension PlayerPresenter {
	func gettingURL(completion: @escaping (() -> Void)) {
		APICallerYandex.shared.makeFirstCallToAPI(
			songID: currentSong.id,
			albumID: currentSong.albumID) { [weak self] result in
				switch result {
				case .success(let payload):
					APICallerYandex.shared.makeSecondCallToAPI(src: payload.src) { result2 in
						switch result2 {
						case .success(let url):
							self?.currentSongsURL = url

						case .failure(let error):
							print(error.localizedDescription)
						}

						completion()
					}

				case .failure(let error):
					print(error.localizedDescription)
					completion()
				}
		}
	}
}
