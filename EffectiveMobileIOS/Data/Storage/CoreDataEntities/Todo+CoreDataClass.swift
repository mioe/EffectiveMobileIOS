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

	@NSManaged nonisolated public var id: UUID
	@NSManaged nonisolated public var name: String
	@NSManaged nonisolated public var text: String?
	@NSManaged nonisolated public var createdAt: Date
	@NSManaged nonisolated public var done: Bool

	public override nonisolated func awakeFromInsert() {
		super.awakeFromInsert()
		setPrimitiveValue(UUID(), forKey: "id")
		setPrimitiveValue(Date(), forKey: "createdAt")
		setPrimitiveValue(false, forKey: "done")
	}
}

extension Todo: Identifiable {

}
