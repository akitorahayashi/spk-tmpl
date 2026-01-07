import ComposableArchitecture
import CounterFeatureDomain
import SwiftUI

/// The UI for the counter feature, bound to a TCA store.
public struct CounterView: View {
  @Bindable var store: StoreOf<CounterFeature>

  public init(store: StoreOf<CounterFeature>) {
    self.store = store
  }

  public var body: some View {
    VStack(spacing: 24) {
      Text("Count: \(self.store.count)")
        .font(.system(size: 48, weight: .bold, design: .rounded))
        .monospacedDigit()

      HStack(spacing: 16) {
        Button {
          self.store.send(.decrementButtonTapped)
        } label: {
          Image(systemName: "minus.circle.fill")
            .font(.system(size: 44))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Decrement")

        Button {
          self.store.send(.resetButtonTapped)
        } label: {
          Image(systemName: "arrow.counterclockwise.circle.fill")
            .font(.system(size: 44))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Reset")

        Button {
          self.store.send(.incrementButtonTapped)
        } label: {
          Image(systemName: "plus.circle.fill")
            .font(.system(size: 44))
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Increment")
      }
      .foregroundStyle(.tint)
    }
    .padding()
  }
}

#if DEBUG
  #Preview {
    CounterView(
      store: Store(initialState: CounterFeature.State(count: 5)) {
        CounterFeature()
      }
    )
  }
#endif
