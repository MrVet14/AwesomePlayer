import Foundation
import RealmSwift

class UserObject: Object {
	@Persisted(primaryKey: true) var id: String = ""
	@Persisted var country: String = ""
	@Persisted var display_name: String = ""
	@Persisted var email: String = ""
	@Persisted var imageURL: String = ""
}
