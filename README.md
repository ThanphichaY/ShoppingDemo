# shoppingDemo
Thanphicha Yimlamai

The repository for demo shopping cart with coupon discount campaign using Xcode and Swift to simulate the application scenerios.

To Test the app is to clone the project and open in Xcode and run on a simulator. This project uses build-in libraries and materials, so no need to install third party like CocoaPods or another dependency packages.

The main functions of the program are 

1.Add products that read from JSON to cart.

2.Navigate to cart detail, you will see the total price without discount.

3.Apply coupons based on business requirements in order coupon > on top > seasonal. If the first type is not selected, the other types are disabled with no tapping action and less opacity. Same as the other in the same type, if one in that type is selected, the other will be disabled. For On Top type, discount for specific category product will be disabled if that category is not in cart. Redeem coupon will display textfield to type points in which points can't exceed the points user have or 20% of total price or else points will be automatically assigned its maximum. 

4.Once coupons are selected, press apply to navigate back to cart detail. There will be discount summary and the final price. For multiple coupons, discount logic is based on the total price in cart and then sum up all discount type to get the final discount. 

For example, the price of the cart is 2000 which are clothes 1100 baht and shoes 900 baht.

coupon 1 is 10% off. coupon 2 is 10% off on footwear and coupon 3 is 30 baht off every 300 baht.

The final discount is (0.1 x 2000) + (0.1 x 900) + (Int(2000/300) x 30) = 470 and the net price is 1530.


5.The program ends.



