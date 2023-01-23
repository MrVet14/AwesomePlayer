import Foundation
import RealmSwift
// swiftlint:disable all
extension DBManager {
	func markSongsAsMarked(ids: [String]) {
		for id in ids {
			DBManager.shared.likedSong(id)
		}
	}
}
