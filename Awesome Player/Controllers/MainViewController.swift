//
//  ViewController.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/9/22.
//
// 

import UIKit

class MainViewController: UIViewController {
    // MARK: - Subviews
    private lazy var connectLabel: UILabel = {
        let label = UILabel()
		label.text = "Connect your Spotify account".localized()
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
		label.textColor = UIColor(asset: Asset.spotifyGreen)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var connectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(asset: Asset.spotifyGreen)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
        button.layer.cornerRadius = 20.0
		button.setTitle("Continue with Spotify".localized(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.sizeToFit()
        button.addTarget(self, action: #selector(didTapConnect(_: )), for: .touchUpInside)
        return button
    }()

    private lazy var disconnectButton: UIButton = {
        let button = UIButton()
		button.backgroundColor = UIColor(asset: Asset.red)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
        button.layer.cornerRadius = 20.0
		button.setTitle("Disconnect".localized(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.sizeToFit()
        button.addTarget(self, action: #selector(didTapSignOut(_: )), for: .touchUpInside)
        return button
    }()

    // MARK: App Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    // MARK: Methods
    func setupViews() {
        view.backgroundColor = UIColor.white
        view.addSubview(connectLabel)
        view.addSubview(connectButton)
        view.addSubview(disconnectButton)
        let constant: CGFloat = 16.0
        connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        disconnectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        disconnectButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        connectLabel.centerXAnchor.constraint(equalTo: connectButton.centerXAnchor).isActive = true
        connectLabel.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: -constant).isActive = true
        connectButton.sizeToFit()
        disconnectButton.sizeToFit()
    }

    @objc
	func didTapConnect(
		_ button: UIButton
	) {
        AuthManager().didTapConnect()
    }

    @objc
	func didTapSignOut(_ button: UIButton) {
        AuthManager().didTapSignOut()
    }
}

extension String {
	func localized() -> String {
		return NSLocalizedString(
			self,
			tableName: "Localizable",
			bundle: .main,
			value: self,
			comment: self)
	}
}
