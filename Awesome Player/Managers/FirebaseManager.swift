import FirebaseFirestore
import Foundation

class FirebaseManager {
	static let shared = FirebaseManager()

	let dataBase = Firestore.firestore().collection("Users")

	private init() {}

	func getData(completion: @escaping (([String]) -> Void)) {
		var songsIDsToReturn: [String] = []

		dataBase.document(getUserID()).collection("LikedSongs").getDocuments { snapshot, error in
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

	func addLikedSongToFirebase(
		_ songID: String,
		completion: @escaping ((Bool) -> Void)
	) {
		dataBase.document(getUserID()).collection("LikedSongs").document(songID).setData(["Song": true]) { error in
			if error != nil {
				print("Error adding liked song to Firestore: \(String(describing: error?.localizedDescription))")
			}
			completion(error == nil)
		}
	}

	func deleteUnlikedSongFromFirebase(
		_ songID: String,
		completion: @escaping ((Bool) -> Void)
	) {
		dataBase.document(getUserID()).collection("LikedSongs").document(songID).delete { error in
			if error != nil {
				print("Error deleting disliked song in Firestore: \(String(describing: error?.localizedDescription))")
			}
			completion(error == nil)
		}
	}

	func getUserID() -> String {
		var returnID = "UserID"

		DBManager.shared.getUserFromDB { result in
			returnID = result.id
		}

		return returnID
	}
}
