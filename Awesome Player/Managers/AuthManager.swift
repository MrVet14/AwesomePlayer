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
                    try KeychainManager().setKey(
                        authKey: authKey,
                        service: "SpotifySDK",
                        account: "User"
                    )
                } catch {
                    print(error)
                }
            }
        }
    }
    func getAccessTokenOnLaunch() {
        var returnedToken = String()
        do {
            returnedToken = try KeychainManager().getKey(service: "SpotifySDK", account: "User")
            print(returnedToken)
        } catch {
            print(error)
        }
        accessToken = returnedToken
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
    func didTapSignOut() {
        if appRemote.isConnected {
            appRemote.disconnect()
        }
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

class KeychainManager {
    enum KeychainError: Error {
        // Attempted read for an item that does not exist.
        case itemNotFound
        // Attempted save to override an existing item.
        // Use update instead of save to update existing items
        case duplicateItem
        // A read of an item in any format other than Data
        case invalidItemFormat
        // Any operation result status than errSecSuccess
        case unexpectedStatus(OSStatus)
    }
    func setKey(authKey: Data, service: String, account: String) throws {
        print("Started setting Key")
        let query: [String: AnyObject] = [
            // attrs to identify item
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            // data to save
            kSecValueData as String: authKey as AnyObject
        ]
        // adding items to keychain
        let status = SecItemAdd(query as CFDictionary, nil)
        // it's a duplicate
        if status == errSecDuplicateItem {
            // updating key
            do {
                try self.updateKey(authKey: authKey, service: service, account: account)
            } catch {
                print(error)
            }
            throw KeychainError.duplicateItem
        }
        // trowing error if failed to save data
        guard status == errSecSuccess else {
            print("Error setting Key")
            throw KeychainError.unexpectedStatus(status)
        }
        print("Finished setting Key")
    }
    func getKey(service: String, account: String) throws -> String {
        print("Started getting Key")
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to read in Keychain
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword,
            // kSecMatchLimitOne indicates keychain should read
            // only the most recent item matching this query
            kSecMatchLimit as String: kSecMatchLimitOne,
            // kSecReturnData is set to kCFBooleanTrue in order
            // to retrieve the data for the item
            kSecReturnData as String: kCFBooleanTrue
        ]
        // SecItemCopyMatching will attempt to copy the item
        // identified by query to the reference itemCopy
        var itemCopy: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)
        // errSecItemNotFound is a special status indicating the
        // read item does not exist. Throw itemNotFound so the
        // client can determine whether or not to handle
        // this case
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        // Any status other than errSecSuccess indicates the
        // read operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        // This implementation of KeychainInterface requires all
        // items to be saved and read as Data. Otherwise,
        // invalidItemFormat is thrown
        guard let authKeyData = itemCopy as? Data else {
            throw KeychainError.invalidItemFormat
        }
        let authKey = String(decoding: authKeyData, as: UTF8.self)
        print("Finished getting Key")
        return authKey
    }
    func updateKey(authKey: Data, service: String, account: String) throws {
        print("Started updating Key")
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to update in Keychain
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]
        // attributes is passed to SecItemUpdate with
        // kSecValueData as the updated item value
        let attributes: [String: AnyObject] = [
            kSecValueData as String: authKey as AnyObject
        ]
        // SecItemUpdate attempts to update the item identified
        // by query, overriding the previous value
        let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        // errSecItemNotFound is a special status indicating the
        // item to update does not exist. Throw itemNotFound so
        // the client can determine whether or not to handle
        // this as an error
        guard status != errSecItemNotFound else {
            throw KeychainError.itemNotFound
        }
        // Any status other than errSecSuccess indicates the
        // update operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        print("Finished updating Key")
    }
    func deleteKey(service: String, account: String) throws {
        print("Started deleting Key")
        let query: [String: AnyObject] = [
            // kSecAttrService,  kSecAttrAccount, and kSecClass
            // uniquely identify the item to delete in Keychain
            kSecAttrService as String: service as AnyObject,
            kSecAttrAccount as String: account as AnyObject,
            kSecClass as String: kSecClassGenericPassword
        ]
        // SecItemDelete attempts to perform a delete operation
        // for the item identified by query. The status indicates
        // if the operation succeeded or failed.
        let status = SecItemDelete(query as CFDictionary)
        // Any status other than errSecSuccess indicates the
        // delete operation failed.
        guard status == errSecSuccess else {
            throw KeychainError.unexpectedStatus(status)
        }
        print("Finished deleting Key")
    }
}
