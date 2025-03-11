//
//  CouponListView.swift
//  ShoppingDemo
//
//  Created by Thanphicha Yimlamai on 11/3/2568 BE.
//

import Foundation
import SwiftUI

struct CouponListView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CouponViewModel
    @ObservedObject var productVM: ProductViewModel
    
    var body: some View {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading) {
                    HStack{
                        Text("Available Coupon")
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .semibold))
                        Spacer()
                        Button(action: {
                            viewModel.applyCoupon()
                            dismiss()
                        }) {
                            Text("Apply")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                                .underline()
                        }
                    }.padding(.bottom, 10)
                    ForEach(Coupon.CouponType.allCases, id: \.self) { cType in
                        let filtered = viewModel.coupons.filter { $0.couponTypeEnum == cType }
                        if !filtered.isEmpty {
                            Text(cType.rawValue.capitalized)
                                .font(.system(size: 16))
                            
                            
                            ForEach(filtered) { coupon in
                                let canTap = viewModel.canSelect(coupon) { neededCat in
                                    productVM.items
                                        .filter { $0.product.category == neededCat.rawValue }
                                        .reduce(0) { $0 + $1.quantity } > 0
                                }
                                let isSelected = viewModel.isSelected(coupon)
                                
                                CouponItemView(coupon: coupon, isSelected: isSelected)
                                
                                    .opacity(canTap ? 1.0 : 0.6)
                               
                                    .onTapGesture {
                                        if canTap {
                                            viewModel.toggleSelection(for: coupon)
                                            { neededCat in
                                                            productVM.items
                                                                .filter { $0.product.category == neededCat.rawValue }
                                                                .reduce(0) { $0 + $1.quantity } > 0
                                                        }
                                        }
                                    }
                                if isSelected,
                                   coupon.couponTypeEnum == .ontop,
                                   coupon.discountType == 3
                                {
                                    RedeemTextView(viewModel: viewModel, productVM: productVM, point: viewModel.redeemText(for: coupon))
                                }
                            }
                            
                            Divider()
                                .padding(.top, 10)
                        }
                    }
                }.padding(16)
            }
    }
}

struct CouponItemView: View {
    var coupon: Coupon
    var isSelected: Bool
    
    var body: some View {
        ZStack {
            Image(coupon.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(maxWidth: .infinity, maxHeight: 120)
                .cornerRadius(10)
                .shadow(radius: 3)
            
            if isSelected {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 3)
            }
        }
        .padding(.vertical, 2)
    }
}

struct RedeemTextView: View {
    @ObservedObject var viewModel: CouponViewModel
    @ObservedObject var productVM: ProductViewModel
    @Binding var point: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: -3) {
            Text("You have \(viewModel.availablePoints) points")
                .font(.system(size: 14))
                .foregroundColor(.gray)
            
            HStack() {
                Text("Redeem 1 point for 1 baht discount")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
                Spacer()
                TextField("0", text: $point)
                    .keyboardType(.numberPad)
                    .frame(width: 80)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: point) { newValue in
                        guard let typedValue = Int(newValue) else { return }
                        let availablePoints = viewModel.availablePoints
                        let maxPointsAvailable = Int(floor(productVM.totalPrice * 0.2))
                        let finalPoint = min(availablePoints, maxPointsAvailable)
                        if typedValue > finalPoint {
                            point = String(finalPoint)
                        }
                    }
            }
            .padding(.vertical, 2)
        }
    }
}



