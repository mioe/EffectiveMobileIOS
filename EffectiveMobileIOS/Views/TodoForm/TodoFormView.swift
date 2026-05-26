// by mioe

import SwiftUI

struct TodoFormView: View {

	@StateObject var presenter: TodoFormPresenter

	@FocusState private var focusedField: Field?

	enum Field: Hashable {
		case name
		case text
	}

	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			VStack(alignment: .leading, spacing: 8) {
				TextField("title", text: $presenter.name)
					.font(.system(size: 34, weight: .bold))
					.lineLimit(1)
					.submitLabel(.next)
					.focused($focusedField, equals: .name)
					.onSubmit {
						focusedField = .text
					}
				if let createdAt = presenter.createdAt {
					DateFormatedText(date: createdAt)
						.font(.system(size: 12))
						.foregroundStyle(.secondary)
				}
			}

			DescriptionEditor()
				.frame(
					maxWidth: .infinity,
					maxHeight: .infinity,
					alignment: .topLeading
				)
		}
		.padding(.horizontal, 20)
		.padding(.top, 8)
		.task {
			presenter.viewDidAppear()
			guard !presenter.isEditing else { return }
			try? await Task.sleep(nanoseconds: 100_000_000)
			focusedField = .name
		}
		.onDisappear {
			presenter.saveOnDisappearIfNeeded()
		}
		.alert(
			"Err",
			isPresented: Binding(
				get: { presenter.errorMessage != nil },
				set: { if !$0 { presenter.errorMessage = nil } }
			),
			presenting: presenter.errorMessage
		) { _ in
			Button("OK", role: .cancel) {}
		} message: { message in
			Text(message)
		}
	}

	@ViewBuilder
	private func DescriptionEditor() -> some View {
		ZStack(alignment: .topLeading) {
			if presenter.text.isEmpty {
				Text("description")
					.font(.system(size: 16))
					.foregroundStyle(.secondary)
					.padding(.horizontal, 5)
					.padding(.top, 8)
					.allowsHitTesting(false)
			}
			TextEditor(text: $presenter.text)
				.font(.system(size: 16))
				.scrollContentBackground(.hidden)
				.padding(.horizontal, -5)  // компенсируем внутренние отступы TextEditor
				.focused($focusedField, equals: .text)
				.onChange(of: presenter.text) { _, newValue in
					guard newValue.contains("\n") else { return }
					presenter.text = newValue.replacingOccurrences(of: "\n", with: "")
					focusedField = nil
					presenter.save()
				}
		}
	}
}
