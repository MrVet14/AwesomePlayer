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
