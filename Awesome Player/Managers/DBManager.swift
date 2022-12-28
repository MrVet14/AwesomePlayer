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
		// Checking if song we try to add already exists in realm
		// And adding theres IDs to an Array
		var alreadyExistingSongs: [String] = []
		for song in passedSongData {
			guard let songObject = getSongObject(song.id) else {
				continue
			}
			alreadyExistingSongs.append(songObject.id)
		}

		/// adding parsed song from APICaller to Realm
		for song in passedSongData {
			/// checking if song has preview url, discarding entry if preview url not present
			guard let songPreviewURL = song.preview_url else {
				continue
			}

			// If song already in Realm, we just change one of the attributes
			if alreadyExistingSongs.contains(song.id) {
				print("The song is in realm and needs changing")
				guard let songObject = getSongObject(song.id) else {
					continue
				}
				do {
					try realm.write {
						/// If existing song was recommended, we just add liked attribute
						if songObject.recommended {
							songObject.liked = true
						} /// The opposite of comment above
						else if songObject.liked {
							songObject.recommended = true
						}
					}
				} catch {
					print("Error while updating existing song", error.localizedDescription)
				}
			} // If song not in Realm, we create new object & add it to Realm
			else {
				print("That song not in realm yet, adding song")
				realm.beginWrite()
				/// creating object and assigning data
				let songToWrite = SongObject()
				songToWrite.albumName = song.album?.name ?? ""
				songToWrite.albumCoverURL = song.album?.images.first?.url ?? ""
				songToWrite.artistName = song.artistName
				songToWrite.explicit = song.explicit
				songToWrite.id = song.id
				songToWrite.name = song.name
				songToWrite.previewURL = songPreviewURL
				songToWrite.liked = typeOfPassedSongs == DBSongTypes.liked
				songToWrite.recommended = typeOfPassedSongs == DBSongTypes.recommended

				realm.add(songToWrite)
				realmCommitWrite()
			}
		}
	}

	// MARK: Method for deleting all the song on App launch
	func purgeAllSongsInRealmOnLaunch(completion: @escaping ((Bool) -> Void)) {
		realm.beginWrite()

		realm.delete(realm.objects(SongObject.self))

		realmCommitWrite()

		completion(true)
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
