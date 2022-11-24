//
//  API Caller.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/10/22.
//

import Foundation
import Moya

enum SpotifyAPI {
	case loadASong(id: String)
	case loadSongs(ids: [String]) // max 50 IDs
	case loadSongFeatures(id: String)
	case loadSongsFeatures(ids: [String]) // max 100 IDs
	case loadRecommended
}

extension SpotifyAPI: TargetType {
	var baseURL: URL {
		return URL(string: PlistReaderManager().returnString(APIConstants.spotifyWebAPIBaseUrl))!
	}

	var path: String {
		switch self {
		case .loadASong(id: let id):
			return "/tracks/\(id)"

		case .loadSongs:
			return "/track"

		case .loadSongFeatures(id: let id):
			return "/audio-features/\(id)"

		case .loadSongsFeatures:
			return "/audio-features"

		case .loadRecommended:
			return "/recommendations"
		}
	}

	var method: Moya.Method {
		return .get
	}

	var task: Moya.Task {
		let queryString = URLEncoding.queryString

		switch self {
		case .loadASong:
			return .requestPlain

		case .loadSongs(ids: let ids):
			return .requestParameters(parameters: ["ids": ids], encoding: queryString)

		case .loadSongFeatures:
			return .requestPlain

		case .loadSongsFeatures(ids: let ids):
			return .requestParameters(parameters: ["ids": ids], encoding: queryString)

		case .loadRecommended:
			let parameters = [
				// Up to 5 seed values may be provided in any combination of seed_artists, seed_tracks and seed_genres
				// "seed_artists": "",
				"seed_genres": "pop,country",
				// "seed_tracks": "",
				"limit": "1",
				"market": "US"
			]
			return .requestParameters(parameters: parameters, encoding: queryString)
		}
	}

	var headers: [String: String]? {
		var authToken = ""

		do {
			authToken = try KeychainManager().getToken()
		} catch {
			print(error)
		}

		let returnHeaders = [
			"Content-type": "application/json",
			"Authorization": "Bearer \(authToken)"
		] as [String: String]

		return returnHeaders
	}
}

extension SpotifyAPI: AccessTokenAuthorizable {
	var authorizationType: Moya.AuthorizationType? {
		return .bearer
	}
}

class APICaller {
	let provider = MoyaProvider<SpotifyAPI>()

	func loadASong(_ id: String) {
		provider.request(.loadASong(id: id)) { result in
			self.testPrintResult(result)
		}
	}

	func loadSongs(_ ids: [String]) {
		provider.request(.loadSongs(ids: ids)) { result in
			self.testPrintResult(result)
		}
	}

	func loadSongFeatures(_ id: String) {
		provider.request(.loadSongFeatures(id: id)) { result in
			self.testPrintResult(result)
		}
	}

	func loadSongsFeatures(_ ids: [String]) {
		provider.request(.loadSongsFeatures(ids: ids)) { result in
			self.testPrintResult(result)
		}
	}

	func loadRecommendedTracks() {
		provider.request(.loadRecommended) { result in
			self.testPrintResult(result)
		}
	}

	func testPrintResult(_ result: Result<Moya.Response, Moya.MoyaError>) {
		switch result {
		case .success(let response):
			print("Success")
			print(response.statusCode)
			print(String(bytes: response.data, encoding: .utf8)!)
		case .failure(let error):
			print("Failure")
			print(error)
		}
	}
}
