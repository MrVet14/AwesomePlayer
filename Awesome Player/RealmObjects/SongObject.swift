import Foundation
import RealmSwift

class SongObject: Object {
	@Persisted(primaryKey: true) var objectID: ObjectId

	@Persisted var albumName: String = ""
	@Persisted var albumCoverURL: String = ""
	@Persisted var artistName: String = ""
	@Persisted var explicit = false
	@Persisted var id: String = ""
	@Persisted var name: String = ""
	@Persisted var preview_url: String = ""
	@Persisted var liked = false
	@Persisted var recommended = false
}
