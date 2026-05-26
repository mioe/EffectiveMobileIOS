// by mioe

import Foundation
import Combine

@MainActor
protocol TodoListPresenterProtocol: AnyObject {
	func didFetchTodo(_ items: [TodoListItem])
	func didFail(_ error: Error)
	func todosDidChange()
}

@MainActor
final class TodoListPresenter: TodoListPresenterProtocol, ObservableObject {
	
	@Published private(set) var items: [TodoListItem] = []
	@Published private(set) var idle: Bool = true
	
	@Published var searchPrompt: String = ""
	@Published var errorMessage: String?
	
	private let interactor: TodoListInteractorProtocol
	private let router: TodoListRouterProtocol
	private var cancellables = Set<AnyCancellable>()
	
	init(
		interactor: TodoListInteractorProtocol,
		router: TodoListRouterProtocol
	) {
		self.interactor = interactor
		self.router = router
		
		// debounce
		$searchPrompt
			.dropFirst()
			.removeDuplicates()
			.debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.reload()
			}
			.store(in: &cancellables)
	}
	
	var todosCount: String {
		"\(items.count) \(Self.pluralTask(items.count))"
	}
	
	// MARK: - Events/methdos
	
	func viewDidAppear() {
		// Первичная загрузка; повторные обновления приходят через
		// `todosDidChange` и debounce поиска
		guard items.isEmpty else { return }
		reload()
	}
	
	func reload() {
		idle = false
		let query = searchPrompt.trimmingCharacters(in: .whitespacesAndNewlines)
		if query.isEmpty {
			interactor.fetchTodos()
		} else {
			interactor.searchTodos(query: query)
		}
	}
	
	func handleCreateTodo() {
		router.goTodoCreate()
	}
	
	func handleDoneTodo(_ item: TodoListItem) {
		interactor.setTodoDone(id: item.id, isDone: !item.isDone)
	}
	
	func handleSelectTodo(_ item: TodoListItem) {
		router.goTodoEdit(id: item.id)
	}
	
	func handleDeleteTodo(_ item: TodoListItem) {
		interactor.deleteTodo(id: item.id)
	}
	
	// MARK: - TodoListPresenterProtocol
	
	func didFetchTodo(_ items: [TodoListItem]) {
		self.items = items
		idle = true
	}
	
	func didFail(_ error: Error) {
		idle = true
		errorMessage = error.localizedDescription
	}
	
	func todosDidChange() {
		reload()
	}
	
	// MARK: - Helpers
	
	private static func pluralTask(_ count: Int) -> String {
		return count == 1 ? "Todo" : "Todos"
	}
}
