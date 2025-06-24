import SwiftUI
import AppKit

class FloatingTeleprompterWindow {
    static let shared = FloatingTeleprompterWindow()

    private var window: NSWindow?

    func show(text: String, opacity: Double = 0.8, isDarkMode: Bool = true) {
        let hostingController = NSHostingController(rootView:
            TeleprompterView(text: text)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(isDarkMode ? Color.black : Color.white)
                .opacity(opacity)
        )

        let window = NSWindow(
            contentRect: NSRect(x: 200, y: 200, width: 600, height: 400),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],  // ✅ updated style
            backing: .buffered,
            defer: false
        )

        window.title = "Teleprompter"
        window.contentView = hostingController.view
        window.makeKeyAndOrderFront(nil)
        window.isReleasedWhenClosed = false
        window.center()

        self.window = window
    }
}
