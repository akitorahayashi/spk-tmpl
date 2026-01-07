import AppFeatureDomain
import ComposableArchitecture
import CounterFeatureUI
import SwiftUI

/// The root view of the application, composing child feature views.
public struct ContentView: View {
  @Bindable var store: StoreOf<AppFeature>

  public init(store: StoreOf<AppFeature>) {
    self.store = store
  }

  public var body: some View {
    NavigationStack {
      CounterView(store: self.store.scope(state: \.counter, action: \.counter))
        .navigationTitle("Template App")
    }
    .task {
      self.store.send(.onAppear)
    }
  }
}

#if DEBUG
  #Preview {
    ContentView(
      store: Store(initialState: AppFeature.State()) {
        AppFeature()
      }
    )
  }
#endif
