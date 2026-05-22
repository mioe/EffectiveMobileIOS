// by mioe

import Foundation

protocol TodoListInteractorProtocol: AnyObject {
	func fetchTodo()
}

class TodoListInteractor: TodoListInteractorProtocol {
	weak var presenter: TodoListPresenter?
	
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
