import FirebaseFirestore
import Foundation

class FirebaseManager {
	static let shared = FirebaseManager()

	let dataBase = Firestore.firestore()

	private init() {}

	func getData(completion: (([String]) -> Void)) {
		// Getting list of liked songs IDs from Firebase
	}

	func addLikedSongToFirebase(_ id: String, completion: ((Bool) -> Void)) {
		// Adding liked item to Firebase
	}

	func deleteUnlikedSongFromFirebase(_ id: String, completion: ((Bool) -> Void)) {
		// Removing unliked item from Firebase
	}
}
