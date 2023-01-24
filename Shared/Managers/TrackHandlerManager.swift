import Foundation

class TrackHandlerManager {
	static let shared = TrackHandlerManager()

	private init() {}

	// MARK: Checking if passed song already Liked or not & acting accordingly
	// If liked removing from Firebase & Realm
	// If not liked, doing the exact opposite of comment above
	func processLikeButtonTappedAction(
		id: String,
		liked: Bool,
		completion: @escaping (() -> Void)
	) {
		if liked {
			FirebaseManager.shared.deleteUnlikedSongFromFirebase(id) { success in
				if success {
					DBManager.shared.dislikedASong(id)
					HapticsManager.shared.vibrate(for: .success)
					completion()
				}
			}
		} else {
			FirebaseManager.shared.addLikedSongToFirebase(id) { success in
				if success {
					DBManager.shared.likedASong(id)
					HapticsManager.shared.vibrate(for: .success)
					completion()
				}
			}
		}
	}
}
