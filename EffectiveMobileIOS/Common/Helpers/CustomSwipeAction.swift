// by mioe

import SwiftUI

// MARK: - AppAction
/// Модель одного swipe-экшна
struct AppAction: Identifiable {
	let id = UUID()
	let icon: String
	let tint: Color
	let background: Color
	var font: Font = .system(size: 18)
	var width: CGFloat = 64
	let action: (inout Bool) -> Void
}

// MARK: - ActionBuilder
/// Result-builder для удобного объявления списка экшнов без `return` и запятых
@resultBuilder
struct ActionBuilder {
	static func buildBlock(_ components: AppAction...) -> [AppAction] {
		return components
	}
}

// MARK: - ActionConfig
struct ActionConfig {
	var leadingPadding: CGFloat = 0
	var trailingPadding: CGFloat = 0
	var spacing: CGFloat = 0
	var occupiesFullWidth: Bool = true
}

// MARK: - View+swipeActions
extension View {
	@ViewBuilder
	func swipeActions(
		config: ActionConfig = .init(),
		@ActionBuilder actions: () -> [AppAction]
	) -> some View {
		self
			.modifier(CustomSwipeActionModifier(config: config, actions: actions()))
	}
}

// MARK: - SwipeActionSharedData
/// Шарим активный swipe между всеми ячейками - чтобы только одна была раскрыта
@MainActor
@Observable
class SwipeActionSharedData {
	static let shared = SwipeActionSharedData()

	var activeSwipeAction: String?
}

// MARK: - CustomSwipeActionModifier
private struct CustomSwipeActionModifier: ViewModifier {
	var config: ActionConfig
	var actions: [AppAction]
	/// View Properties
	@State private var resetPositionTrigger: Bool = false
	@State private var offsetX: CGFloat = 0
	@State private var lastStoredOffsetX: CGFloat = 0
	@State private var bounceOffset: CGFloat = 0
	@State private var progress: CGFloat = 0
	/// Scroll Properties
	@State private var currentScrollOffset: CGFloat = 0
	@State private var storedScrollOffset: CGFloat?
	var sharedData = SwipeActionSharedData.shared
	@State private var currentID: String = UUID().uuidString
	/// Динамическая высота, чтобы экшн занимал столько же, сколько и сам row
	@State private var contentHeight: CGFloat = 0

	func body(content: Content) -> some View {
		ZStack(alignment: .trailing) {
			/// Фон-«подложка» цвета последнего экшна — виден когда row уезжает влево (в т.ч. overscroll)
			Rectangle()
				.fill(actions.last?.background ?? .clear)
				.frame(
					width: max(-(offsetX + bounceOffset), 0),
					height: contentHeight
				)

			content
				.onGeometryChange(for: CGFloat.self) {
					$0.size.height
				} action: { newValue in
					contentHeight = newValue
				}
				.overlay {
					Rectangle()
						.foregroundStyle(.clear)
						.containerRelativeFrame(
							config.occupiesFullWidth ? .horizontal : .init()
						)
						.overlay(alignment: .trailing) {
							ActionsView()
						}
				}
				.compositingGroup()
				.offset(x: offsetX)
				.offset(x: bounceOffset)
				.gesture(
					PanGesture(
						onBegan: {
							gestureDidBegan()
						},
						onChange: { value in
							gestureDidChange(translation: value.translation)
						},
						onEnded: { value in
							gestureDidEnded(
								translation: value.translation,
								velocity: value.velocity
							)
						}
					)
				)
		}
		.mask {
			Rectangle()
				.containerRelativeFrame(
					config.occupiesFullWidth ? .horizontal : .init()
				)
		}
		.onChange(of: resetPositionTrigger) { oldValue, newValue in
			reset()
		}
		.onGeometryChange(for: CGFloat.self) {
			$0.frame(in: .scrollView).minY
		} action: { newValue in
			if let storedScrollOffset, storedScrollOffset != newValue {
				reset()
			}
		}
		.onChange(of: sharedData.activeSwipeAction) { oldValue, newValue in
			if newValue != currentID && offsetX != 0 {
				reset()
			}
		}
	}

	// MARK: - ActionsView
	@ViewBuilder
	func ActionsView() -> some View {
		ZStack {
			ForEach(actions.indices, id: \.self) { index in
				let action = actions[index]

				GeometryReader { proxy in
					let size = proxy.size
					let spacing = config.spacing * CGFloat(index)
					let offset = (CGFloat(index) * size.width) + spacing

					Button(action: { action.action(&resetPositionTrigger) }) {
						Image(systemName: action.icon)
							.font(action.font)
							.foregroundStyle(action.tint)
							.frame(width: size.width, height: size.height)
							.background(action.background)
					}
					.offset(x: offset * progress)
				}
				.frame(width: action.width, height: contentHeight)
			}
		}
		.visualEffect { content, proxy in
			content
				.offset(x: proxy.size.width)
		}
		.offset(x: config.leadingPadding)
	}

	// MARK: - Gesture handlers
	private func gestureDidBegan() {
		storedScrollOffset = lastStoredOffsetX
		sharedData.activeSwipeAction = currentID
	}

	private func gestureDidChange(translation: CGSize) {
		offsetX = min(
			max(translation.width + lastStoredOffsetX, -maxOffsetWidth),
			0
		)
		progress = -offsetX / maxOffsetWidth

		bounceOffset =
			min(translation.width - (offsetX - lastStoredOffsetX), 0) / 10
	}

	private func gestureDidEnded(translation: CGSize, velocity: CGSize) {
		let endTarget = velocity.width + offsetX

		withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
			if -endTarget > (maxOffsetWidth * 0.6) {
				offsetX = -maxOffsetWidth
				bounceOffset = 0
				progress = 1
			} else {
				/// Reset to intial position
				reset()
			}
		}

		lastStoredOffsetX = offsetX
	}

	private func reset() {
		withAnimation(.snappy(duration: 0.3, extraBounce: 0)) {
			offsetX = 0
			lastStoredOffsetX = 0
			progress = 0
			bounceOffset = 0
		}

		storedScrollOffset = nil
	}

	// MARK: - Helpers
	var maxOffsetWidth: CGFloat {
		let totalActionSize: CGFloat = actions.reduce(.zero) {
			partialResult,
			action in
			partialResult + action.width
		}

		let spacing = config.spacing * CGFloat(actions.count - 1)

		return totalActionSize + spacing + config.leadingPadding
			+ config.trailingPadding
	}
}
