//
//  AuthManager.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/10/22.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    struct Constants {
        static let clientID = "a02da930b4a64ab8a976ea8376eda362"
        static let clientSecret = "dd4bc1311afa489b8c2e6f5ffe1298cf"
    }
    private init() {}
    var isSignedIn: Bool {
        return false
    }
    private var accessToken: String? {
        return nil
    }
    private var refreshToken: String? {
        return nil
    }
    private var tokenExpirationDate: Date? {
        return nil
    }
    private var shouldRefreshToken: Bool {
        return false
    }
}
