//
//  AuthManager.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/10/22.
//

import Foundation

final class AuthManager: NSObject {
	let spotifyClientId = PlistReaderManager().returnString(PlistBundleParameters.spotifyClientId)
	let spotifyClientSecretKey = PlistReaderManager().returnString(PlistBundleParameters.spotifyClientSecretKey)
	let redirectUri = PlistReaderManager().returnURL(PlistBundleParameters.redirectUri)

    var responseTypeCode: String? {
        didSet {
            fetchSpotifyToken { dictionary, error in
                if let error = error {
                    print("Fetching token request error \(error)")
                    return
                }
				guard let accessToken = dictionary!["access_token"] as? String else {
					print("error unwrapping access token")
					return
				}
                DispatchQueue.main.async {
                    self.appRemote.connectionParameters.accessToken = accessToken
                    self.appRemote.connect()
                    self.accessToken = accessToken
                }
            }
        }
    }

    lazy var appRemote: SPTAppRemote = {
        let appRemote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        appRemote.connectionParameters.accessToken = self.accessToken
        appRemote.delegate = self
        return appRemote
    }()

    var accessToken = "" {
        didSet {
            if let authKey = accessToken.data(using: .utf8) {
                do {
                    try KeychainManager().setKey(authKey: authKey)
                } catch {
                    print(error)
                }
            }
        }
    }

    func getAccessTokenOnLaunch() {
        var returnedToken = String()
        do {
            returnedToken = try KeychainManager().getKey()
            print(returnedToken)
        } catch {
            print(error)
        }
        accessToken = returnedToken
    }

    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: spotifyClientId, redirectURL: redirectUri)
        configuration.playURI = ""
		configuration.tokenSwapURL = PlistReaderManager().returnURL(PlistBundleParameters.tokenSwapURL)
		configuration.tokenRefreshURL = PlistReaderManager().returnURL(PlistBundleParameters.tokenRefreshURL)
        return configuration
    }()

    lazy var sessionManager: SPTSessionManager? = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()

    func didTapConnect() {
        guard let sessionManager = sessionManager else { return }
		let scopes: SPTScope = [.userReadEmail]
        sessionManager.initiateSession(with: scopes, options: .clientOnly)
    }

    func didTapSignOut() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
    }

    // MARK: POST Request
    /// fetch Spotify access token. Use after getting responseTypeCode
    func fetchSpotifyToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
		let url = PlistReaderManager().returnURL(PlistBundleParameters.spotifyAPITokenURL)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
		let spotifyAuthKeyPreString = "\(spotifyClientId):\(spotifyClientSecretKey)"
		let spotifyAuthKey = "Basic \(spotifyAuthKeyPreString.data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = [
			"Authorization": spotifyAuthKey,
			"Content-Type": "application/x-www-form-urlencoded"
		]
        var requestBodyComponents = URLComponents()
		let stringScopes = ["user-read-email"]
        let scopeAsString = stringScopes.joined(separator: " ")
        requestBodyComponents.queryItems = [
			URLQueryItem(
				name: "client_id",
				value: spotifyClientId
			),
			URLQueryItem(
				name: "grant_type",
				value: "authorization_code"
			),
			URLQueryItem(
				name: "code",
				value: responseTypeCode!
			),
			URLQueryItem(
				name: "redirect_uri",
				value: redirectUri.absoluteString
			),
			URLQueryItem(
				name: "scope",
				value: scopeAsString
			)
		]
        request.httpBody = requestBodyComponents.query?.data(using: .utf8)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse,
                  (200 ..< 300) ~= response.statusCode,
                  error == nil else {
                print("Error fetching token \(error?.localizedDescription ?? "")")
                return completion(nil, error)
            }
            let responseObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            print(responseObject!)
//            print("---access_token:", responseObject?["access_token"] ?? "")
//            print("---refresh_token:", responseObject?["refresh_token"] ?? "")
            completion(responseObject, nil)
        }
        task.resume()
    }
}

// MARK: - SPTAppRemoteDelegate
extension AuthManager: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
    }

    func appRemote(
		_ appRemote: SPTAppRemote,
		didDisconnectWithError error: Error?
	) {
    }

    func appRemote(
		_ appRemote: SPTAppRemote,
		didFailConnectionAttemptWithError error: Error?
	) {
    }
}

// MARK: - SPTSessionManagerDelegate
extension AuthManager: SPTSessionManagerDelegate {
    func sessionManager(
		manager: SPTSessionManager,
		didFailWith error: Error
	) {
        if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
            print("AUTHENTICATE with WEBAPI")
        } else {
            print("Authorization Failed")
        }
    }

    func sessionManager(
		manager: SPTSessionManager,
		didRenew session: SPTSession
	) {
        print("Session Renewed")
    }

    func sessionManager(
		manager: SPTSessionManager,
		didInitiate session: SPTSession
	) {
    }
}
