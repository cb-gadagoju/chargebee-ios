//
//  StoreSubscriptionPeriod.swift
//  Chargebee
//
//  Created by ramesh_g on 13/06/23.
//

import Foundation
import StoreKit

enum PaymentModeType: String {
    case payAsYouGo
    case payUpFront
}
extension  PaymentModeType {
    var description: String{
        switch self {
        case .payAsYouGo:
            return "pay_as_you_go"
        case .payUpFront:
            return "pay_up_front"
        }
    }
    
    
}

enum CBSubscriptionPeriod:Int {
    case none = 0
    case monthly = 1
    case everyTwoMonths = 2
    case everyThreeMonths = 3
    case everySixMonths = 6
    case yearly = 12
}

public extension SKProductDiscount {
    var localizedPaymentMode: String{
        switch paymentMode {
        case .payAsYouGo:
            return "pay_as_you_go"
        case .payUpFront:
            return "pay_up_front"
        case .freeTrial:
            return "freeTrial"
        @unknown default:
            return "unknown"
        }
    }
}

struct StoreSubscriptionPeriod {
    
    func getSubscriptionPeriodForPayUpFront(product: SKProduct) -> CBSubscriptionPeriod {
        
        if let intro = product.introductoryPrice?.subscriptionPeriod {
            let unit = intro.unit
            let value = intro.numberOfUnits
            
            switch unit {
            case .day:
                return .none
            case .week:
                return .none
            case .month:
                switch value {
                case 1:
                    return .monthly
                case 2:
                    return .everyTwoMonths
                case 3:
                    return .everyThreeMonths
                case 6:
                    return .everySixMonths
                default:
                    fatalError("ERROR: YOU HAVE NOT CONSIDERED ALL MONTHLY VALUES.")
                }
            case .year:
                return .yearly
            @unknown default:
                fatalError("ERROR: YOU HAVE NOT CONSIDERED ALL SUBSCRIPTION UNITS.")
            }
            
        }else {
            return .none
        }
    }
}
