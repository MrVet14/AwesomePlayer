import Foundation
import RealmSwift

class DBManager {
	static let shared = DBManager()

	private init() {}

	// MARK: Openning Realm
	// swiftlint:disable force_try
	let realm = try! Realm()

	// MARK: Adding user data to Realm
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

	// MARK: Adding song to Realm, can be used for Recommended & Liked songs
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

		/// Adding parsed song from APICaller to Realm
		for song in passedSongData {
			/// Checking if song has preview url, discarding entry if preview url not present
			guard let songPreviewURL = song.preview_url else {
				continue
			}

			// If song already in Realm, we just change one of the attributes
			if alreadyExistingSongs.contains(song.id) {
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

	// MARK: Adding playlist to Realm,
	func addPlaylistToRealm(_ playlist: PlaylistDetailsResponse) {
		realm.beginWrite()

		let playListToWrite = PlaylistObject()
		playListToWrite.id = playlist.id
		playListToWrite.playlistDescription = playlist.description
		playListToWrite.name = playlist.name
		playListToWrite.image = playlist.images.first?.url ?? ""
		playListToWrite.numberOfTracks = playlist.tracks.items.count

		realm.add(playListToWrite)
		realmCommitWrite()
	}

	// MARK: Method for deleting all the song on App launch
	func purgeAllSongsAndAlbumsInRealmOnLaunch(completion: @escaping ((Bool) -> Void)) {
		realm.beginWrite()

		realm.delete(realm.objects(PlaylistObject.self))
		realm.delete(realm.objects(SongObject.self))

		realmCommitWrite()

		completion(true)
	}

	// MARK: Retrieving Recommended songs from realm
	func getRecommendedSongsFromDB(completion: @escaping (([SongObject]) -> Void)) {
		let results = realm.objects(SongObject.self).where { $0.recommended == true }
		completion(Array(results))
	}

	// MARK: Retrieving Liked songs from realm
	func getLikedSongsFromDB(completion: @escaping (([SongObject]) -> Void)) {
		let results = realm.objects(SongObject.self).where { $0.liked == true }
		completion(Array(results))
	}

	// MARK: Retrieving Playlists songs from realm
	func getPlaylistsFormDB(completion: @escaping (([PlaylistObject]) -> Void)) {
		let results = realm.objects(PlaylistObject.self)
		completion(Array(results))
	}

	// MARK: Marking song as liked
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

	// MARK: Removing song from liked
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

	// MARK: Getting song object to be easily used in methods & avoid repetition
	func getSongObject(_ songID: String) -> SongObject? {
		let result = realm.objects(SongObject.self).where { $0.id == songID }
		return result.first
	}

	// MARK: Getting playlist object to be easily used in methods & avoid repetition
	func getPlaylistObject(_ playlistID: String) -> PlaylistObject? {
		let result = realm.objects(PlaylistObject.self).where { $0.id == playlistID }
		return result.first
	}

	// MARK: Method for committing write to Realm
	func realmCommitWrite() {
		do {
			try realm.commitWrite()
		} catch {
			print(error.localizedDescription)
		}
	}
}
