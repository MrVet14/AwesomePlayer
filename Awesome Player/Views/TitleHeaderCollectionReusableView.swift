import UIKit

class TitleHeaderCollectionReusableView: UICollectionReusableView {
	static let identifier = "TitleHeaderCollectionReusableView"

	// MARK: Subviews
	private let label: UILabel = {
		let label = UILabel()
		label.textColor = .label
		label.numberOfLines = 1
		label.font = .systemFont(ofSize: 22, weight: .regular)
		return label
	}()

	// MARK: Init
	override init(frame: CGRect) {
		super.init(frame: frame)
		backgroundColor = .systemBackground
		addSubview(label)
	}

	// swiftlint:disable fatal_error
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	// MARK: Laying out constraints
	override func layoutSubviews() {
		super.layoutSubviews()
		label.frame = CGRect(x: 15, y: 0, width: width - 30, height: height)
	}

	// MARK: Configuring Header with Data
	func configure(with title: String) {
		label.text = title
	}
}
