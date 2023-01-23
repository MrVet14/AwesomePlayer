import UIKit

// MARK: Configuring Collection View
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	// MARK: Registering Collection View Cells that we intend to use
	func registeringCollectionViewCells() {
		collectionView.register(
			UICollectionViewCell.self,
			forCellWithReuseIdentifier: "cell"
		)
		collectionView.register(
			SongCollectionViewCell.self,
			forCellWithReuseIdentifier: SongCollectionViewCell.identifier
		)
		collectionView.register(
			TitleHeaderCollectionReusableView.self,
			forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
			withReuseIdentifier: TitleHeaderCollectionReusableView.identifier
		)
	}

	// MARK: Setting Number of Items in Section
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		switch sections.first {
		case .recommendedSongs(let viewModels):
			return viewModels.count

		case .none:
			return 0
		}
	}

	// MARK: Configuring Cells in Collection View
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		switch sections.first {
		case .recommendedSongs(let viewModels):
			guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: SongCollectionViewCell.identifier,
				for: indexPath) as? SongCollectionViewCell
			else {
				return UICollectionViewCell()
			}

			let viewModel = viewModels[indexPath.row]

			cell.configure(with: viewModel)
			cell.likeButtonTapAction = { [weak self] in
				self?.processLikeButtonTappedAction(id: viewModel.id, liked: viewModel.liked)
			}

			return cell

		case .none:
			return UICollectionViewCell()
		}
	}

	// MARK: Adding Action on Tap on Cell
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		HapticsManager.shared.vibrateForSelection()

		let song = recommendedSongs[indexPath.row]
		PlayerPresenter.shared.startPlaybackProcess(from: self, listOfOtherSongsInView: recommendedSongs, song: song)
	}

	// MARK: Creating Headers for the Sections
	func collectionView
	(_ collectionView: UICollectionView,
	 viewForSupplementaryElementOfKind kind: String,
	 at indexPath: IndexPath
	) -> UICollectionReusableView {
		guard let header = collectionView.dequeueReusableSupplementaryView(
			ofKind: kind,
			withReuseIdentifier: TitleHeaderCollectionReusableView.identifier,
			for: indexPath
		) as? TitleHeaderCollectionReusableView, kind == UICollectionView.elementKindSectionHeader else {
			return UICollectionReusableView()
		}

		header.configure(with: L10n.recommendedSongs)

		return header
	}

	// MARK: Creating Section Layout for Collection View
	func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
		// MARK: Recommended Songs Section
		// Section Header
		let supplementaryViews = [
			NSCollectionLayoutBoundarySupplementaryItem(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1),
					heightDimension: .absolute(50)
				),
				elementKind: UICollectionView.elementKindSectionHeader,
				alignment: .top
			)
		]

		// Item
		let item = NSCollectionLayoutItem(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .fractionalHeight(1.0))
		)
		item.contentInsets = NSDirectionalEdgeInsets(top: 2, leading: 2, bottom: 2, trailing: 2)

		// Group
		let group = NSCollectionLayoutGroup.vertical(
			layoutSize: NSCollectionLayoutSize(
				widthDimension: .fractionalWidth(1.0),
				heightDimension: .absolute(80)
			),
			subitem: item,
			count: 1
		)

		// Section
		let section = NSCollectionLayoutSection(group: group)
		section.boundarySupplementaryItems = supplementaryViews
		return section
	}
}
