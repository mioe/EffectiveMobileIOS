// by mioe

import Foundation

protocol TodoListInteractorProtocol: AnyObject {
	func fetchTodos()
	func searchTodos(query: String)
	func setTodoDone(id: UUID, isDone: Bool)
	func deleteTodo(id: UUID)
}

class TodoListInteractor: TodoListInteractorProtocol {
	
	weak var presenter: TodoListPresenterProtocol?
	
	private let repository: TodoRepositoryProtocol
	private var changeObserver: NSObjectProtocol?
	
	init(repository: TodoRepositoryProtocol) {
		self.repository = repository
		
		// любое изменение задач (в том числе из модуля формы) - повод
		// перечитать список
		changeObserver = NotificationCenter.default.addObserver(
			forName: .todosDidChange,
			object: nil,
			queue: .main
		) { [weak self] _ in
			self?.presenter?.todosDidChange()
		}
	}
	
	func fetchTodo() {
		guard let url = URL(string: "") else {
			return
		}
		
		URLSession.shared.dataTask(with: url) { data, _, _ in
			guard let data else {
				return
			}
			
			do {
				let res = try? JSONDecoder()
			} catch {
				print(error.localizedDescription)
			}
		}
	}
}
