// by mioe

import Combine
import Foundation

@MainActor
protocol TodoFormPresenterProtocol: AnyObject {
	func didFetchTodo(_ item: TodoListItem)
	func didFinish()
	func didFail(_ error: Error)
}

@MainActor
final class TodoFormPresenter: TodoFormPresenterProtocol, ObservableObject {

	@Published var name: String = ""
	@Published var text: String = ""
	@Published var isDone: Bool = false
	@Published var errorMessage: String?
	@Published private(set) var createdAt: Date?

	let mode: TodoFormMode

	private let interactor: TodoFormInteractorProtocol
	private let router: TodoFormRouterProtocol

	// для режима редактирования
	private var originalName: String?
	private var originalText: String?
	private var originalIsDone: Bool?

	private var didDispatchSave = false
	private var isAutoSaving = false

	init(
		mode: TodoFormMode,
		interactor: TodoFormInteractorProtocol,
		router: TodoFormRouterProtocol
	) {
		self.mode = mode
		self.interactor = interactor
		self.router = router
	}

	var isEditing: Bool {
		mode.editingId != nil
	}

	var canSave: Bool {
		!name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
	}

	private var isDirty: Bool {
		if let originalName, let originalText, let originalIsDone {
			return name != originalName
				|| text != originalText
				|| isDone != originalIsDone
		}
		return canSave
	}

	func viewDidAppear() {
		// подгружаем данные только для режима редактирования и только раз
		guard let id = mode.editingId, createdAt == nil else { return }
		interactor.fetchTodo(id: id)
	}

	func save() {
		guard !didDispatchSave else { return }
		let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmedName.isEmpty else { return }

		didDispatchSave = true

		let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
		let payloadText = trimmedText.isEmpty ? nil : trimmedText

		if let id = mode.editingId {
			interactor.updateTodo(
				id: id,
				name: trimmedName,
				text: payloadText,
				isDone: isDone
			)
		} else {
			interactor.createTodo(name: trimmedName, text: payloadText)
		}
	}

	func saveOnDisappearIfNeeded() {
		guard !didDispatchSave, canSave, isDirty else { return }
		isAutoSaving = true
		save()
	}

	// MARK: - TodoFormPresenterProtocol

	func didFetchTodo(_ item: TodoListItem) {
		name = item.name
		text = item.text ?? ""
		isDone = item.isDone
		createdAt = item.createdAt

		originalName = name
		originalText = text
		originalIsDone = isDone
	}

	func didFinish() {
		guard !isAutoSaving else { return }
		router.dismiss()
	}

	func didFail(_ error: Error) {
		errorMessage = error.localizedDescription
	}
}
