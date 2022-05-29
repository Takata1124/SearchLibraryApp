//
//  LocationData.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/27.
//

import Foundation

struct LocationData: Decodable {
    
    let short: String
    let post: String
    let tel: String
    let pref: String
    let city: String
    let address: String
    let geocode: String
    let distance: Double
    let systemid: String
    let url_pc: String
}

struct Spot {

    let name: String
    var systemId: String
    let latitude: String
    let longitude: String
    let distance: Double
    let pcUrl: String
}
