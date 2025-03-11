//
//  ProductViewModel.swift
//  ShoppingDemo
//
//  Created by Thanphicha Yimlamai on 10/3/2568 BE.
//

import Foundation

class ProductViewModel: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var products: [Product] = []
    @Published var showBottomSheet: Bool = false
   
    init() {
        self.products = JSONLoader.load("shopping_list.json")
    }

    var hasSelection: Bool {
        !items.isEmpty
    }
    
    var totalQuantity: Int {
           items.reduce(0) { $0 + $1.quantity }
       }
   
    func add(_ product: Product) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
    }
    
    func remove(_ product: Product) {
        guard let index = items.firstIndex(where: { $0.product.id == product.id }) else {
            return
        }
        if items[index].quantity > 1 {
            items[index].quantity -= 1
        } else {
            items.remove(at: index)
        }
    }
    func totalPriceForCategory(for category: Product.Category) -> Double {
            items
                .filter { $0.product.category == category.rawValue }
                .reduce(0.0) { $0 + Double($1.subtotal) }
        }
   var totalPrice: Double {
       let sum = items.reduce(0.0) { $0 + Double($1.subtotal) }
       return floor(sum)
    }
    var categoryTotals: [Product.Category: Double] {
            var totals = [Product.Category: Double]()
            for item in items {
                if let category = Product.Category(rawValue: item.product.category) {
                    totals[category, default: 0] += Double(item.subtotal)
                }
            }
            return totals
        }
    func displayName(for category: Product.Category) -> String {
        switch category {
        case .bag:
            return "Bags"
        case .cloth:
            return "Clothes"
        case .accessories:
            return "Accessories"
        case .footwear:
            return "Footwear"
        }
    }
    
    func quantity(for product: Product) -> Int {
        items.first(where: { $0.product.id == product.id })?.quantity ?? 0
    }
    func calculateDiscount(selectedCoupons: [SelectedCoupon]) -> ([AppliedCoupon], Double) {
        var couponName = ""
        var onTopName = ""
        var seasonalName = ""
        var couponDiscount = 0.0
        var ontopDiscount = 0.0
        var seasonalDiscount = 0.0
        var totalDiscount = 0.0
        var netPrice = 0.0
        
        for coupon in selectedCoupons {
            print(selectedCoupons)
            switch coupon.discountType {
            case 1:
                couponName = coupon.couponName
                couponDiscount = Double(coupon.discount)
                totalDiscount += couponDiscount
            case 2:
                couponName = coupon.couponName
                let discount = Double(coupon.discount) / 100.0
                couponDiscount = (discount * totalPrice)
                totalDiscount += couponDiscount
            case 3:
                onTopName = coupon.couponName
                ontopDiscount = Double(coupon.discount)
                totalDiscount += ontopDiscount
            case 4:
                onTopName = coupon.couponName
                let bagTotal = categoryTotals[.bag] ?? 0
                let discount = Double(coupon.discount) / 100.0
                ontopDiscount = (discount * bagTotal)
                totalDiscount += ontopDiscount
            case 5:
                onTopName = coupon.couponName
                let clothTotal = categoryTotals[.cloth] ?? 0
                let discount = Double(coupon.discount) / 100.0
                ontopDiscount = (discount * clothTotal)
                totalDiscount += ontopDiscount
            case 6:
                onTopName = coupon.couponName
                let accessoriesTotal = categoryTotals[.accessories] ?? 0
                let discount = Double(coupon.discount) / 100.0
                ontopDiscount = (discount * accessoriesTotal)
                totalDiscount += ontopDiscount
            case 7:
                onTopName = coupon.couponName
                let footwearTotal = categoryTotals[.footwear] ?? 0
                let discount = Double(coupon.discount) / 100.0
                ontopDiscount = (discount * footwearTotal)
                totalDiscount += ontopDiscount
            case 8:
                seasonalName = coupon.couponName
                let onPriceValue = Double(coupon.onPrice)
                let times = Int(totalPrice / onPriceValue)
                seasonalDiscount = Double(times * coupon.discount)
                totalDiscount += seasonalDiscount
            default:
                totalDiscount = 0
            }
        }
        
        var appliedCoupons = [AppliedCoupon]()
        netPrice = totalPrice - totalDiscount
        if couponDiscount > 0 {
            appliedCoupons.append(AppliedCoupon(couponName: couponName, discount: couponDiscount))
        }
        if ontopDiscount > 0 {
            appliedCoupons.append(AppliedCoupon(couponName: onTopName, discount: ontopDiscount))
        }
        if seasonalDiscount > 0 {
            appliedCoupons.append(AppliedCoupon(couponName: seasonalName, discount: seasonalDiscount))
        }
        if totalDiscount > 0 {
            appliedCoupons.append(AppliedCoupon(couponName: "Total Discount", discount: totalDiscount))
        }
        return (appliedCoupons, netPrice)
    }
}


