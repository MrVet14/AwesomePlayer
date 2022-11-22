//
//  Song.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/9/22.
//

import Foundation

struct Song: Hashable {
	let id: String
	let title: String
	let album: String
	let albumCoverPictureURL: String
	let sonSampleURL: String
}
