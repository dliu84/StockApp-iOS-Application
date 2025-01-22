

import Foundation
import CoreData


extension Stock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stock> {
        return NSFetchRequest<Stock>(entityName: "Stock")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var performanceID: String?
    @NSManaged public var status: Int16
    @NSManaged public var timeStamp: Date?
    @NSManaged public var rank: Int16
    @NSManaged public var isFavorite: Bool
}

extension Stock : Identifiable {

}
