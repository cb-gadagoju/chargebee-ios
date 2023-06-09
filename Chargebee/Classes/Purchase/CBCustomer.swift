//
//  CBCustomer.swift
//  Chargebee
//
//  Created by ramesh_g on 06/02/23.
//

import Foundation
import StoreKit

public struct CBCustomer{
    public let customerID: String?
    public let firstName: String?
    public let lastName: String?
    public let email: String?
    
    public init(customerID: String? = "",firstName: String? = "",lastName:String? = "",
                email:String? = "") {
        self.customerID = customerID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}


struct IntroductoryDiscountModel: Equatable {
    let localizedPeriod: String
    let localizedPrice: String
    let paymentMode: String
}

struct CBProductDiscountIntroOffers{
    var price: String?
    var type: String?
    var period: String?
    public init(price: String? = "",type: String? = "",period:String? = "") {
        self.price = price
        self.type = type
        self.period = period
    }

}

public struct CBProductDiscount {
    /// Discount price of a product in a local currency.
    public let price: Decimal

    /// Unique identifier of a discount offer for a product.
    public let identifier: String?

    /// An information about period for a product discount.
    public let subscriptionPeriod: CBProductSubscriptionPeriod

    /// A number of periods this product discount is available
    public let numberOfPeriods: Int

    /// A payment mode for this product discount.
    public let paymentMode: PaymentMode

    /// A formatted price of a discount for a user's locale.
    public let localizedPrice: String?

    /// A formatted subscription period of a discount for a user's locale.
    public let localizedSubscriptionPeriod: String?

    /// A formatted number of periods of a discount for a user's locale.
    public let localizedNumberOfPeriods: String?
}

extension CBProductDiscount {
    @available(iOS 11.2, macOS 10.14.4, *)
    init(discount: SKProductDiscount, locale: Locale) {
        let identifier: String?
        if #available(iOS 12.2, *) {
            identifier = discount.identifier
        } else {
            identifier = nil
        }

        self.init(price: discount.price.decimalValue,
                  identifier: identifier,
                  subscriptionPeriod: CBProductSubscriptionPeriod(subscriptionPeriod: discount.subscriptionPeriod),
                  numberOfPeriods: discount.numberOfPeriods,
                  paymentMode: PaymentMode(mode: discount.paymentMode),
                  localizedPrice: locale.localized(price: discount.price),
                  localizedSubscriptionPeriod: locale.localized(period: discount.subscriptionPeriod),
                  localizedNumberOfPeriods: locale.localized(numberOfPeriods: discount))
    }
}

extension CBProductDiscount {
    public enum PaymentMode: UInt {
        case payAsYouGo
        case payUpFront
        case freeTrial
        case unknown
    }
}

extension CBProductDiscount.PaymentMode {
    @available(iOS 11.2, macOS 10.14.4, *)
    public init(mode: SKProductDiscount.PaymentMode) {
        switch mode {
        case .payAsYouGo:
            self = .payAsYouGo
        case .payUpFront:
            self = .payUpFront
        case .freeTrial:
            self = .freeTrial
        @unknown default:
            self = .unknown
        }
    }
}

extension CBProductDiscount.PaymentMode: CustomStringConvertible {
    public var description: String {
        switch self {
        case .payAsYouGo: return "payAsYouGo"
        case .payUpFront: return "payUpFront"
        case .freeTrial: return "freeTrial"
        case .unknown: return "unknown"
        }
    }
}



public struct CBProductSubscriptionPeriod {
    /// A unit of time that a subscription period is specified in.
    public let unit: CBPeriodUnit

    /// A number of period units.
    public let numberOfUnits: Int
}

extension CBProductSubscriptionPeriod {
    @available(iOS 11.2, macOS 10.13.2, *)
    init(subscriptionPeriod: SKProductSubscriptionPeriod) {
        self.init(unit: CBPeriodUnit(unit: subscriptionPeriod.unit), numberOfUnits: subscriptionPeriod.numberOfUnits)
    }
}

