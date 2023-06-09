//
//  IntroOffers.swift
//  Chargebee
//
//  Created by ramesh_g on 30/05/23.
//

import Foundation
import StoreKit




public final class SK1ProductDiscount: NSObject,SK1productDiscountType {
    
    
    var offerIdentifier: String {self.discountType.offerIdentifier}
    var price: Decimal  {self.discountType.price}
    
    var localizedPriceString: String{self.discountType.localizedPriceString}
    
    var paymentMode: PaymentMode{self.discountType.paymentMode}
    
    var numberOfPeriods: Int{self.discountType.numberOfPeriods}
    
    var subscriptionPeriod: SubscriptionPeriod{self.discountType.subscriptionPeriod}
    
    var type: DiscountType{self.discountType.type}
    
    
    public enum PaymentMode: Int {
        /// Price is charged one or more times
        case payAsYouGo = 0
        /// Price is charged once in advance
        case payUpFront = 1
        /// No initial charge
        case freeTrial = 2
    }
    
    public enum DiscountType: Int {
        case introductory = 0
        case promotional = 1
    }
    let discountType: SK1productDiscountType
    init(discountType: SK1productDiscountType) {
        self.discountType = discountType
        super.init()
    }
//    var offerIdentifier: String{self.discountType.offerIdentifier}
//    var price: Decimal{self.discountType.price}
}


internal protocol SK1productDiscountType: Sendable {
    var offerIdentifier: String {get}
    var price: Decimal { get }
    var localizedPriceString: String { get }
    var paymentMode: SK1ProductDiscount.PaymentMode{get}
    var numberOfPeriods: Int { get }
    var subscriptionPeriod: SubscriptionPeriod{get}
    var type: SK1ProductDiscount.DiscountType{get}
}

public final class SubscriptionPeriod {
    var numberOfPeriods: Int
    var unit: Unit
    init(numberOfPeriods: Int, unit: Unit) {
        self.numberOfPeriods = numberOfPeriods
        self.unit = unit
    }
}
public enum Unit: Int {
    case day = 0
    case week = 1
    case month = 2
    case year = 3
}

