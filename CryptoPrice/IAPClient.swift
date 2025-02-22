import Foundation
import StoreKit
import RevenueCat

protocol Purchasing {}

// TODO: Remove below on next release

@available(iOS, introduced: 1.0, deprecated: 1.3, message: "Replaced by using RevenueCat instead")
public class InAppPurchaseClient: NSObject, Purchasing {
    private let purchasedProductsKey = "in-app-purchase_products"

    fileprivate var paymentQueue: SKPaymentQueue
    fileprivate var productRequest: SKProductsRequest?

    public var products: [SKProduct]
    public var purchasedProducts: [SKProduct]

    public var paymentCallback: (([SKProduct], Error?) -> Void)?
    public var restoreCallback: ((Bool) -> Void)?
    public var productsCallback: (([SKProduct]) -> Void)?

    override public init() {
        paymentQueue = SKPaymentQueue.default()
        products = []
        purchasedProducts = []
        super.init()
        paymentQueue.delegate = self
        paymentQueue.add(self)
        
        if let savedProducts = UserDefaults.standard.array(forKey: purchasedProductsKey) as? [SKProduct] {
            purchasedProducts = savedProducts
        }
    }
    
    deinit {
        UserDefaults.standard.set(purchasedProducts, forKey: purchasedProductsKey)
        paymentQueue.remove(self)
    }
    
    public func fetchProducts(identifiers: [String]) {
        let request = SKProductsRequest(productIdentifiers: Set(identifiers))
        request.delegate = self
        request.start()
        productRequest = request
    }

    public func purchase(product: SKProduct) {
        purchaseUnlimited()
    }

    public func purchaseUnlimited() {
        Purchases.shared.getProducts([RevenueCat.unlimitedProductIdentifier]) { results in
            for product in results {
                print("\(product.subscriptionPeriod?.value) \(product.subscriptionPeriod?.unit)")

                Purchases.shared.purchase(product: product) { transaction, info, error, bool in
                    if let error = error {
                        print(error.localizedDescription)
                    }

                    print(transaction?.transactionIdentifier)
                }
            }
        }
    }

    public func restorePurchase() { // There must be some functionality for the user to restore non-consumable IAP's
        paymentQueue.restoreCompletedTransactions()
        Purchases.shared.restorePurchases { info, error in
            guard error != nil else {
                print(error?.localizedDescription)
                return
            }

            guard let info = info else {
                self.restoreCallback?(false)
                return
            }

            // TODO: Restore successful! Take action
            //       ...
        }
    }

    public func isPurchased(identifier: String) -> Bool {
        guard let product = (products.filter { (p) -> Bool in
            return p.productIdentifier == identifier
            }.first) else { return false }

        return purchasedProducts.contains(product)
    }
    
    public func canMakePayments() -> Bool { // Important to implement a way to let the user know if payments cannot be made
        return SKPaymentQueue.canMakePayments()
    }
}

extension InAppPurchaseClient: SKPaymentQueueDelegate {
    public func paymentQueue(_ paymentQueue: SKPaymentQueue, shouldContinue transaction: SKPaymentTransaction, in newStorefront: SKStorefront) -> Bool {
        return true
    }
}

extension InAppPurchaseClient: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        #if DEBUG
        print("Log: Got \(response.products.count) products.")
        print("Log: Invalid product ids \(response.invalidProductIdentifiers)")
        #endif
        products = response.products

        DispatchQueue.main.async {
            self.productsCallback?(self.products)
        }
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Log: Failed to retrieve products.")
    }
    
    public func requestDidFinish(_ request: SKRequest) {
        productRequest = nil
    }
}

extension InAppPurchaseClient: SKPaymentTransactionObserver {
    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions where transaction.transactionState == .purchased ||
            transaction.transactionState == .restored {
                if let product = (products.first { (prod) -> Bool in
                    prod.productIdentifier == transaction.payment.productIdentifier
                }) {
                    DispatchQueue.main.async { [weak self] in
                        guard let `self` = self else { return }
                        self.purchasedProducts.append(product)
                        self.paymentCallback?(self.purchasedProducts, transaction.error)
                    }
                }
                queue.finishTransaction(transaction)
        }
        
        for transaction in transactions where transaction.transactionState == .failed {
            DispatchQueue.main.async {
                self.paymentCallback?(self.purchasedProducts, transaction.error)
            }
            queue.finishTransaction(transaction)
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            self.paymentCallback?(self.purchasedProducts, transaction.error)
        }
    }
    
    public func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        self.restoreCallback?(false)
    }
    
    public func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        self.restoreCallback?(true)
    }
}
