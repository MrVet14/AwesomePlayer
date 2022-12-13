import Foundation
import RealmSwift

class DBManager {
	static let shared = DBManager()

	private init() {}

	// MARK: openning Realm
	// swiftlint:disable force_try
	let realm = try! Realm()

	// MARK: adding user data to Realm
	func addUserToDB(_ passedUserData: Result<User, any Error>) {
		switch passedUserData {
		case .success(let data):
			realm.beginWrite()

			/// removing previous entries in realm
			realm.delete(realm.objects(UserObject.self))

			/// creating object and assigning data
			let user = UserObject()
			user.country = data.country
			user.display_name = data.display_name
			user.email = data.email
			user.id = data.id
			user.imageURL = data.images[0].url

			/// adding entry to Realm
			realm.add(user)

			realmCommitWrite()

		case .failure(let error):
			print(error.localizedDescription)
		}
	}

	// MARK: retrieving user data from realm
	func getUserFromDB(completion: ((UserObject) -> Void)) {
		let result = realm.objects(UserObject.self)
		let returnObject = result[0]
		completion(returnObject)
	}

	// MARK: adding song to Realm, can be used for Recommended & Liked songs
	func addSongsToDB(
		_ passedSongData: Result<MultipleSongsResponse, any Error>,
		typeOfPassedSongs: String
	) {
		switch passedSongData {
		case .success(let result):
			realm.beginWrite()

			/// removing previous entries in realm
			if typeOfPassedSongs == DBSongTypes.recommended {
				realm.delete(realm.objects(SongObject.self).filter("recommended == true"))
			} else {
				realm.delete(realm.objects(SongObject.self).filter("liked == true"))
			}

			/// adding parsed song from APICaller to Realm
			for song in result.tracks {
				/// checking if song has preview url, discarding entry if preview url not present
				guard let songPreviewURL = song.preview_url else {
					continue
				}

				/// processing artist names
				/// combining 'em if there's several
				var artistName = ""
				if song.artists.count == 1 {
					artistName = song.artists[0].name
				} else {
					for artist in song.artists {
						artistName += ("\(artist.name) & ")
					}
					artistName = String(artistName.dropLast(3))
				}

				/// creating object and assigning data
				let songToWrite = SongObject()
				songToWrite.albumName = song.album!.name
				songToWrite.albumCoverURL = song.album!.images[0].url
				songToWrite.artistName = artistName
				songToWrite.explicit = song.explicit
				songToWrite.id = song.id
				songToWrite.name = song.name
				songToWrite.preview_url = songPreviewURL

				/// checking type of entry and assigning data accordingly
				if typeOfPassedSongs == DBSongTypes.recommended {
					songToWrite.liked = false
					songToWrite.recommended = true
				} else {
					songToWrite.liked = true
					songToWrite.recommended = false
				}

				/// finally adding entry to Realm
				realm.add(songToWrite)
			}

			realmCommitWrite()

		case .failure(let error):
			print(error.localizedDescription)
		}
	}

	// MARK: retrieving Recommended songs from realm
	func getRecommendedSongsFromDB(completion: ((Results<SongObject>) -> Void)) {
		let result = realm.objects(SongObject.self).filter("recommended == true")
		completion(result)
	}

	// MARK: retrieving Liked songs from realm
	func getLikedSongsFromDB(completion: ((Results<SongObject>) -> Void)) {
		let result = realm.objects(SongObject.self).filter("liked == true")
		completion(result)
	}

	// MARK: marking song as liked
	func likedSong(_ songID: String) {
		let songObject = getSongObject(songID)

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
		let songObject = getSongObject(songID)

		do {
			try realm.write {
				songObject.liked = false
			}
		} catch {
			print(error.localizedDescription)
		}
	}

	// MARK: getting song object to be user in likedSong() & dislikedSong() methods
	func getSongObject(_ songID: String) -> SongObject {
		let result = realm.objects(SongObject.self).filter("id = '\(songID)'")
		let returnObject = result[0]
		return returnObject
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
