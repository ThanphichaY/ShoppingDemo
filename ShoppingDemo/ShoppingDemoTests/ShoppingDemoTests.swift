//
//  ShoppingDemoTests.swift
//  ShoppingDemoTests
//
//  Created by Thanphicha Yimlamai on 12/3/2568 BE.
//

import XCTest
@testable import ShoppingDemo

final class ShoppingDemoTests: XCTestCase {
    var productVM: ProductViewModel!
    var couponVM: CouponViewModel!
    
    override func setUp() {
        super.setUp()
        productVM = ProductViewModel()
        couponVM  = CouponViewModel()
        
        let bagProduct = Product(
            productName: "Test Bag",
            id: 999,
            category: 1,
            price: 1000,
            unit: "THB",
            image: "bag_test"
        )
        productVM.add(bagProduct)
    }
    
    override func tearDown() {
        productVM = nil
        couponVM  = nil
        super.tearDown()
    }
    
    // MARK: - CouponViewModel.canSelect Tests
    
    func testCanSelect_CouponType_WhenNoneSelected_ShouldReturnTrue() {
        let coupon = Coupon(
            couponName: "Fixed 50 Baht",
            id: 101,
            discount: 50,
            type: "coupon",
            discountType: 1,
            onPrice: nil,
            image: "coupon_img"
        )
        
        let canSelect = couponVM.canSelect(coupon) { neededCat in
            productVM.items.contains { $0.product.category == neededCat.rawValue }
        }
        XCTAssertTrue(canSelect, "Should be able to select a coupon type when none is selected.")
    }
    
    func testCanSelect_OntopTypeRequiresCouponFirst_ShouldReturnFalseIfNoCouponSelected() {
        let coupon = Coupon(
            couponName: "15% on Bags",
            id: 202,
            discount: 15,
            type: "ontop",
            discountType: 4,
            onPrice: nil,
            image: "coupon_img"
        )
        
        let canSelect = couponVM.canSelect(coupon) { neededCat in
            productVM.items.contains { $0.product.category == neededCat.rawValue }
        }
        XCTAssertFalse(canSelect, "Should NOT be able to select ontop type if no coupon is selected first.")
    }
    
    func testCanSelect_OntopTypeWithCouponSelectedAndHasBagCategory_ShouldReturnTrue() {
        let cpnCoupon = Coupon(
            couponName: "50 Baht off",
            id: 101,
            discount: 50,
            type: "coupon",
            discountType: 1,
            onPrice: nil,
            image: "coupon_img"
        )
        couponVM.toggleSelection(for: cpnCoupon) { neededCat in
            productVM.items.contains { $0.product.category == neededCat.rawValue }
        }
        
        let ontopCoupon = Coupon(
            couponName: "15% on Bags",
            id: 202,
            discount: 15,
            type: "ontop",
            discountType: 4,
            onPrice: nil,
            image: "ontop_img"
        )
        
        let canSelect = couponVM.canSelect(ontopCoupon) { neededCat in
            productVM.items.contains { $0.product.category == neededCat.rawValue }
        }
        XCTAssertTrue(canSelect, "Should be able to select ontop type after coupon is selected and cart has bag.")
    }
    
    func testCanSelect_OntopTypeWithCouponSelectedAndNotBagCategory_ShouldReturnFalse() {
        let cpnCoupon = Coupon(
            couponName: "50 Baht off",
            id: 101,
            discount: 50,
            type: "coupon",
            discountType: 1,
            onPrice: nil,
            image: "coupon_img"
        )
        couponVM.toggleSelection(for: cpnCoupon) { neededCat in
            productVM.items.contains { $0.product.category == neededCat.rawValue }
        }
        
        let ontopCoupon = Coupon(
            couponName: "15% on cloth",
            id: 202,
            discount: 15,
            type: "ontop",
            discountType: 5,
            onPrice: nil,
            image: "ontop_img"
        )
        
        let canSelect = couponVM.canSelect(ontopCoupon) { neededCat in
            productVM.items.contains { $0.product.category == neededCat.rawValue }
        }
        XCTAssertFalse(canSelect, "Should not be able to select ontop type of discount on cloth")
    }
    
    func testCanSelect_SeasonalTypeWithNoCouponOrOntopSelected_ShouldReturnFalse() {
        let seasonalCoupon = Coupon(
            couponName: "30 baht off every 200 baht",
            id: 202,
            discount: 15,
            type: "seasonal",
            discountType: 5,
            onPrice: nil,
            image: "ontop_img"
        )
        
        let canSelect = couponVM.canSelect(seasonalCoupon) { neededCat in
            productVM.items.contains { $0.product.category == neededCat.rawValue }
        }
        XCTAssertFalse(canSelect, "Should not be able to select seasonal type")
    }
    
    // MARK: - ProductViewModel.calculateDiscount Tests
    func testCalculateDiscount_FixedAmount() {
        let sc = SelectedCoupon(
            couponName: "50 Baht off",
            id: 111,
            discount: 50,
            type: "coupon",
            discountType: 1,
            onPrice: 0
        )
        
        let (applied, netPrice) = productVM.calculateDiscount(selectedCoupons: [sc])
        XCTAssertEqual(applied.count, 2, "Should create 2 rows: one for the coupon, one for total discount if your logic does that.")
        let totalDiscountRow = applied.first(where: { $0.couponName == "Total Discount" })
        XCTAssertNotNil(totalDiscountRow)
        XCTAssertEqual(totalDiscountRow?.discount, 50.0)
        XCTAssertEqual(netPrice, 950.0, accuracy: 0.001, "Net price should be 950 after a 50 Baht discount on 1000 total.")
    }
    
    func testCalculateDiscount_OffOnBag() {
        let sc = SelectedCoupon(
            couponName: "15% on Bags",
            id: 202,
            discount: 15,
            type: "ontop",
            discountType: 4,
            onPrice: 0
        )
        
        let (applied, netPrice) = productVM.calculateDiscount(selectedCoupons: [sc])
        XCTAssertEqual(applied.count, 2)
        let totalDiscountRow = applied.first(where: { $0.couponName == "Total Discount" })
        XCTAssertEqual(totalDiscountRow?.discount ?? 0, 150.0, accuracy: 0.01)
        XCTAssertEqual(netPrice, 850.0, accuracy: 0.001, "Net price should be 850 after 15% off bag priced 1000.")
    }
    
    func testCalculateDiscount_MultipleCoupons() {
      let sc1 = SelectedCoupon(
            couponName: "50 Baht off",
            id: 101,
            discount: 50,
            type: "coupon",
            discountType: 1,
            onPrice: 0
        )
        let sc2 = SelectedCoupon(
            couponName: "15% on Bags",
            id: 202,
            discount: 15,
            type: "ontop",
            discountType: 4,
            onPrice: 0
        )
        
        let (applied, netPrice) = productVM.calculateDiscount(selectedCoupons: [sc1, sc2])
        XCTAssertEqual(netPrice, 800.0, "Should discount total by 200, leaving 800.")
        let totalDiscount = applied.first(where: { $0.couponName == "Total Discount" })?.discount
        XCTAssertEqual(totalDiscount ?? 0, 200.0, accuracy: 0.01)
    }
}
