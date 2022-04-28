//
//  BookData.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/28.
//

import Foundation

struct RakutenData: Decodable {

    let Items: [Items]
}

struct Items: Decodable {

    let Item: Item
}

struct Item: Decodable, Hashable {

    let title: String
    let author: String
    let isbn: String
    let salesDate: String
    let itemCaption: String
    let largeImageUrl: String
}

