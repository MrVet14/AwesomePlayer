import Foundation
import RealmSwift

extension DBManager {
	func markSongsAsLiked(ids: [String]) {
		for id in ids {
			DBManager.shared.likedSong(id)
		}
	}
}
