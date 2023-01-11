import Kingfisher
import SnapKit
import UIKit

class PlaylistHeaderCollectionReusableView: UICollectionReusableView {
	static let identifier = "PlaylistHeaderCollectionReusableView"

	// MARK: SubViews
	private let descriptionLabel: UILabel = {
		let label = UILabel()
		label.textColor = .secondaryLabel
		label.font = .systemFont(ofSize: 18, weight: .regular)
		label.numberOfLines = 3
		return label
	}()

	private let imageView: UIImageView = {
		let imageView = UIImageView()
		imageView.contentMode = .scaleAspectFit
		imageView.image = UIImage(systemName: "photo")
		return imageView
	}()

	// MARK: Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .systemBackground
		addSubview(imageView)
		addSubview(descriptionLabel)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Laying out constraints
	override func layoutSubviews() {
		super.layoutSubviews()

		imageView.snp.makeConstraints { make in
			make.height.equalTo(315)
			make.top.equalToSuperview().offset(15)
			make.leading.equalToSuperview().offset(40)
			make.trailing.equalToSuperview().offset(-40)
		}

		descriptionLabel.snp.makeConstraints { make in
			make.top.equalTo(imageView.snp.bottom).offset(10)
			make.leading.equalToSuperview().offset(25)
			make.trailing.equalToSuperview().offset(-25)
		}
	}

	// MARK: Configuring Header with Data
	func configure(with viewModel: PlaylistHeaderViewViewModel) {
		descriptionLabel.text = viewModel.description
		imageView.kf.setImage(with: URL(string: viewModel.artworkURL), options: [.transition(.fade(0.1))])
	}
}
