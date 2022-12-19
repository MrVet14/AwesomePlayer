import Foundation
import RealmSwift

class UserObject: Object {
	@Persisted(primaryKey: true) var objectID: ObjectId

	@Persisted var country: String = ""
	@Persisted var display_name: String = ""
	@Persisted var email: String = ""
	@Persisted var id: String = ""
	@Persisted var imageURL: String = ""
}
