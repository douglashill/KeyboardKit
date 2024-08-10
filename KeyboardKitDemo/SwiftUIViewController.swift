// Douglas Hill, November 2022

import SwiftUI
import KeyboardKit

@MainActor func swiftUIExampleViewController() -> UIViewController {
    return UIHostingController(rootView: ExampleView())
}

private struct ExampleView: View {

    @State var message = "This example demonstrates using KeyboardKit and SwiftUI’s KeyboardShortcut to set up standard key equivalents for buttons."

    var body: some View {
        NavigationView {
            Text(message)
                .navigationTitle("Swift UI Example")
                .toolbar {
                    // TODO: These buttons are missing accessibility labels and titles for the large content viewer.
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            message = "Deleted!"
                        } label: {
                            Image(systemName: "trash")
                        }
                        .keyboardShortcut(.KeyboardKit.delete)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            message = "Refreshed!"
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .keyboardShortcut(.KeyboardKit.refresh)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            message = "Bookmarks?"
                        } label: {
                            Image(systemName: "book")
                        }
                        .keyboardShortcut(.KeyboardKit.bookmarks)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            message = "Smaller"
                        } label: {
                            Image(systemName: "minus.magnifyingglass")
                        }
                        .keyboardShortcut(.KeyboardKit.zoomOut)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            message = "Bigger"
                        } label: {
                            Image(systemName: "plus.magnifyingglass")
                        }
                        .keyboardShortcut(.KeyboardKit.zoomIn)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            message = "New"
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .keyboardShortcut(.KeyboardKit.new)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            message = "Saved!"
                        }
                        .keyboardShortcut(.KeyboardKit.save)
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
}
