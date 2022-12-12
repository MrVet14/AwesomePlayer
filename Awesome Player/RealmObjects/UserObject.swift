import Foundation
import RealmSwift

class UserObject: Object {
	@objc dynamic var country: String = ""
	@objc dynamic var display_name: String = ""
	@objc dynamic var email: String = ""
	@objc dynamic var id: String = ""
	@objc dynamic var imageURL: String = ""
}
