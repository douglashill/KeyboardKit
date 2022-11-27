// Douglas Hill, November 2022

import UIKit
import SwiftUI
import KeyboardKit

func swiftUIExampleViewController() -> UIViewController {
    return UIHostingController(rootView: ExampleView())
}

struct ExampleView: View {

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
                        .keyboardShortcut(KeyboardAction.delete.keyboardShortcut)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            message = "Refreshed!"
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                        .keyboardShortcut(KeyboardAction.refresh.keyboardShortcut)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            message = "Bookmarks?"
                        } label: {
                            Image(systemName: "book")
                        }
                        .keyboardShortcut(KeyboardAction.bookmarks.keyboardShortcut)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            message = "Smaller"
                        } label: {
                            Image(systemName: "minus.magnifyingglass")
                        }
                        .keyboardShortcut(KeyboardAction.zoomOut.keyboardShortcut)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            message = "Bigger"
                        } label: {
                            Image(systemName: "plus.magnifyingglass")
                        }
                        .keyboardShortcut(KeyboardAction.zoomIn.keyboardShortcut)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            message = "New"
                        } label: {
                            Image(systemName: "square.and.pencil")
                        }
                        .keyboardShortcut(KeyboardAction.new.keyboardShortcut)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            message = "Saved!"
                        }
                        .keyboardShortcut(KeyboardAction.save.keyboardShortcut)
                    }
                }
        }
        .navigationViewStyle(.stack)
    }
}
