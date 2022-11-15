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
        label.text = "Connect your Spotify account"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(red: (29.0 / 255.0), green: (185.0 / 255.0), blue: (84.0 / 255.0), alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var connectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(red: (29.0 / 255.0), green: (185.0 / 255.0), blue: (84.0 / 255.0), alpha: 1.0)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentEdgeInsets = UIEdgeInsets(top: 11.75, left: 32.0, bottom: 11.75, right: 32.0)
        button.layer.cornerRadius = 20.0
        button.setTitle("Continue with Spotify", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        button.sizeToFit()
        button.addTarget(self, action: #selector(startAuth(_: )), for: .touchUpInside)
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
        let constant: CGFloat = 16.0
        connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        connectLabel.centerXAnchor.constraint(equalTo: connectButton.centerXAnchor).isActive = true
        connectLabel.bottomAnchor.constraint(equalTo: connectButton.topAnchor, constant: -constant).isActive = true
    }
    @objc func startAuth(_ button: UIButton) {
        AuthManager().didTapConnect()
    }
}
