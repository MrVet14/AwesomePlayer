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

	// MARK: Adding song to Realm
	func addSongsToDB(
		_ passedSongData: [Song],
		typeOfPassedSongs: String,
		playlistID: String
	) {
		// Adding parsed song from APICaller to Realm
		for song in passedSongData {
			// Checking if song has preview url, discarding entry if preview url not present
			guard let songPreviewURL = song.preview_url else {
				continue
			}

			// Checking if song we try to add already exists in realm
			if let existingSongObject = getSongObject(song.id) {
				do {
					try realm.write {
						// Checking if existing song associated with a playlist
						// If not, we're assigning it to one
						if existingSongObject.associatedPlaylists.isEmpty && !playlistID.isEmpty {
							existingSongObject.associatedPlaylists = playlistID
						} else if !existingSongObject.isInAPlaylist {
							// If existing song was recommended, we just add liked attribute
							if existingSongObject.recommended {
								existingSongObject.liked = true
							} // The opposite of comment above
							else if existingSongObject.liked {
								existingSongObject.recommended = true
							}
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
				songToWrite.isInAPlaylist = typeOfPassedSongs == DBSongTypes.inAPlaylist
				songToWrite.associatedPlaylists = playlistID

				realm.add(songToWrite)
				realmCommitWrite()
			}
		}
	}

	// MARK: Adding Featured Playlists to Realm
	func addFeaturedPlaylistsToRealm(_ playlists: FeaturedPlaylistsResponse) {
		for playlist in playlists.playlists.items {
			realm.beginWrite()

			let playlistToWrite = PlaylistObject()
			playlistToWrite.id = playlist.id
			playlistToWrite.playlistDescription = playlist.description
			playlistToWrite.name = playlist.name
			playlistToWrite.image = playlist.images.first?.url ?? ""
			playlistToWrite.numberOfTracks = playlist.tracks.total

			realm.add(playlistToWrite)
			realmCommitWrite()
		}
	}

	// MARK: Adding Playlist Songs to Realm,
	func addPlaylistSongsToRealm(_ playlist: PlaylistDetailsResponse) {
		let songFromPlaylistToSendToDB = playlist.tracks.items.compactMap {
			return $0.track
		}
		addSongsToDB(songFromPlaylistToSendToDB, typeOfPassedSongs: DBSongTypes.inAPlaylist, playlistID: playlist.id)
	}

	// MARK: Method for deleting all the song on App launch
	func purgeAllSongsAndPlaylistsInRealmOnLaunch(completion: @escaping ((Bool) -> Void)) {
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

	// MARK: Retrieving Featured Playlists from realm
	func getFeaturedPlaylistsFromDB(completion: @escaping (([PlaylistObject]) -> Void)) {
		let result = realm.objects(PlaylistObject.self)
		completion(Array(result))
	}

	// MARK: Retrieving Songs for a Playlist from realm
	func getSongsForAPlaylist(
		_ id: String,
		completion: @escaping (([SongObject]) -> Void)
	) {
		let results = realm.objects(SongObject.self).where { $0.associatedPlaylists == id }
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
