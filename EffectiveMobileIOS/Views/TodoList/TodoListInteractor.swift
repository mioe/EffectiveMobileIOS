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
			MainActor.assumeIsolated {
				self?.presenter?.todosDidChange()
			}
		}
	}

	deinit {
		if let changeObserver {
			NotificationCenter.default.removeObserver(changeObserver)
		}
	}

	func fetchTodos() {
		repository.fetchTodos { [weak self] result in
			self?.handle(result)
		}
	}

	func searchTodos(query: String) {
		repository.searchTodos(query: query) { [weak self] result in
			self?.handle(result)
		}
	}

	func setTodoDone(id: UUID, isDone: Bool) {
		repository.setTodoDone(id: id, isDone: isDone) { [weak self] result in
			if case .failure(let error) = result {
				self?.presenter?.didFail(error)
			}
			// При успехе список обновит нотификация `.todosDidChange`.
		}
	}

	func deleteTodo(id: UUID) {
		repository.deleteTodo(id: id) { [weak self] result in
			if case .failure(let error) = result {
				self?.presenter?.didFail(error)
			}
		}
	}

	private func handle(_ result: Result<[TodoListItem], Error>) {
		switch result {
		case .success(let items):
			presenter?.didFetchTodo(items)
		case .failure(let error):
			presenter?.didFail(error)
		}
	}
}
