//
//  CBProductsTableViewController.swift
//  Chargebee_Example
//
//  Created by Imayaselvan on 23/05/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit
import Chargebee

final class CBSDKProductsTableViewController: UITableViewController, UITextFieldDelegate {

    var products: [CBProduct] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        CBSDKProductTableViewCell.registerCellXib(with: self.tableView)
        self.title = "Products"
        if CBDemoPersistance.isPurchaseProductIDAvailable(){
            CBDemoPersistance.clearPurchaseIDCache()
        }
    }
 
    func reachabilityObserver() {
        NetworkReachability.shared.reachabilityObserver = {  status in
            switch status {
            case .connected:
                print("Reachability: Network available ")
                if CBDemoPersistance.isPurchaseProductIDAvailable(){
                    self.validateReceiptOnceInternetIsAvailable()
                }
            case .disconnected:
                print("Reachability: Network unavailable ")
            }
        }
    }
    
    func ValidateReceipt(_ product: CBProduct){
        CBPurchase.shared.validateReceipt(product) { result in
            switch result {
            case .success(let result):
                print(result.status )
                print(result.subscriptionId ?? "")
                print(result.planId ?? "")
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                    let alertController = UIAlertController(title: "Chargebee", message: "success", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
                if CBDemoPersistance.isPurchaseProductIDAvailable(){
                    CBDemoPersistance.clearPurchaseIDCache()
                }
                NetworkReachability.shared.stopNotifier()
            case .failure(let error):
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                    let alertController = UIAlertController(title: "Chargebee", message: error.localizedDescription, preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func validateReceiptOnceInternetIsAvailable() {
        if let productID = CBDemoPersistance.getProductIDFromCache() {
            // Getting the productID from Cache and with ProductID we will get the product using retrieveProducts API and Validate Receipt
            self.view.activityStartAnimating(activityColor: .gray, backgroundColor: .gray)
            print("Offline Validation is Going on")
            CBPurchase.shared.retrieveProducts(withProductID: [productID] as! [String]) { result in
                DispatchQueue.main.async {
                    self.view.activityStopAnimating()
                }
                switch result {
                case let .success(products):
                    if let product = products.first {
                        self.ValidateReceipt(product)
                        print("Inside Success")

                    }
                case let .failure(error):
                    debugPrint("Error: \(error.localizedDescription)")
                    print("Inside Failure")

                }
            }
        }
    }
    
    private func addNetWorkObserver(){
         NetworkReachability.shared.startNotifier()
         self.reachabilityObserver()
     }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: CBSDKProductTableViewCell.self), for: indexPath) as! CBSDKProductTableViewCell
        let product: CBProduct = products[indexPath.row]
        cell.product = product
        cell.titleLabel.text = product.product.localizedTitle
        cell.priceLabel.text = "\(product.product.price)"
        var buttonTitle: String = "Buy"
        cell.delegate = self
        if #available(iOS 11.2, *) {
            if let _ = product.product.subscriptionPeriod {
                buttonTitle = "Subscribe"
            }
        } else {
            // Fallback on earlier versions
        }
        cell.btnAction.setTitle(buttonTitle, for: .normal)
        return cell

    }

}

extension UITableViewCell {
// Not using static as it wont be possible to override to provide custom storyboardID then
class var storyboardID: String {
    return "\(self)"
  }

static func registerCellXib(with tableview: UITableView) {
    let nib = UINib(nibName: self.storyboardID, bundle: nil)
    tableview.register(nib, forCellReuseIdentifier: self.storyboardID)
  }
}

extension CBSDKProductsTableViewController: ProductTableViewCellDelegate {

    func buyClicked(withProduct: CBProduct) {

        func purchase(customerID: String) {
            self.view.activityStartAnimating(activityColor: UIColor.white, backgroundColor: UIColor.black.withAlphaComponent(0.5))
            addNetWorkObserver()
            CBPurchase.shared.purchaseProduct(product: withProduct, customerId: customerID) { result in
                print(result)
                //When internet is disconnected once the purchase is done with Applestore and Receipt not updated with Chargbee then we should cache the productIdentifer here
                if CBDemoPersistance.isPurchaseProductIDAvailable(){
                    CBDemoPersistance.clearPurchaseIDCache()
                }
                if !CBDemoPersistance.isPurchaseProductIDAvailable(){
                    CBDemoPersistance.saveProductIdentifierOnPurchase(for: withProduct.product.productIdentifier)
                }
               
                switch result {
                case .success(let result):
                    print(result.status)
                    print(result.subscriptionId ?? "")
                    print(result.planId ?? "")
                    DispatchQueue.main.async {
                        self.view.activityStopAnimating()
                        let alertController = UIAlertController(title: "Chargebee", message: "success", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    if CBDemoPersistance.isPurchaseProductIDAvailable(){
                        CBDemoPersistance.clearPurchaseIDCache()
                    }
                    NetworkReachability.shared.stopNotifier()
                case .failure(let error):
                    print(error.localizedDescription)
                    
                    
                    guard let errorDetails = error as? CBError else{
                        print("error has been casted to CBError")
                        return
                    }
                    switch errorDetails {
                    case .operationFailed(errorResponse: let errorResponse),
                            .invalidRequest(errorResponse: let errorResponse),      .paymentFailed(errorResponse: let errorResponse):
                        print("errorResponse",errorResponse)
                        DispatchQueue.main.async {
                            self.view.activityStopAnimating()
                            let alertController = UIAlertController(title: "Chargebee", message: "\(error.localizedDescription)", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(alertController, animated: true, completion: nil)
                        }
                    case .serverNotResponding(errorResponse: let errorResponse):
                        // Retry Validating receipt here with below method in case server is not responding.
                        print("Error:",errorResponse)
                        self.ValidateReceipt(withProduct)
                    }
                }
            }
        }

        let alert = UIAlertController(title: "",
                                      message: "Please enter customerID",
                                      preferredStyle: UIAlertController.Style.alert)
        let defaultAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { (_) in
            if let textFields = alert.textFields, let customerTextField = textFields.first {
                purchase(customerID: customerTextField.text ?? "")
            }
        }
        defaultAction.isEnabled = true
        alert.addAction(defaultAction)
        alert.addTextField { (textField) in
             textField.delegate = self
        }
        present(alert, animated: true, completion: nil)

    }
}
