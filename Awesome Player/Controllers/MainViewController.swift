//
//  ViewController.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/9/22.
//
// swiftlint:disable all

import UIKit

//class MainViewController: UIViewController, SPTSessionManagerDelegate {
//    let spotifyClientID = "a02da930b4a64ab8a976ea8376eda362"
//    let spotifyRedirectURL = URL(string: "awesome-player://")!
//    let clientSecret = "dd4bc1311afa489b8c2e6f5ffe1298cf"
//
//    lazy var configuration = SPTConfiguration(
//      clientID: spotifyClientID,
//      redirectURL: spotifyRedirectURL
//    )
//
//    lazy var sessionManager: SPTSessionManager = {
//      if let tokenSwapURL = URL(string: "https://[my token swap app domain]/api/token"),
//         let tokenRefreshURL = URL(string: "https://[my token swap app domain]/api/refresh_token") {
//        self.configuration.tokenSwapURL = tokenSwapURL
//        self.configuration.tokenRefreshURL = tokenRefreshURL
//        self.configuration.playURI = ""
//      }
//      let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
//      return manager
//    }()
//
//    private lazy var connectButton = ConnectButton(title: "CONNECT")
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .cyan
//
//        view.addSubview(connectButton)
//
//        connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
//
//        connectButton.addTarget(self, action: #selector(didTapConnect(_:)), for: .touchUpInside)
//    }
//
//    @objc func didTapConnect(_ button: UIButton) {
//        print("connect tapped")
//        /*
//         Scopes let you specify exactly what types of data your application wants to
//         access, and the set of scopes you pass in your call determines what access
//         permissions the user is asked to grant.
//         For more information, see https://developer.spotify.com/web-api/using-scopes/.
//         */
//        let requestedScopes: SPTScope = [.appRemoteControl]
//        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
//    }
//
//    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
//        print("success", session)
//    }
//
//    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
//        print("fail", error)
//    }
//
//    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
//      print("renewed", session)
//    }
////
////    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
////      self.sessionManager.application(app, open: url, options: options)
////      return true
////    }
//}

class MainViewController: UIViewController, SPTSessionManagerDelegate {
    let spotifyClientID = "a02da930b4a64ab8a976ea8376eda362"
    let spotifyRedirectURL = URL(string: "awesome-player://")!
    let clientSecret = "dd4bc1311afa489b8c2e6f5ffe1298cf"
    var accessToken = ""

    lazy var configuration = SPTConfiguration(
      clientID: spotifyClientID,
      redirectURL: spotifyRedirectURL
    )

    lazy var sessionManager: SPTSessionManager = {
        print("Started session")
        if let tokenSwapURL = URL(string: "http://localhost:1234/swap/api/token"),
           let tokenRefreshURL = URL(string: "http://localhost:1234/swap/api/refresh_token") {
          self.configuration.tokenSwapURL = tokenSwapURL
          self.configuration.tokenRefreshURL = tokenRefreshURL
          self.configuration.playURI = ""
        }
        let manager = SPTSessionManager(configuration: self.configuration, delegate: self)
        print(manager)
        return manager
    }()

    // MARK: - UI

    private lazy var connectButton = ConnectButton(title: "CONNECT")

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .cyan

        view.addSubview(connectButton)

        connectButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        connectButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        connectButton.addTarget(self, action: #selector(didTapConnect(_:)), for: .touchUpInside)
    }

    // MARK: - Actions
    @objc func didTapConnect(_ button: UIButton) {
        print("connect tapped")
        /*
         Scopes let you specify exactly what types of data your application wants to
         access, and the set of scopes you pass in your call determines what access
         permissions the user is asked to grant.
         For more information, see https://developer.spotify.com/web-api/using-scopes/.
         */
        let requestedScopes: SPTScope = [.appRemoteControl]
        self.sessionManager.initiateSession(with: requestedScopes, options: .default)
    }

    // MARK: - SPTSessionManagerDelegate
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        print("Authorization Failed")
        presentAlertController(title: "Authorization Failed", message: error.localizedDescription, buttonTitle: "Bummer")
    }

    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("Session Renewed")
        presentAlertController(title: "Session Renewed", message: session.description, buttonTitle: "Sweet")
    }

    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
        print("didInitiate")
        print(session.accessToken)
    }

    func sessionManager(manager: SPTSessionManager, shouldRequestAccessTokenWith code: String) -> Bool {
        print("started something")
        return true
    }
    
    // MARK: - Private Helpers
    private func presentAlertController(title: String, message: String, buttonTitle: String) {
        DispatchQueue.main.async {
            let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
            controller.addAction(action)
            self.present(controller, animated: true)
        }
    }
}


class ConnectButton: UIButton {
    fileprivate let buttonBackgroundColor =
        UIColor(red:(29.0 / 255.0), green:(185.0 / 255.0), blue:(84.0 / 255.0), alpha:1.0)
    fileprivate let titleAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .heavy),
        .foregroundColor: UIColor.white,
        .kern: 2.0
    ]

    init(title: String) {
        super.init(frame: CGRect.zero)
        backgroundColor = buttonBackgroundColor
        layer.cornerRadius = 20.0
        translatesAutoresizingMaskIntoConstraints = false
        let title = NSAttributedString(string: title, attributes: titleAttributes)
        setAttributedTitle(title, for: .normal)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
