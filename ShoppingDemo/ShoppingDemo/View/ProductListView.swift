//
//  ContentView.swift
//  ShoppingDemo
//
//  Created by Thanphicha Yimlamai on 8/3/2568 BE.
//

import SwiftUI

struct ProductListView: View {
    @ObservedObject var viewModel = ProductViewModel()
    @ObservedObject var couponVM = CouponViewModel()
    
    var body: some View {
            NavigationView {
                List(viewModel.products) { product in
                    ProductItemView(product: product,
                                    quantity: viewModel.quantity(for: product)) {
                        viewModel.add(product)
                    } decrementAction: {
                        viewModel.remove(product)
                    }
                }
                .sheet(isPresented: $viewModel.showBottomSheet) {
                    if !viewModel.items.isEmpty {
                        CartSheetView(viewModel: viewModel, couponVM: couponVM)
                            .presentationDetents([.large])
                            .presentationDragIndicator(.visible)
                    } else {
                        CartSheetEmptyView()
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Text("ShopShop")
                            .font(.headline)
                        
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ZStack(alignment: .topTrailing) {
                            Button {
                                viewModel.showBottomSheet = true
                            } label: {
                                Image(systemName: "cart")
                                    .font(.title2)
                            }
                            if viewModel.totalQuantity > 0 {
                                Text("\(viewModel.totalQuantity)")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                    .frame(width: 16, height: 16)
                                    .background(Circle().fill(Color.red))
                                    .offset(x: 6, y: -4)
                            }
                        }
                    }
                }
            }
        }
}

struct ProductItemView: View {
    var product: Product
    let quantity: Int
    let incrementAction: () -> Void
    let decrementAction: () -> Void
    
    var body: some View {
        HStack(alignment: .top){
            Image(product.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 80, height: 80)
                .cornerRadius(10)
                .shadow(radius: 3)
            
            VStack(alignment: .leading) {
                Text(product.productName)
                    .font(.title2)
                    .foregroundColor(.secondary)
                    
               
                HStack {
                    Text("\(product.unit) \(product.price)")
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Spacer()
                    HStack(spacing: 0) {
                        Image(systemName: "minus")
                            .frame(width: 16, height: 16)
                            .foregroundColor(.black)
                            .onTapGesture {
                                decrementAction()
                            }
                        Text("\(quantity)")
                            .frame(width: 40)
                            .font(.caption)
                        
                        Image(systemName: "plus")
                            .frame(width: 16, height: 16)
                            .foregroundColor(.black)
                            .onTapGesture {
                                incrementAction()
                            }
                    }
                    .padding(6)
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.black, lineWidth: 1))
                    
                }
            }
        }.padding(.vertical, 8)
    }
}

struct CartSheetView: View {
    @ObservedObject var viewModel: ProductViewModel
    @ObservedObject var couponVM: CouponViewModel
    @State private var navigateToCouponView = false
    
    var body: some View {
        NavigationView{
            VStack(alignment: .leading) {
                Text("Your Order")
                    .font(.headline)
                    .padding(.top, 16)
                ForEach(viewModel.items) { item in
                    VStack {
                        HStack {
                            Text(item.product.productName)
                            Spacer()
                            Text("x \(item.quantity)")
                        }
                        HStack {
                            Spacer()
                            Text("\(item.product.price * item.quantity)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                    }
                    
                }.padding(.vertical, 2)
                
                Section(header: Text("Category Total").font(.headline).padding(.vertical, 16)) {
                    ForEach(Product.Category.allCases, id: \.self) { category in
                        let catTotal = viewModel.totalPriceForCategory(for: category)
                        if catTotal > 0 {
                            HStack {
                                Text(viewModel.displayName(for: category))
                                Spacer()
                                Text("THB \(String(format: "%.2f", catTotal))")
                            }
                        }
                    }.padding(.vertical, 3)
                }
                
                if !couponVM.appliedCoupons.isEmpty {
                    let (discountData, _) = viewModel.calculateDiscount(selectedCoupons: couponVM.appliedCoupons)
                    ForEach(discountData, id: \.self) { data in
                        HStack{
                            Text("\(data.couponName)")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Spacer()
                            Text("- \(String(format: "%.2f", data.discount))")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }.padding(.vertical, 2)
                    }
                }
                
                HStack{
                    Spacer()
                    Button(action: {
                        navigateToCouponView = true
                    }) {
                        Text("Apply Coupon")
                            .foregroundColor(.black)
                            .font(.caption2)
                            .underline()
                    }
                    NavigationLink(
                        destination: CouponListView(viewModel: couponVM, productVM: viewModel),
                        isActive: $navigateToCouponView,
                        label: {EmptyView()})
                }.padding(.top, 8)
                Spacer()
                
                if !couponVM.appliedCoupons.isEmpty {
                    let (_, netPrice) = viewModel.calculateDiscount(selectedCoupons: couponVM.appliedCoupons)
                    HStack{
                        Spacer()
                        Text("THB \(String(format: "%.2f", netPrice))")
                            .font(.title3)
                    }
                }
                
                HStack{
                    Text("Total")
                        .font(.title3)
                    Spacer()
                    
                    Text("THB \(String(format: "%.2f", viewModel.totalPrice))")
                        .font(.title3)
                        .strikethrough(!couponVM.appliedCoupons.isEmpty, color: .black)
                }
                
                Button(action: {
                    print("Check out successfully")
                }) {
                    Text("CHECK OUT")
                        .frame(maxWidth: .infinity, maxHeight: 50)
                        .foregroundColor(.white)
                        .background(Color.black)
                        .cornerRadius(5)
                }
            }.padding(.horizontal, 16)
        }
    }
}

struct CartSheetEmptyView: View {
    var body: some View {
        VStack(spacing: 16){
            Image("empty-cart")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 160, height: 160)
            Text("Your cart is Empty")
                .font(.system(size: 20, weight: .semibold))
        }
    }
}


#Preview {
    ProductListView()
}
