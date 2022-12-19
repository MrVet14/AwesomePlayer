import Foundation
import RealmSwift

class SongObject: Object {
	@Persisted(primaryKey: true) var id: String = ""
	@Persisted var albumName: String = ""
	@Persisted var albumCoverURL: String = ""
	@Persisted var artistName: String = ""
	@Persisted var name: String = ""
	@Persisted var preview_url: String = ""
	@Persisted var explicit = false
	@Persisted var liked = false
	@Persisted var recommended = false
}
