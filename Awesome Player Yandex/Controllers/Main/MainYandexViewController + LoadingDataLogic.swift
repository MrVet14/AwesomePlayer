import UIKit

enum MainViewSectionType {
	case recommendedSongs(viewModels: [SongCellViewModel])
}

extension MainViewController {
	// MARK: Getting Data Form API & Firebase, then storing & retrieving it from Realm
	func loadTheData() {
		let group = DispatchGroup()
		group.enter()
		group.enter()

		// Purging all songs & playlists in realm on start
		DBManager.shared.purgeSongsAndPlaylistsOnLaunch { success in
			if success {
				group.leave()
			}
		}

		// Creating User
		DBManager.shared.addUserToDB(AuthManagerYandex.shared.createUser())

		// Loading Tracks
//		APICallerYandex.shared.loadChart { [weak self] result in
//			switch result {
//			case .success(let response):
//				DBManager.shared.addSongsToDB(
//					(self?.convertResponse(response.playlist.tracks))!,
//					typeOfPassedSongs: DBSongTypes.recommended,
//					playlistID: ""
//				)
//				group.leave()
//
//			case .failure(let error):
//				self?.handlingErrorDuringLoadingData(error: error)
//			}
//		}

		group.notify(queue: .main) { [weak self] in
			self?.getLikedSongs()
		}
	}

	// MARK: Loading Liked Songs from Firebase
	func getLikedSongs() {
		FirebaseManager.shared.getData { [weak self] result in
			DBManager.shared.markSongsAsLiked(ids: result)

			self?.indicatorView.stopAnimating()
			self?.collectionView.isHidden = false

			self?.configureModels()
		}
	}

	// MARK: Updating Song Data
	func getUpdatedDataFromDB(completion: @escaping (() -> Void)) {
		let group = DispatchGroup()
		group.enter()

		DBManager.shared.getRecommendedSongs { [weak self] recommendedSongsResult in
			self?.recommendedSongs = recommendedSongsResult
			group.leave()
		}

		group.notify(queue: .main) {
			completion()
		}
	}

	// MARK: Creating or updating ViewModels
	@objc
	func configureModels() {
		getUpdatedDataFromDB { [weak self] in
			guard let self = self else {
				return
			}
			// Clearing sections
			self.sections.removeAll()

			let songViewModelsToReturn = self.recommendedSongs.compactMap({
				return SongCellViewModel(
					id: $0.id,
					name: $0.name,
					albumCoverURL: $0.albumCoverURL,
					artistName: $0.artistName,
					explicit: $0.explicit,
					liked: $0.liked)
			})
			self.sections.append(.recommendedSongs(viewModels: songViewModelsToReturn))

			// Reloading Collection View with new data
			self.collectionView.reloadData()
		}
	}

	// MARK: Converting Yandex's response to universal model
	func convertResponse(_ songs: [SongYandex]) -> [Song] {
		var conversion: [Song] = []

		for song in songs {
			let songImage = "https:/\(song.coverUri.replacingOccurrences(of: "%%", with: "400x400"))"
			let conversionImage = Image(url: songImage)

			guard let songAlbum = song.albums[0] else {
				break
			}
			let conversionAlbum = Album(
				id: "\(songAlbum.id)",
				images: [conversionImage],
				name: songAlbum.title)

			guard let songArtist = song.artists[0] else {
				break
			}
			let conversionArtist = Artist(
				id: "\(songAlbum.id)",
				name: songArtist.name)

			conversion.append(
				Song(
					album: conversionAlbum,
					artists: [conversionArtist],
					explicit: false,
					id: song.realId,
					name: song.title,
					preview_url: "123"))
		}

		return conversion
	}
}
