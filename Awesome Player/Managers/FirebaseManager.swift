import FirebaseFirestore
import Foundation

class FirebaseManager {
	static let shared = FirebaseManager()

	let dataBase = Firestore.firestore().collection("Users")
	var userID: String {
		var returnID = "UserID"

		DBManager.shared.getUserFromDB { result in
			returnID = result.id
		}

		return returnID
	}

	private init() {}

	func getData(completion: @escaping (([String]) -> Void)) {
		var songsIDsToReturn: [String] = []

		dataBase.document(userID).collection("LikedSongs").getDocuments { snapshot, error in
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

	func addLikedSongToFirebase(_ songID: String,
								completion: @escaping ((Bool) -> Void)
	) {
		dataBase.document(userID).collection("LikedSongs").document(songID).setData(["Song": true]) { error in
			if error == nil {
				completion(true)
			} else {
				print("Error adding liked song to Firestore: \(String(describing: error?.localizedDescription))")
				completion(false)
			}
		}
	}

	func deleteUnlikedSongFromFirebase(_ songID: String,
									   completion: @escaping ((Bool) -> Void)
	) {
		dataBase.document(userID).collection("LikedSongs").document(songID).delete { error in
			if error == nil {
				completion(true)
			} else {
				print("Error deleting disliked song in Firestore: \(String(describing: error?.localizedDescription))")
				completion(false)
			}
		}
	}
}
