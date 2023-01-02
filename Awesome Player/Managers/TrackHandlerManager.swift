import Foundation

class TrackHandlerManager {
	static let shared = TrackHandlerManager()

	private init() {}

	func processLikeButtonTappedAction(
		id: String,
		liked: Bool,
		completion: @escaping (() -> Void)
	) {
		if liked {
			FirebaseManager.shared.deleteUnlikedSongFromFirebase(id) { success in
				if success {
					DBManager.shared.dislikedSong(id)
					completion()
				}
			}
		} else {
			FirebaseManager.shared.addLikedSongToFirebase(id) { success in
				if success {
					DBManager.shared.likedSong(id)
					completion()
				}
			}
		}
	}
}
