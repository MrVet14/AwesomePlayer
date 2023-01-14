import FirebaseFirestore
import Foundation

class FirebaseManager {
	static let shared = FirebaseManager()

	// MARK: Getting User ID to identify user in Firestore
	lazy var userID: String = {
		var returnID = "UserID"

		DBManager.shared.getUserFromDB { result in
			returnID = result.id
		}

		return returnID
	}()

	// MARK: Path to Firestore Data Base
	lazy var dataBase = Firestore.firestore().collection("Users").document(userID).collection("LikedSongs")

	private init() {}

	// MARK: Getting Liked Songs IDs form Firestore
	func getData(completion: @escaping (([String]) -> Void)) {
		var songsIDsToReturn: [String] = []

		dataBase.getDocuments { snapshot, error in
			if error == nil {
				if let snapshot = snapshot {
					for entry in snapshot.documents {
						songsIDsToReturn.append(entry.documentID)
					}
				}
			} else {
				print("Error retrieving data from Firestore: \(String(describing: error?.localizedDescription))")
			}

			completion(songsIDsToReturn)
		}
	}

	// MARK: Adding Liked Song ID to Firestore
	func addLikedSongToFirebase(
		_ songID: String,
		completion: @escaping ((Bool) -> Void)
	) {
		dataBase.document(songID).setData(["Song": true]) { error in
			if error != nil {
				print("Error adding liked song to Firestore: \(String(describing: error?.localizedDescription))")
			}
			completion(error == nil)
		}
	}

	// MARK: Removing Liked Song ID from Firestore
	func deleteUnlikedSongFromFirebase(
		_ songID: String,
		completion: @escaping ((Bool) -> Void)
	) {
		dataBase.document(songID).delete { error in
			if error != nil {
				print("Error deleting disliked song in Firestore: \(String(describing: error?.localizedDescription))")
			}
			completion(error == nil)
		}
	}
}