extension CBProductSubscriptionPeriod: CustomStringConvertible {
    public var description: String {
        "\(numberOfUnits) \(unit)"
    }
}

extension CBProductSubscriptionPeriod: Equatable, Sendable {}

extension CBProductSubscriptionPeriod: Codable {
    enum CodingKeys: String, CodingKey {
        case unit
        case numberOfUnits = "number_of_units"
    }
}




public enum CBPeriodUnit: UInt {
    case day
    case week
    case month
    case year
    case unknown
}

extension CBPeriodUnit {
    @available(iOS 11.2, macOS 10.13.2, *)
    public init(unit: SKProduct.PeriodUnit) {
        switch unit {
        case .day:
            self = .day
        case .week:
            self = .week
        case .month:
            self = .month
        case .year:
            self = .year
        @unknown default:
            self = .unknown
        }
    }

    @available(iOS 11.2, macOS 10.13.2, *)
    public init(unit: SKProduct.PeriodUnit?) {
        guard let unit = unit else {
            self = .unknown
            return
        }
        self.init(unit: unit)
    }
}

extension CBPeriodUnit: CustomStringConvertible {
    public var description: String {
        let value: CodingValues
        switch self {
        case .day: value = .day
        case .week: value = .week
        case .month: value = .month
        case .year: value = .year
        case .unknown: value = .unknown
        }
        return value.rawValue
    }
}

extension CBPeriodUnit: Equatable, Sendable {}

extension CBPeriodUnit: Codable {
    fileprivate enum CodingValues: String {
        case day
        case week
        case month
        case year
        case unknown
    }

    public init(from decoder: Decoder) throws {
        let value = CodingValues(rawValue: try decoder.singleValueContainer().decode(String.self))
        switch value {
        case .day: self = .day
        case .week: self = .week
        case .month: self = .month
        case .year: self = .year
        default: self = .unknown
        }
    }

    public func encode(to encoder: Encoder) throws {
        let value: CodingValues
        switch self {
        case .day: value = .day
        case .week: value = .week
        case .month: value = .month
        case .year: value = .year
        case .unknown: value = .unknown
        }
        var container = encoder.singleValueContainer()
        try container.encode(value.rawValue)
    }
}



extension Locale {
    func localized(price: NSNumber) -> String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2
        return formatter.string(from: price)
    }

    @available(iOS 11.2, macOS 10.13.2, *)
    func localized(period: SKProductSubscriptionPeriod) -> String? {
        switch period.unit {
        case .day:
            if period.numberOfUnits == 7 { return localizedComponents(weekOfMonth: 1) }
            return localizedComponents(day: period.numberOfUnits)
        case .week:
            return localizedComponents(weekOfMonth: period.numberOfUnits)
        case .month:
            return localizedComponents(month: period.numberOfUnits)
        case .year:
            return localizedComponents(year: period.numberOfUnits)
        @unknown default:
            return nil
        }
    }

    @available(iOS 11.2, macOS 10.13.2, *)
    func localized(numberOfPeriods discount: SKProductDiscount) -> String? {
        let resultingNumber = discount.numberOfPeriods * discount.subscriptionPeriod.numberOfUnits
        
        switch discount.subscriptionPeriod.unit {
        case .day:
            return localizedComponents(day: resultingNumber)
        case .week:
            return localizedComponents(weekOfMonth: resultingNumber)
        case .month:
            return localizedComponents(month: resultingNumber)
        case .year:
            return localizedComponents(year: resultingNumber)
        @unknown default:
            return nil
        }
    }

    private func localizedComponents(day: Int? = nil, weekOfMonth: Int? = nil, month: Int? = nil, year: Int? = nil) -> String? {
        var calendar = Calendar.current
        calendar.locale = self

        var components = DateComponents(calendar: calendar)
        components.day = day
        components.weekOfMonth = weekOfMonth
        components.month = month
        components.year = year

        return DateComponentsFormatter.localizedString(from: components, unitsStyle: .full)
    }
}
