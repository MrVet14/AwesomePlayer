import Foundation
import RealmSwift

extension DBManager {
	// MARK: Adding Featured Playlists to Realm
	func addFeaturedPlaylists(_ playlists: FeaturedPlaylistsResponse) {
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
	func addPlaylistsSongs(_ playlist: PlaylistDetailsResponse) {
		let songFromPlaylistToSendToDB = playlist.tracks.items.compactMap {
			return $0.track
		}
		addSongsToDB(songFromPlaylistToSendToDB, typeOfPassedSongs: DBSongTypes.inAPlaylist, playlistID: playlist.id)
	}

	// MARK: Retrieving Featured Playlists from realm
	func getFeaturedPlaylists(completion: @escaping (([PlaylistObject]) -> Void)) {
		let result = realm.objects(PlaylistObject.self)
		completion(Array(result))
	}

	// MARK: Getting playlist object to be easily used in methods & avoid repetition
	func getPlaylistObject(_ playlistID: String) -> PlaylistObject? {
		let result = realm.objects(PlaylistObject.self).where { $0.id == playlistID }
		return result.first
	}
}
