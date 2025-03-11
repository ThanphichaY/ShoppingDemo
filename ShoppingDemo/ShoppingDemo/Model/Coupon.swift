//
//  Coupon.swift
//  ShoppingDemo
//
//  Created by Thanphicha Yimlamai on 11/3/2568 BE.
//

import Foundation

struct Coupon: Hashable, Codable, Identifiable {
    var couponName: String
    var id: Int
    var discount: Int
    var type: String
    var discountType: Int
    var onPrice: Int?
    var image: String
   
    enum DiscountType: Int, CaseIterable, Codable, Hashable {
        case fixedAmount = 1
        case percentage = 2
        case redeem = 3
        case offOnbag = 4
        case offOnCloth = 5
        case offOnAccessory = 6
        case offOnFootwear = 7
        case offOnPrice = 8
    }
    
    enum CouponType: String, CaseIterable, Codable, Hashable {
        case coupon
        case ontop
        case seasonal 
    }
    
    var couponTypeEnum: CouponType {
           CouponType(rawValue: type) ?? .coupon
       }
    
}

struct SelectedCoupon: Hashable, Codable, Identifiable {
    var couponName: String
    var id: Int
    var discount: Int
    var type: String
    var discountType: Int
    var onPrice: Int
}

struct AppliedCoupon: Hashable, Codable {
    var couponName: String
    var discount: Double
}


