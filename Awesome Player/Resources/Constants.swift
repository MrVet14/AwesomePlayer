//
//  Constants.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/15/22.
//

import Foundation

enum KeyChainParameters {
	internal static let service: String = "SpotifySDK"
	internal static let account: String = "User"
}

enum PlistBundleParameters {
	internal static let spotifyClientId: String = "spotifyClientId"
	internal static let spotifyClientSecretKey: String = "spotifyClientSecretKey"
	internal static let redirectUri: String = "redirectUri"
	internal static let spotifyAPITokenURL: String = "spotifyAPITokenURL"
	internal static let tokenSwapURL: String = "tokenSwapURL"
	internal static let tokenRefreshURL: String = "tokenRefreshURL"
}

enum APIConstants {
	internal static let spotifyWebAPIBaseUrl = "spotifyWebAPIBaseUrl"
}
