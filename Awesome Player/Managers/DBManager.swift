import Foundation
import RealmSwift

class DBManager {
	static let shared = DBManager()

	private init() {}

	// MARK: openning Realm
	// swiftlint:disable force_try
	let realm = try! Realm()

	// MARK: adding user data to Realm
	func addUserToDB(_ passedUserData: User) {
		realm.beginWrite()

		/// removing previous entries in realm
		realm.delete(realm.objects(UserObject.self))

		/// creating object and assigning data
		let user = UserObject()
		user.country = passedUserData.country
		user.displayName = passedUserData.display_name
		user.email = passedUserData.email
		user.id = passedUserData.id
		user.imageURL = passedUserData.images.first?.url ?? ""

		/// adding entry to Realm
		realm.add(user)

		realmCommitWrite()
	}

	// MARK: retrieving user data from realm
	func getUserFromDB(completion: @escaping ((UserObject) -> Void)) {
		guard let result = realm.objects(UserObject.self).first else { return }
		completion(result)
	}

	// MARK: adding song to Realm, can be used for Recommended & Liked songs
	func addSongsToDB(
		_ passedSongData: [Song],
		typeOfPassedSongs: String
	) {
		realm.beginWrite()

		/// removing previous entries in realm
		if typeOfPassedSongs == DBSongTypes.recommended {
			realm.delete(realm.objects(SongObject.self).where { $0.recommended == true })
		} else {
			realm.delete(realm.objects(SongObject.self).where { $0.liked == true })
		}

		/// adding parsed song from APICaller to Realm
		for song in passedSongData {
			/// checking if song has preview url, discarding entry if preview url not present
			guard let songPreviewURL = song.preview_url else {
				continue
			}

			/// processing artist names
			/// combining 'em if there's several
			var artistName = ""
			switch song.artists.count {
			case 1:
				artistName = song.artists[0].name
			case 2:
				artistName = "\(song.artists[0].name) & \(song.artists[1].name)"
			default:
				artistName = L10n.numerousArtists
			}

			/// creating object and assigning data
			let songToWrite = SongObject()
			songToWrite.albumName = song.album?.name ?? ""
			songToWrite.albumCoverURL = song.album?.images.first?.url ?? ""
			songToWrite.artistName = artistName
			songToWrite.explicit = song.explicit
			songToWrite.id = song.id
			songToWrite.name = song.name
			songToWrite.previewURL = songPreviewURL
			songToWrite.liked = typeOfPassedSongs == DBSongTypes.liked
			songToWrite.recommended = typeOfPassedSongs == DBSongTypes.recommended

			/// finally adding entry to Realm
			realm.add(songToWrite)
		}

		realmCommitWrite()
	}

	// MARK: retrieving Recommended songs from realm
	func getRecommendedSongsFromDB(completion: @escaping (([SongObject]) -> Void)) {
		let results = realm.objects(SongObject.self).where { $0.recommended == true }
		completion(Array(results))
	}

	// MARK: retrieving Liked songs from realm
	func getLikedSongsFromDB(completion: @escaping (([SongObject]) -> Void)) {
		let results = realm.objects(SongObject.self).where { $0.liked == true }
		completion(Array(results))
	}

	// MARK: marking song as liked
	func likedSong(_ songID: String) {
		guard let songObject = getSongObject(songID) else {
			print("No Object present")
			return
		}

		do {
			try realm.write {
				songObject.liked = true
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: removing song from liked
	func dislikedSong(_ songID: String) {
		guard let songObject = getSongObject(songID) else {
			print("No Object present")
			return
		}

		do {
			try realm.write {
				songObject.liked = false
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: getting song object to be user in likedSong() & dislikedSong() methods
	func getSongObject(_ songID: String) -> SongObject? {
		let result = realm.objects(SongObject.self).where { $0.id == songID }
		return result.first
	}

	// MARK: method for committing write to Realm
	func realmCommitWrite() {
		do {
			try realm.commitWrite()
		} catch {
			print(error.localizedDescription)
		}
	}
}
