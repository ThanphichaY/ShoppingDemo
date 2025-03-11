//
//  ItemModel.swift
//  ShoppingDemo
//
//  Created by Thanphicha Yimlamai on 8/3/2568 BE.
//

import Foundation

struct Product: Hashable, Codable, Identifiable {
    var productName: String
    var id: Int
    var category: Int
    var price: Int
    var unit: String
    var image: String

    enum Category: Int, CaseIterable, Codable, Hashable {
        case bag = 1
        case cloth = 2
        case accessories = 3
        case footwear = 4
    }
}

struct CartItem: Identifiable, Hashable { 
    let product: Product
    var quantity: Int

    var id: Int {
        product.id
    }
    
    var subtotal: Double {
        Double(product.price * quantity)
    }
    
}
