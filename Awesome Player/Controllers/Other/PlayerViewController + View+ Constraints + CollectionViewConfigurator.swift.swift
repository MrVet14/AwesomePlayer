import UIKit

// MARK: Configuring Collection View
extension PlayerViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	// MARK: Setting Number of Items in Section
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return listOfOtherSongsModel.count
	}

	// MARK: Configuring Cells in Collection View
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: ListOfSongsInPlayerCollectionViewCell.identifier,
			for: indexPath) as? ListOfSongsInPlayerCollectionViewCell
		else {
			return UICollectionViewCell()
		}

		let viewModel = listOfOtherSongsModel[indexPath.row]

		cell.configure(with: viewModel)

		return cell
	}

	// MARK: Adding Action on Tap on Cell
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		// It should be safe to force unwrap, cause it's manually declared
		tappedOnTheSongInListOfOtherSongs!(indexPath.row)
	}
}

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
			ListOfSongsInPlayerCollectionViewCell.self,
			forCellWithReuseIdentifier: ListOfSongsInPlayerCollectionViewCell.identifier
		)
		collectionView.dataSource = self
		collectionView.delegate = self
	}

	// MARK: Adding constraints to subviews
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
