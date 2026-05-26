// by mioe

import CoreData
import Foundation

extension Notification.Name {
	/// постится после любого изменения задач в хранилище
	static let todosDidChange = Notification.Name("todosDidChange")
}

protocol TodoRepositoryProtocol: AnyObject {
	func fetchTodos(
		completion: @escaping (Result<[TodoListItem], Error>) -> Void
	)
	func searchTodos(
		query: String,
		completion: @escaping (Result<[TodoListItem], Error>) -> Void
	)
	func todo(
		by id: UUID,
		completion: @escaping (Result<TodoListItem?, Error>) -> Void
	)
	func createTodo(
		name: String,
		text: String?,
		completion: @escaping (Result<Void, Error>) -> Void
	)
	func updateTodo(
		id: UUID,
		name: String,
		text: String?,
		isDone: Bool,
		completion: @escaping (Result<Void, Error>) -> Void
	)
	func setTodoDone(
		id: UUID,
		isDone: Bool,
		completion: @escaping (Result<Void, Error>) -> Void
	)
	func deleteTodo(
		id: UUID,
		completion: @escaping (Result<Void, Error>) -> Void
	)
}

final class TodoRepository: TodoRepositoryProtocol {
	private let coreData: CoreDataManager
	private let api: TodoAPIServiceProtocol
	private let defaults: UserDefaults

	private let didImportKey = "didImportInitialTodos"

	init(
		coreData: CoreDataManager = .shared,
		api: TodoAPIServiceProtocol = TodoAPIService(),
		defaults: UserDefaults = .standard
	) {
		self.coreData = coreData
		self.api = api
		self.defaults = defaults
	}

	// MARK: - TodoRepositoryProtocol

	func fetchTodos(completion: @escaping (Result<[TodoListItem], Error>) -> Void)
	{
		// не первый запуск - отдаём то, что сохранено в CoreData
		guard !defaults.bool(forKey: didImportKey) else {
			fetchLocal(predicate: nil, completion: completion)
			return
		}

		// первый запуск -> тянем список из API, сохраняем, затем читаем локально
		api.fetchTodos { [weak self] result in
			guard let self else { return }
			switch result {
			case .failure(let error):
				DispatchQueue.main.async { completion(.failure(error)) }
			case .success(let dtos):
				self.importTodos(dtos) { importResult in
					switch importResult {
					case .failure(let error):
						DispatchQueue.main.async { completion(.failure(error)) }
					case .success:
						self.defaults.set(true, forKey: self.didImportKey)
						self.fetchLocal(predicate: nil, completion: completion)
					}
				}
			}
		}
	}

	func searchTodos(
		query: String,
		completion: @escaping (Result<[TodoListItem], Error>) -> Void
	) {
		let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
		let predicate =
			trimmed.isEmpty
			? nil
			: NSPredicate(
				format: "name CONTAINS[cd] %@ OR text CONTAINS[cd] %@",
				trimmed,
				trimmed
			)
		fetchLocal(predicate: predicate, completion: completion)
	}

	func todo(
		by id: UUID,
		completion: @escaping (Result<TodoListItem?, Error>) -> Void
	) {
		let context = coreData.newBackgroundContext()
		context.perform {
			do {
				let todo = try context.fetch(Self.request(for: id)).first
				let item = todo.map(TodoListItem.init(todo:))
				DispatchQueue.main.async { completion(.success(item)) }
			} catch {
				DispatchQueue.main.async { completion(.failure(error)) }
			}
		}
	}

	func createTodo(
		name: String,
		text: String?,
		completion: @escaping (Result<Void, Error>) -> Void
	) {
		let context = coreData.newBackgroundContext()
		context.perform {
			let todo = Todo(context: context)
			todo.id = UUID()
			todo.name = name
			todo.text = text
			todo.createdAt = Date()
			todo.done = false
			self.save(context, completion: completion)
		}
	}

	func updateTodo(
		id: UUID,
		name: String,
		text: String?,
		isDone: Bool,
		completion: @escaping (Result<Void, Error>) -> Void
	) {
		mutate(id: id, completion: completion) { todo in
			todo.name = name
			todo.text = text
			todo.done = isDone
		}
	}

	func setTodoDone(
		id: UUID,
		isDone: Bool,
		completion: @escaping (Result<Void, Error>) -> Void
	) {
		mutate(id: id, completion: completion) { $0.done = isDone }
	}

	func deleteTodo(id: UUID, completion: @escaping (Result<Void, Error>) -> Void)
	{
		let context = coreData.newBackgroundContext()
		context.perform {
			do {
				if let todo = try context.fetch(Self.request(for: id)).first {
					context.delete(todo)
				}
				self.save(context, completion: completion)
			} catch {
				DispatchQueue.main.async { completion(.failure(error)) }
			}
		}
	}

	// MARK: - Private

	private func importTodos(
		_ dtos: [TodoDTO],
		completion: @escaping (Result<Void, Error>) -> Void
	) {
		let context = coreData.newBackgroundContext()
		context.perform {
			let importedAt = Date()
			for dto in dtos {
				let todo = Todo(context: context)
				todo.id = UUID()
				todo.name = "Todo #\(dto.id)"
				todo.text = dto.todo
				todo.done = dto.completed
				todo.createdAt = importedAt
			}
			do {
				try context.save()
				DispatchQueue.main.async { completion(.success(())) }
			} catch {
				DispatchQueue.main.async { completion(.failure(error)) }
			}
		}
	}

	private func fetchLocal(
		predicate: NSPredicate?,
		completion: @escaping (Result<[TodoListItem], Error>) -> Void
	) {
		let context = coreData.newBackgroundContext()
		context.perform {
			let request = Todo.fetchRequest()
			request.predicate = predicate
			request.sortDescriptors = [
				NSSortDescriptor(key: "createdAt", ascending: false)
			]
			do {
				let items = try context.fetch(request).map(TodoListItem.init(todo:))
				DispatchQueue.main.async { completion(.success(items)) }
			} catch {
				DispatchQueue.main.async { completion(.failure(error)) }
			}
		}
	}

	private func mutate(
		id: UUID,
		completion: @escaping (Result<Void, Error>) -> Void,
		_ change: @escaping (Todo) -> Void
	) {
		let context = coreData.newBackgroundContext()
		context.perform {
			do {
				guard let todo = try context.fetch(Self.request(for: id)).first else {
					DispatchQueue.main.async { completion(.success(())) }
					return
				}
				change(todo)
				self.save(context, completion: completion)
			} catch {
				DispatchQueue.main.async { completion(.failure(error)) }
			}
		}
	}

	/// сохраняет контекст и уведомляет подписчиков, вызывается внутри `perform`
	private func save(
		_ context: NSManagedObjectContext,
		completion: @escaping (Result<Void, Error>) -> Void
	) {
		do {
			if context.hasChanges {
				try context.save()
			}
			DispatchQueue.main.async {
				NotificationCenter.default.post(name: .todosDidChange, object: nil)
				completion(.success(()))
			}
		} catch {
			DispatchQueue.main.async { completion(.failure(error)) }
		}
	}

	private static func request(for id: UUID) -> NSFetchRequest<Todo> {
		let request = Todo.fetchRequest()
		request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
		request.fetchLimit = 1
		return request
	}
}
