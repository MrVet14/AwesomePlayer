//
//  Playlist.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 1/1/23.
//

import Foundation

struct PlaylistDetailsResponse: Codable {
	let description: String
	let id: String
	let images: [Image]
	let name: String
	let tracks: PlaylistTracksResponse
}

struct PlaylistTracksResponse: Codable {
	let items: [PlaylistItem]
}

struct PlaylistItem: Codable {
	let track: Song
}
