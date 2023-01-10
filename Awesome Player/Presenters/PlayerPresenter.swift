import AVFoundation
import Foundation
import UIKit

class PlayerPresenter {
	static let shared = PlayerPresenter()

	private init() {}

	var isPlayerBarActive = false

	var player: AVPlayer?
	let playerVC = PlayerViewController.shared
	let playerBar = PlayerBarAboveAllViewsView.shared

	var playerPlaying = true {
		didSet {
			playerVC.playerPlaying = playerPlaying
			playerBar.playerPlaying = playerPlaying
		}
	}

	var currentSong = SongObject()

	// MARK: Starting playback when user tapped on a song in a view
	func startPlaybackProcess(
		from viewController: UIViewController,
		listOfOtherSongsInView: [SongObject],
		song: SongObject
	) {
		currentSong = song
		playerVC.listOfOtherSong = listOfOtherSongsInView

		if !isPlayerBarActive {
			NotificationCenter.default.post(name: Notification.Name(NotificationCenterConstants.playerBar), object: nil)
			isPlayerBarActive = true
		}

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
		playerBar.songToDisplay = currentSong

		playerPlaying = true

		player?.play()

		managePlayback()
	}

	// MARK: Managing callbacks from PlayerVC
	func managePlayback() {
		playerBar.didTapPlayPause = { [weak self] in
			self?.playPause()
		}
	}

	// MARK: Resuming or Pausing Playback based on the current state of playback
	func playPause() {
		guard let player = self.player else {
			return
		}

		switch player.timeControlStatus {
		case .playing:
			playerPlaying = false
			player.pause()

		case .paused:
			playerPlaying = true
			player.play()

		default:
			playerPlaying = false
			player.pause()
		}
	}

	// MARK: Switching song back
	func tappedBack() {
		updateSongDataForPlayer(
			songIndexToLaunch: getCurrentIndexOfASongInArray() - 1
		)
	}

	// MARK: Switching song forward
	func tappedNext() {
		updateSongDataForPlayer(
			songIndexToLaunch: getCurrentIndexOfASongInArray() + 1
		)
	}

	// MARK: Setting new song to play
	func updateSongDataForPlayer(songIndexToLaunch: Int) {
		var index = 0

		if songIndexToLaunch > playerVC.listOfOtherSong.count - 1 {
			index = 0
		} else if songIndexToLaunch < 0 {
			index = playerVC.listOfOtherSong.count - 1
		} else {
			index = songIndexToLaunch
		}

		currentSong = playerVC.listOfOtherSong[index]
		startPlayback()
	}

	// MARK: Identifying index of current song
	func getCurrentIndexOfASongInArray() -> Int {
		guard let songIndex = playerVC.listOfOtherSong.firstIndex(of: currentSong) else {
			print("Error occurred, song element hasn't been found")
			return 0
		}
		return songIndex
	}
}

// MARK: Managing Controls in PlayerVC
extension PlayerPresenter: PlayerControlsDelegate {
	func didTapPlayPause() {
		playPause()
	}

	func didTapBack() {
		tappedBack()
	}

	func didTapNext() {
		tappedNext()
	}

	func tappedOnTheSongInListOfOtherSongs(songIndex: Int) {
		updateSongDataForPlayer(songIndexToLaunch: songIndex)
	}
}
