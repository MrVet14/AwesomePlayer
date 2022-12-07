import Foundation
import Moya

class AuthManager {
	static let shared = AuthManager()

	// MARK: Setting for AuthManager
	let vars = AuthManagerVariablesParser.shared.parse()

	// MARK: provider for Moya
	let provider = MoyaProvider<SpotifyAccessToken>()

	var refreshingToken = false
	var updatingForAPICall = false

	private init() {}

	// MARK: all the required variables for AuthManager

	/// creating sign in url with all the needed attributes
	var signInURL: URL? {
		let base = vars.spotifyAuthBaseURL
		let clientIdString = "client_id=\(vars.clientID)"
		let scopesString = "scope=\(vars.scopes)"
		let redirectURIString = "redirect_uri=\(vars.redirectURI)"
		let showDialogString = "show_dialog=TRUE"
		let string = "\(base)?response_type=code&\(clientIdString)&\(scopesString)&\(redirectURIString)&\(showDialogString)"
		return URL(string: string)
	}

	var isSignedIn: Bool {
		return accessToken != nil
	}

	private var accessToken: String? {
		return getDataFromKeychainAndUnwrapIt(TypesOfDataForKeychain.accessToken)
	}

	private var refreshToken: String? {
		return getDataFromKeychainAndUnwrapIt(TypesOfDataForKeychain.refreshToken)
	}

	private var tokenExpirationDate: Date? {
		return UserDefaults.standard.object(forKey: "expirationDate") as? Date
	}

	// MARK: checking if access token should be updated
	private var shouldRefreshToken: Bool {
		guard let expirationDate = tokenExpirationDate else {
			return false
		}
		let currentDate = Date()
		let fiveMinutes: TimeInterval = 300
		return currentDate.addingTimeInterval(fiveMinutes) >= expirationDate
	}

	// MARK: exchanging code for access token
	func exchangeCodeForToken(
		code: String,
		completion: @escaping ((Bool) -> Void)
	) {
		provider.request(.get(code: code)) { [weak self] result in
			completion((self?.handleResult(result, actionType: "getting"))!)
		}
	}

	// MARK: refreshing token of needed
	func refreshIfNeeded(completion: @escaping ((Bool) -> Void)) {
		guard !refreshingToken else {
			return
		}

		guard shouldRefreshToken else {
			completion(true)
			return
		}

		guard let refreshToken = self.refreshToken else {
			return
		}

		refreshingToken = true

		provider.request(.refresh(refreshToken: refreshToken)) { [weak self] result in
			completion((self?.handleResult(result, actionType: "refresh"))!)
			self?.refreshingToken = false
		}
	}

	// MARK: handling POST result from exchanging of refreshing token
	func handleResult(
		_ result: Result<Moya.Response, Moya.MoyaError>,
		actionType: String
	) -> Bool {
		switch result {
		case .success(let response):
			do {
				let result = try JSONDecoder().decode(AuthResponse.self, from: response.data)
				if actionType == "refresh" && updatingForAPICall == true {
					self.onRefreshBlocks.forEach { $0(result.access_token) }
					self.onRefreshBlocks.removeAll()
				}
				self.cacheToken(result: result)
				return true
			} catch {
				print(error)
				return false
			}

		case .failure(let error):
			if actionType == "refresh" {
				print("Failure while refreshing access token")
			} else {
				print("Failure while getting access token")
			}
			print(error)
			return false
		}
	}

