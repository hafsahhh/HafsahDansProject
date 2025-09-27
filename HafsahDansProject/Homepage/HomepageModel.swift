//
//  HomepageModel.swift
//  HafsahDansProject
//
//  Created by Siti Hafsah on 27/09/25.
//

import Foundation

// MARK: - WelcomeElement
struct WelcomeElement: Codable {
    let id: Int
    let title: String
    let price: Double
    let description: String
    let category: String
    let image: String
    let rating: Rating
}

// MARK: - Rating
struct Rating: Codable {
    let rate: Double
    let count: Int
}

typealias Welcome = [WelcomeElement]
