import UIKit

// MARK: Adding Subviews to View & Laying out Constraints
extension PlayerViewController {
	// MARK: Adding view elements to View & configuring them
	func setupViews() {
		view.addSubview(blurredBackground)

		view.addSubview(imageView)
		view.addSubview(songTitleLabel)
		view.addSubview(songArtistNameLabel)
		view.addSubview(explicitLabel)

		view.addSubview(playPauseButton)
		view.addSubview(backButton)
		view.addSubview(nextButton)
		view.addSubview(shareButton)
		view.addSubview(likeButton)

		view.addSubview(collectionView)

		collectionView.register(
			SongsListInPlayerCollectionViewCell.self,
			forCellWithReuseIdentifier: SongsListInPlayerCollectionViewCell.identifier
		)
		collectionView.dataSource = self
		collectionView.delegate = self
	}

	// MARK: Adding constraints to subviews
	// swiftlint:disable override_in_extension
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()

		blurredBackground.snp.makeConstraints { make in
			make.edges.equalToSuperview()
		}

		imageView.snp.makeConstraints { make in
			make.height.equalTo(370)
			make.top.equalToSuperview().offset(20)
			make.leading.equalToSuperview().offset(20)
			make.trailing.equalToSuperview().offset(-20)
		}

		songTitleLabel.snp.makeConstraints { make in
			make.top.equalTo(imageView.snp.bottom).offset(20)
			make.leading.equalToSuperview().offset(20)
			make.trailing.equalToSuperview().offset(-20)
		}

		songArtistNameLabel.snp.makeConstraints { make in
			make.top.equalTo(songTitleLabel.snp.bottom).offset(3)
			make.horizontalEdges.equalTo(songTitleLabel)
		}

		explicitLabel.snp.makeConstraints { make in
			make.top.equalTo(imageView.snp.bottom).offset(5)
			make.trailing.equalTo(imageView)
		}

		playPauseButton.snp.makeConstraints { make in
			make.centerX.equalToSuperview()
			make.top.equalTo(songArtistNameLabel.snp.bottom).offset(40)
		}

		backButton.snp.makeConstraints { make in
			make.top.equalTo(playPauseButton).offset(4)
			make.trailing.equalTo(playPauseButton.snp.leading).offset(-30)
		}

		nextButton.snp.makeConstraints { make in
			make.top.equalTo(playPauseButton).offset(4)
			make.leading.equalTo(playPauseButton.snp.trailing).offset(30)
		}

		shareButton.snp.makeConstraints { make in
			make.top.equalTo(playPauseButton)
			make.trailing.equalTo(backButton.snp.leading).offset(-30)
		}

		likeButton.snp.makeConstraints { make in
			make.top.equalTo(playPauseButton).offset(6)
			make.leading.equalTo(nextButton.snp.trailing).offset(30)
		}

		collectionView.snp.makeConstraints { make in
			make.top.equalTo(playPauseButton.snp.bottom).offset(40)
			make.leading.equalToSuperview().offset(20)
			make.trailing.bottom.equalToSuperview().offset(-20)
		}
	}
}
