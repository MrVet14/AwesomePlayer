import AVFoundation
import Foundation
import UIKit

class PlayerPresenter {
	static let shared = PlayerPresenter()

	private init() {}

	var isPlayerActive = false

	var player: AVPlayer?
	var playerVC = PlayerViewController.shared

	var currentSong = SongObject()
	var listOfOtherSong: [SongObject] = []

	// MARK: Starting playback when user tapped on a song in a view
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

	// MARK: Creating Player and passing all the needed data to PlayerVC
	func startPlayback() {
		guard let url = URL(string: currentSong.previewURL) else {
			print("Error creating URL for AVPlayer")
			return
		}
		player = AVPlayer(url: url)

		playerVC.songToDisplay = currentSong
		playerVC.listOfOtherSongs = listOfOtherSong
		playerVC.configureView()

		player?.play()

		managePlayback()

		isPlayerActive = true
	}

	// MARK: Managing callbacks from PlayerVC
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

		playerVC.tappedOnTheSongInListOfOtherSongs = { [weak self] index in
			self?.updateSongDataForPlayer(songIndexToLaunch: index)
		}
	}

	// MARK: Switching song back
	func tappedBack() {
		getCurrentIndexOfASongInArray { index in
			updateSongDataForPlayer(songIndexToLaunch: index - 1)
		}
	}

	// MARK: Switching song forward
	func tappedNext() {
		getCurrentIndexOfASongInArray { index in
			updateSongDataForPlayer(songIndexToLaunch: index + 1)
		}
	}

	// MARK: Setting new song to play
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

	// MARK: Identifying index of current song
	func getCurrentIndexOfASongInArray(completion: ((Int) -> Void)) {
		guard let songIndex = listOfOtherSong.firstIndex(of: currentSong) else {
			print("Error occurred, song element hasn't been found")
			return
		}
		completion(songIndex)
	}
}
