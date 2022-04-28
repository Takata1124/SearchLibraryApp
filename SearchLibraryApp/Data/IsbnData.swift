//
//  IsbnData.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/26.
//

import Foundation

struct IsbnData: Decodable {
    
    let summary: Summary
    let hanmoto: Hanmoto
    let onix: Onix
}

struct Hanmoto: Decodable {
    
    let datecreated: String
}

struct Summary: Decodable {
    
    let isbn: String
    let title: String
    let pubdate: String
    let cover: String
    let author: String
}

struct Onix: Decodable {
    
    let CollateralDetail: CollateralDetail
}

struct CollateralDetail: Decodable {
    
    let TextContent: [TextContent]
}

struct TextContent: Decodable {
    let Text: String
}
