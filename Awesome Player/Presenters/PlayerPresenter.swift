import AVFoundation
import Foundation
import UIKit

class PlayerPresenter {
	static let shared = PlayerPresenter()

	private init() {}

	var player: AVPlayer?
	var playerVC = PlayerViewController.shared

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

		viewController.present(playerVC, animated: true)
	}

	func startPlayback() {
		guard let url = URL(string: currentSong.previewURL) else {
			print("Error creating URL for AVPlayer")
			return
		}
		player = AVPlayer(url: url)

		playerVC.songToDisplay = currentSong
		playerVC.configureView()

		player?.play()

		managePlayback()
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
		getCurrentIndexOfSongInArray { index in
			updateSongDataForPlayer(songIndexToLaunch: index - 1)
		}
	}

	func tappedNext() {
		getCurrentIndexOfSongInArray { index in
			updateSongDataForPlayer(songIndexToLaunch: index + 1)
		}
	}

	func updateSongDataForPlayer(songIndexToLaunch: Int) {
		var index = 0

		if songIndexToLaunch > listOfOtherSong.count - 1 {
			index = 0
		} else if songIndexToLaunch < 0 {
			index = listOfOtherSong.count - 1
		} else {
			index = songIndexToLaunch
		}

		currentSong = listOfOtherSong[index]
		startPlayback()
	}

	func getCurrentIndexOfSongInArray(completion: ((Int) -> Void)) {
		guard let songIndex = listOfOtherSong.firstIndex(of: currentSong) else {
			print("Error occurred, song element hasn't been found")
			return
		}
		completion(songIndex)
	}
}
