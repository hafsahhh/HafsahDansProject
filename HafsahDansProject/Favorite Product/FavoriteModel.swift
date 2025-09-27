//
//  FavoriteModel.swift
//  HafsahDansProject
//
//  Created by Siti Hafsah on 27/09/25.
//

import Foundation
import RealmSwift

class FavoriteProduct: Object {
    @Persisted(primaryKey: true) var id: Int = 0
    @Persisted var title: String = ""
    @Persisted var price: Double = 0.0
    @Persisted var image: String = ""
    @Persisted var category: String = "" 
}
