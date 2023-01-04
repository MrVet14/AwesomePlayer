import Foundation
import RealmSwift

class PlaylistObject: Object {
	@Persisted(primaryKey: true) var id: String = ""
	@Persisted var playlistDescription: String = ""
	@Persisted var name: String = ""
	@Persisted var image: String = ""
	@Persisted var numberOfTracks: Int = 0
}
