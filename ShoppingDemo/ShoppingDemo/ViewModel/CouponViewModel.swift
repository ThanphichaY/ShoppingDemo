//
//  CouponViewModel.swift
//  ShoppingDemo
//
//  Created by Thanphicha Yimlamai on 11/3/2568 BE.
//

import Foundation
import SwiftUI

class CouponViewModel: ObservableObject {
    @Published var coupons: [Coupon] = []
    @Published var redeemPoints: [Int: String] = [:]
    @Published var availablePoints: Int = 99
    
    @Published var selectedCoupons: [Coupon.CouponType: Coupon?] = [
        .coupon:   nil,
        .ontop:    nil,
        .seasonal: nil
    ]
    
    @Published var appliedCoupons: [SelectedCoupon] = []
    
    init() {
        self.coupons = JSONLoader.load("coupon_list.json")
    }
    
    private let discountTypeToCategory: [Int: Product.Category] = [
        4: .bag,
        5: .cloth,
        6: .accessories,
        7: .footwear
    ]
    
    func canSelect(_ coupon: Coupon, cartHasCategory: (Product.Category) -> Bool) -> Bool {
        let cType = coupon.couponTypeEnum
        switch cType {
        case .coupon:
            let currentlySelected = selectedCoupons[.coupon] ?? nil
            return (currentlySelected == nil || currentlySelected == coupon)
        case .ontop:
            let couponSelected = selectedCoupons[.coupon] ?? nil
            guard couponSelected != nil else { return false }
            if let neededCat = discountTypeToCategory[coupon.discountType] {
                guard cartHasCategory(neededCat) else { return false }
            }
            let ontopSelected = selectedCoupons[.ontop] ?? nil
            return (ontopSelected == nil || ontopSelected == coupon)
        case .seasonal:
            let ontopSelected    = selectedCoupons[.ontop] ?? nil
            let seasonalSelected = selectedCoupons[.seasonal] ?? nil
            guard ontopSelected != nil else { return false }
            return (seasonalSelected == nil || seasonalSelected == coupon)
        }
    }
    
    func toggleSelection(for coupon: Coupon, cartHasCategory: (Product.Category) -> Bool) {
        guard canSelect(coupon, cartHasCategory: cartHasCategory) else { return }
        
        let cType = coupon.couponTypeEnum
        if selectedCoupons[cType] == coupon {
            selectedCoupons[cType] = nil
            if cType == .coupon {
                selectedCoupons[.ontop] = nil
                selectedCoupons[.seasonal] = nil
            }
            if cType == .ontop {
                selectedCoupons[.seasonal] = nil
            }
            if cType == .seasonal {
                selectedCoupons[.seasonal] = nil
            }
        } else {
            selectedCoupons[cType] = coupon
        }
        
    }
    
    func isSelected(_ coupon: Coupon) -> Bool {
        selectedCoupons[coupon.couponTypeEnum] == coupon
    }
    
    func redeemText(for coupon: Coupon) -> Binding<String> {
            Binding(
                get: { self.redeemPoints[coupon.id, default: ""] },
                set: { self.redeemPoints[coupon.id] = $0 }
            )
        }
    
    func applyCoupon() {
        let selectedArray = selectedCoupons.values
            .compactMap { $0 }
        
        let mapped = selectedArray.map { coupon -> SelectedCoupon in
            var sc = SelectedCoupon(
                couponName: coupon.couponName,
                id: coupon.id,
                discount: coupon.discount,
                type: coupon.type,
                discountType: coupon.discountType,
                onPrice: coupon.onPrice ?? 0
            )
            if coupon.discountType == 3 {
                let typedPointsString = redeemPoints[coupon.id, default: "0"]
                let typedPoints = Int(typedPointsString) ?? 0
                sc.discount = typedPoints
            }
            
            return sc
        }
        appliedCoupons = mapped
        
    }
}
