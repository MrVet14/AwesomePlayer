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
	var playerPlaying = true

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

		playerPlaying = true

		playerVC.songToDisplay = currentSong
		playerVC.listOfOtherSongs = listOfOtherSong
		playerVC.playerPlaying = playerPlaying
		playerVC.configureView()

		playerBar.songToDisplay = currentSong
		playerBar.playerPlaying = playerPlaying
		playerBar.configureView()

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

		HapticsManager.shared.vibrateForSelection()

		if player.timeControlStatus == .playing {
			playerPlaying = false
			player.pause()
		} else if player.timeControlStatus == .paused {
			playerPlaying = true
			player.play()
		}

		updatePlayPauseButtonView()
	}

	// MARK: Passing new data into dependent Views and Updating Them
	func updatePlayPauseButtonView() {
		playerVC.playerPlaying = playerPlaying
		playerVC.configureView()

		playerBar.playerPlaying = playerPlaying
		playerBar.configureView()
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
		HapticsManager.shared.vibrateForSelection()

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
	func getCurrentIndexOfASongInArray() -> Int {
		guard let songIndex = listOfOtherSong.firstIndex(of: currentSong) else {
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
