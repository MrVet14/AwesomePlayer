import UIKit

// MARK: Configuring Collection View
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource {
	// MARK: Setting Number of Items in Section
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let type = sections[section]
		switch type {
		case .featuredPlaylists(let viewModels):
			return viewModels.count

		case .recommendedSongs(let viewModels):
			return viewModels.count
		}
	}

	// MARK: Setting Number of Sections to Display
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return sections.count
	}

	// MARK: Configuring Cells in Collection View
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let type = sections[indexPath.section]
		switch type {
		case .featuredPlaylists(let viewModels):
			guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: PlaylistCollectionViewCell.identifier,
				for: indexPath) as? PlaylistCollectionViewCell
			else {
				return UICollectionViewCell()
			}
			let viewModel = viewModels[indexPath.row]

			cell.configure(with: viewModel)

			return cell

		case .recommendedSongs(let viewModels):
			guard let cell = collectionView.dequeueReusableCell(
				withReuseIdentifier: SongCollectionViewCell.identifier,
				for: indexPath) as? SongCollectionViewCell
			else {
				return UICollectionViewCell()
			}

			let viewModel = viewModels[indexPath.row]

			cell.configure(with: viewModel)
			cell.likeButtonTapAction = {
				[weak self] () in
				self?.processLikeButtonTappedAction(id: viewModel.id, liked: viewModel.liked)
			}

			return cell
		}
	}

	// MARK: Adding Action on Tap on Cell
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		collectionView.deselectItem(at: indexPath, animated: true)
		let section = sections[indexPath.section]
		switch section {
		case .featuredPlaylists:
			let playlist = featuredPlaylists[indexPath.row]
			let playlistVC = PlaylistViewController()
			playlistVC.alreadyLoaded = alreadyLoadedPlaylists.contains(playlist.id)
			playlistVC.playlist = playlist
			playlistVC.navigationItem.largeTitleDisplayMode = .never
			navigationController?.pushViewController(playlistVC, animated: true)
			playlistVC.hasBeenLoaded = {
				[weak self] in
				self?.alreadyLoadedPlaylists.append(playlist.id)
			}

		case .recommendedSongs:
			let song = recommendedSongs[indexPath.row]
			print("Recommended song with id: \(song.id) has been tapped")
		}
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
		let section = indexPath.section

		let title = sections[section].title
		header.configure(with: title)

		return header
	}

	// MARK: Creating Section Layout for Collection View
	static func createSectionLayout(section: Int) -> NSCollectionLayoutSection {
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

		switch section {
		// Liked Songs Section
		case 0:
			// Group
			let verticalGroup = NSCollectionLayoutGroup.vertical(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(1.0),
					heightDimension: .absolute(390)
				),
				subitem: item,
				count: 3
			)
			let horizontalGroup = NSCollectionLayoutGroup.horizontal(
				layoutSize: NSCollectionLayoutSize(
					widthDimension: .fractionalWidth(0.9),
					heightDimension: .absolute(390)
				),
				subitem: verticalGroup,
				count: 1
			)

			// Section
			let section = NSCollectionLayoutSection(group: horizontalGroup)
			section.orthogonalScrollingBehavior = .groupPaging
			section.boundarySupplementaryItems = supplementaryViews
			return section

		// Recommended Songs Section
		default:
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
}