	// MARK: caching access, refresh tokens & also saving expiration date
	func cacheToken(result: AuthResponse) {
		do {
			/// saving data on sign in
			if result.refresh_token != nil {
				if let accessToken = result.access_token.data(using: .utf8) {
					try saveData(TypesOfDataForKeychain.accessToken, accessToken)
				}
				if let refreshToken = result.refresh_token!.data(using: .utf8) {
					try saveData(TypesOfDataForKeychain.refreshToken, refreshToken)
				}
			} else {
				/// Updating Access Token
				if let accessToken = result.access_token.data(using: .utf8) {
					try updateData(TypesOfDataForKeychain.accessToken, accessToken)
				}
			}
		} catch {
			print(error)
		}
		/// Saving expiration data
		UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expires_in)), forKey: "expirationDate")
	}

	private var onRefreshBlocks = [((String) -> Void)]()

	func validToken(completion: @escaping (String) -> Void) {
		guard !refreshingToken else {
			/// Append the completion
			onRefreshBlocks.append(completion)
			return
		}

		updatingForAPICall = true

		if shouldRefreshToken {
			/// refreshing token
			refreshIfNeeded { [weak self] success in
				if let token = self?.accessToken, success {
					completion(token)
					self?.updatingForAPICall = false
				}
			}
		} else {
			if let token = accessToken {
				completion(token)
				updatingForAPICall = false
			}
		}
	}

	// MARK: signing out
	func signOut(completion: (Bool) -> Void) {
		do {
			try deleteData(TypesOfDataForKeychain.accessToken)
			try deleteData(TypesOfDataForKeychain.refreshToken)
		} catch {
			print(error)
			completion(false)
		}

		UserDefaults.standard.setValue(nil, forKey: "expirationDate")

		completion(true)
	}

	// MARK: getting data from keychain & unwrapping it
	func getDataFromKeychainAndUnwrapIt(_ dataToGet: String) -> String? {
		var returnData: String?

		do {
			returnData = try getData(dataToGet)
		} catch {
			print(error)
		}

		guard returnData != nil else {
			return nil
		}

		return returnData
	}

	// MARK: This implementation of KeychainInterface requires all items to be saved and read as Data.
	// Otherwise, invalidItemFormat is thrown

	/// initial shared query of parameter used by keychain methods below
	var query: [String: Any] = [
		/// kSecAttrService,  kSecAttrAccount, and kSecClass uniquely identify the item in Keychain
		kSecAttrAccount as String: KeyChainParameters.account as AnyObject,
		kSecClass as String: kSecClassGenericPassword
	]

	// MARK: method to save our data to Keychain
	func saveData(_ whatToSave: String, _ value: Data) throws {
		var query = self.query
		/// type of added data
		query[kSecAttrService as String] = whatToSave as AnyObject
		/// the value of data
		query[kSecValueData as String] = value as AnyObject

		/// adding items to keychain
		let status = SecItemAdd(query as CFDictionary, nil)
		/// trowing error if failed to save data
		if status == errSecDuplicateItem {
			// updating key
			do {
				try self.updateData(whatToSave, value)
			} catch {
				print(error)
			}
			throw KeychainError.duplicateItem
		}
		guard status == errSecSuccess else {
			print("Error saving Data")
			throw KeychainError.unexpectedStatus(status)
		}
	}

	// MARK: method to get our data from Keychain
	func getData(_ whatToGet: String) throws -> String {
		var query = self.query
		/// type of  data we try to get from keychain
		query[kSecAttrService as String] = whatToGet as AnyObject
		/// kSecMatchLimitOne indicates keychain should read only the most recent item matching this query
		query[kSecMatchLimit as String] = kSecMatchLimitOne
		/// kSecReturnData is set to kCFBooleanTrue in order to retrieve the data for the item
		query[kSecReturnData as String] = kCFBooleanTrue

		/// SecItemCopyMatching will attempt to copy the item
		/// identified by query to the reference itemCopy
		var itemCopy: AnyObject?

		let status = SecItemCopyMatching(query as CFDictionary, &itemCopy)
		/// errSecItemNotFound is a special status indicating the
		/// read item does not exist. Throw itemNotFound so the
		/// client can determine whether or not to handle this case
		guard status != errSecItemNotFound else {
			throw KeychainError.itemNotFound
		}
		/// Any status other than errSecSuccess indicates the read operation failed.
		guard status == errSecSuccess else {
			throw KeychainError.unexpectedStatus(status)
		}
		/// checking if our value is indeed Data and it's present
		guard let dataToDecode = itemCopy as? Data else {
			throw KeychainError.invalidItemFormat
		}

		let dataToReturn = String(decoding: dataToDecode, as: UTF8.self)
		return dataToReturn
	}

	// MARK: method to update our data in Keychain
	func updateData(_ whatToUpdate: String, _ value: Data) throws {
		var query = self.query
		/// type of updated data
		query[kSecAttrService as String] = whatToUpdate as AnyObject

		/// attributes is passed to SecItemUpdate with kSecValueData as the updated item value
		let attributes: [String: AnyObject] = [
			kSecValueData as String: value as AnyObject
		]

		/// SecItemUpdate attempts to update the item identified by query, overriding the previous value
		let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
		/// errSecItemNotFound is a special status indicating the
		/// item to update does not exist. Throw itemNotFound so
		/// the client can determine whether or not to handle this as an error
		guard status != errSecItemNotFound else {
			throw KeychainError.itemNotFound
		}
		/// Any status other than errSecSuccess indicates the update operation failed.
		guard status == errSecSuccess else {
			throw KeychainError.unexpectedStatus(status)
		}
	}

	// MARK: method to delete our data in Keychain
	func deleteData(_ whatToDelete: String) throws {
		var query = self.query
		/// type of deleted data
		query[kSecAttrService as String] = whatToDelete as AnyObject

		let status = SecItemDelete(query as CFDictionary)
		// Any status other than errSecSuccess indicates the delete operation failed.
		guard status == errSecSuccess else {
			throw KeychainError.unexpectedStatus(status)
		}
	}
}

// MARK: Configuration for Moya
enum SpotifyAccessToken {
	case get(code: String)
	case refresh(refreshToken: String)
}

extension SpotifyAccessToken: TargetType {
	// MARK: Setting for AuthManager

	var baseURL: URL {
		return URL(string: AuthManager.shared.vars.tokenAPIURL)!
	}

	var path: String {
		return ""
	}

	var method: Moya.Method {
		return .post
	}

	var task: Moya.Task {
		let encodingQueryString = URLEncoding.queryString

		switch self {
		// exchanging code for access token
		case .get(code: let code):
			let parameters = [
				"grant_type": "authorization_code",
				"code": code,
				"redirect_uri": AuthManager.shared.vars.redirectURI
			]

			return.requestParameters(
				parameters: parameters,
				encoding: encodingQueryString
			)

		// refreshing access token for a fresher one
		case .refresh(refreshToken: let refreshToken):
			let parameters = [
				"grant_type": "refresh_token",
				"refresh_token": refreshToken
			]

			return .requestParameters(
				parameters: parameters,
				encoding: encodingQueryString
			)
		}
	}

	var headers: [String: String]? {
		let authString = "\(AuthManager.shared.vars.clientID):\(AuthManager.shared.vars.clientSecret)"

		let headersToReturn = [
			"Authorization": "Basic \(authString.data(using: .utf8)!.base64EncodedString())",
			"Content-type": "application/x-www-form-urlencoded"
		] as [String: String]

		return headersToReturn
	}
}
