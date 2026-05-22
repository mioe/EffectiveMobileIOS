// by mioe

public import CoreData
public import Foundation

public typealias TodoCoreDataClassSet = NSSet

@objc(Todo)
public class Todo: NSManagedObject {

}

public typealias TodoCoreDataPropertiesSet = NSSet

extension Todo {

	@nonobjc public class func fetchRequest() -> NSFetchRequest<Todo> {
		return NSFetchRequest<Todo>(entityName: "Todo")
	}

	@NSManaged public var id: UUID
	@NSManaged public var name: String
	@NSManaged public var text: String?
	@NSManaged public var createdAt: Date
	@NSManaged public var done: Bool

	public override nonisolated func awakeFromInsert() {
		super.awakeFromInsert()
		setPrimitiveValue(UUID(), forKey: "id")
		setPrimitiveValue(Date(), forKey: "createdAt")
		setPrimitiveValue(false, forKey: "done")
	}
}

extension Todo: Identifiable {

}
