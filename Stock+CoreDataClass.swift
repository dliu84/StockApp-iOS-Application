

import Foundation
import CoreData

enum StockStatus: Int {
    case inactive = 0
    case active = 1
}

@objc(Stock)
public class Stock: NSManagedObject {
    var stockStatus: StockStatus {
            get {
                return StockStatus(rawValue: Int(status)) ?? .inactive
            }
            set {
                status = Int16(newValue.rawValue)
            }
        }
}
