import AVFoundation
import Foundation
import UIKit

class PlayerManager {
	static let shared = PlayerManager()

	private init() {}

	func startPlayback(
		from viewController: UIViewController,
		song: SongObject
	) {
		let playerVC = PlayerViewController()
		playerVC.songToDisplay = song
		viewController.present(playerVC, animated: true, completion: nil)
	}
}
