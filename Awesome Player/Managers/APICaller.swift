//
//  API Caller.swift
//  Awesome Player
//
//  Created by Vitali Vyucheiski on 11/10/22.
//

import Foundation
import Moya

enum SpotifyAPI {
	
}

extension SpotifyAPI: TargetType {
	var baseURL: URL {
		<#code#>
	}
 
	var path: String {
		<#code#>
	}

	var method: Moya.Method {
		return .get
	}

	var task: Moya.Task {
		<#code#>
	}

	var headers: [String : String]? {
		<#code#>
	}
}
