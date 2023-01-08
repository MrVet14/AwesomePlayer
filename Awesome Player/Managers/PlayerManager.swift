import AVFoundation
import Foundation
import UIKit

class PlayerManager {
	static let shared = PlayerManager()

	private init() {}

	var player: AVPlayer?
	var playerVC = PlayerViewController()

	var currentSong = SongObject()
	var listOfOtherSong: [SongObject] = []

	func startPlaybackProcess(
		from viewController: UIViewController,
		listOfOtherSongsInView: [SongObject],
		song: SongObject
	) {
		currentSong = song
		listOfOtherSong = listOfOtherSongsInView

		startPlayback()
		managePlayback()

		viewController.present(playerVC, animated: true)
	}

	func startPlayback() {
		guard let url = URL(string: currentSong.previewURL) else {
			print("Error creating URL for AVPlayer")
			return
		}
		player = AVPlayer(url: url)

		playerVC = PlayerViewController()
		playerVC.songToDisplay = currentSong

		player?.play()
	}

	func managePlayback() {
		playerVC.didTapPlayPause = { [weak self] in
			if self?.playerVC.playerPlaying == true {
				self?.player?.pause()
			} else {
				self?.player?.play()
			}
		}

		playerVC.didTapBack = { [weak self] in
			self?.tappedBack()
		}

		playerVC.didTapNext = { [weak self] in
			self?.tappedNext()
		}
	}

	func tappedBack() {
		print("Did tap back")
	}

	func tappedNext() {
		print("Did tap next")
	}

	func passNewDataToPlayerVC() {
	}
}
