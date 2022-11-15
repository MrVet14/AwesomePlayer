//
//  Constants.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/15/22.
//

import Foundation

let accessTokenKey = "access-token-key"
let redirectUri = URL(string: "awesome-player://")!
let spotifyClientId = "a02da930b4a64ab8a976ea8376eda362"
let spotifyClientSecretKey = "dd4bc1311afa489b8c2e6f5ffe1298cf"

// remove scopes you don't need
let scopes: SPTScope = [.userReadEmail]
// remove scopes you don't need
let stringScopes = ["user-read-email"]
