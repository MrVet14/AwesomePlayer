//
//  AuthManager.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/10/22.
//

import Foundation

final class AuthManager: NSObject {
    var responseTypeCode: String? {
        didSet {
            fetchSpotifyToken { dictionary, error in
                if let error = error {
                    print("Fetching token request error \(error)")
                    return
                }
                // swiftlint:disable force_cast
                let accessToken = dictionary!["access_token"] as! String
                DispatchQueue.main.async {
                    self.appRemote.connectionParameters.accessToken = accessToken
                    self.appRemote.connect()
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
    var accessToken = UserDefaults.standard.string(forKey: accessTokenKey) {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(accessToken, forKey: accessTokenKey)
        }
    }
    lazy var configuration: SPTConfiguration = {
        let configuration = SPTConfiguration(clientID: spotifyClientId, redirectURL: redirectUri)
        configuration.playURI = ""
        configuration.tokenSwapURL = URL(string: "http://localhost:1234/swap")
        configuration.tokenRefreshURL = URL(string: "http://localhost:1234/refresh")
        return configuration
    }()
    lazy var sessionManager: SPTSessionManager? = {
        let manager = SPTSessionManager(configuration: configuration, delegate: self)
        return manager
    }()
    func didTapConnect() {
        guard let sessionManager = sessionManager else { return }
        sessionManager.initiateSession(with: scopes, options: .clientOnly)
    }
    // MARK: POST Request
    /// fetch Spotify access token. Use after getting responseTypeCode
    func fetchSpotifyToken(completion: @escaping ([String: Any]?, Error?) -> Void) {
        let url = URL(string: "https://accounts.spotify.com/api/token")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // swiftlint:disable line_length
        let spotifyAuthKey = "Basic \((spotifyClientId + ":" + spotifyClientSecretKey).data(using: .utf8)!.base64EncodedString())"
        request.allHTTPHeaderFields = ["Authorization": spotifyAuthKey, "Content-Type": "application/x-www-form-urlencoded"]
        var requestBodyComponents = URLComponents()
        let scopeAsString = stringScopes.joined(separator: " ")
        requestBodyComponents.queryItems = [URLQueryItem(name: "client_id", value: spotifyClientId), URLQueryItem(name: "grant_type", value: "authorization_code"), URLQueryItem(name: "code", value: responseTypeCode!), URLQueryItem(name: "redirect_uri", value: redirectUri.absoluteString), URLQueryItem(name: "scope", value: scopeAsString)]
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
            print("---access_token:", responseObject?["access_token"] ?? "")
            print("---refresh_token:", responseObject?["refresh_token"] ?? "")
            completion(responseObject, nil)
        }
        task.resume()
    }
}
// MARK: - SPTAppRemoteDelegate
extension AuthManager: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
    }
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
    }
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
    }
}
// MARK: - SPTSessionManagerDelegate
extension AuthManager: SPTSessionManagerDelegate {
    func sessionManager(manager: SPTSessionManager, didFailWith error: Error) {
        if error.localizedDescription == "The operation couldn’t be completed. (com.spotify.sdk.login error 1.)" {
            print("AUTHENTICATE with WEBAPI")
        } else {
            print("Authorization Failed")
        }
    }
    func sessionManager(manager: SPTSessionManager, didRenew session: SPTSession) {
        print("Session Renewed")
    }
    func sessionManager(manager: SPTSessionManager, didInitiate session: SPTSession) {
    }
}
