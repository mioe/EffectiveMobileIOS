// by mioe

import Foundation

protocol TodoFormInteractorProtocol: AnyObject {
	func fetchTodo(id: UUID)
	func createTodo(name: String, text: String?)
	func updateTodo(id: UUID, name: String, text: String?, isDone: Bool)
}

@MainActor
final class TodoFormInteractor: TodoFormInteractorProtocol {

	weak var presenter: TodoFormPresenterProtocol?

	private let repository: TodoRepositoryProtocol

	init(repository: TodoRepositoryProtocol) {
		self.repository = repository
	}

	func fetchTodo(id: UUID) {
		repository.todo(by: id) { [weak self] result in
			switch result {
			case .success(let item):
				if let item {
					self?.presenter?.didFetchTodo(item)
				}
			case .failure(let error):
				self?.presenter?.didFail(error)
			}
		}
	}

	func createTodo(name: String, text: String?) {
		repository.createTodo(name: name, text: text) { [weak self] result in
			self?.handle(result)
		}
	}

	func updateTodo(id: UUID, name: String, text: String?, isDone: Bool) {
		repository.updateTodo(id: id, name: name, text: text, isDone: isDone) {
			[weak self] result in
			self?.handle(result)
		}
	}

	private func handle(_ result: Result<Void, Error>) {
		switch result {
		case .success:
			presenter?.didFinish()
		case .failure(let error):
			presenter?.didFail(error)
		}
	}
}
