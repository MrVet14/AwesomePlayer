import Foundation
import RealmSwift

class SongObject: Object {
	@objc dynamic var albumName: String = ""
	@objc dynamic var albumCoverURL: String = ""
	@objc dynamic var artistName: String = ""
	@objc dynamic var explicit = false
	@objc dynamic var id: String = ""
	@objc dynamic var name: String = ""
	@objc dynamic var preview_url: String = ""
	@objc dynamic var liked = false
	@objc dynamic var recommended = false
}
