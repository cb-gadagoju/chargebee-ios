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

