import SwiftUI
import HomeyMusicKit
import AppKit

struct Slideshow: View {
    let slides: [Slide]
    @State private var index: Int

    init(slides: [Slide], startIndex: Int = 0) {
        self.slides = slides
        self._index = State(initialValue: startIndex)
    }

    var body: some View {
        ZStack {
            // 1) Letter‑boxed content
            SlideDetail(slide: slides[index])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(slides[index].backgroundColor))
                .ignoresSafeArea()

            // 2) Invisible key catcher overlay
            KeyCatcher(
                onPrevious: previous,
                onNext:     next,
                onClose:    close
            )
            .allowsHitTesting(false)
        }
        // Esc (or Cmd–W) closes
        .onExitCommand { close() }
    }

    private func next() {
        if index < slides.count - 1 { index += 1 }
    }

    private func previous() {
        if index > 0 { index -= 1 }
    }

    private func close() {
        NSApp.keyWindow?.close()
    }

    /// Spins up a new full‑screen window containing this slideshow.
    static func present(slides: [Slide], startIndex: Int) {
        let view    = Slideshow(slides: slides, startIndex: startIndex)
        let hosting = NSHostingController(rootView: view.ignoresSafeArea())

        let screenFrame = NSScreen.screens.first?.frame ?? .zero
        let window = NSWindow(
            contentRect:   screenFrame,
            styleMask:     [.titled, .resizable, .fullSizeContentView, .closable],
            backing:       .buffered,
            defer:         false
        )
        window.collectionBehavior         = [.fullScreenPrimary]
        window.titlebarAppearsTransparent = true
        window.titleVisibility            = .hidden
        window.contentViewController      = hosting

        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(hosting)

        let controller = NSWindowController(window: window)
        controller.showWindow(nil)
        DispatchQueue.main.async { window.toggleFullScreen(nil) }
    }
}

private struct KeyCatcher: NSViewRepresentable {
    let onPrevious: () -> Void
    let onNext:     () -> Void
    let onClose:    () -> Void

    func makeNSView(context: Context) -> KeyCatcherView {
        let v = KeyCatcherView()
        v.onPrevious = onPrevious
        v.onNext     = onNext
        v.onClose    = onClose
        return v
    }
    func updateNSView(_ nsView: KeyCatcherView, context: Context) {}

    class KeyCatcherView: NSView {
        var onPrevious: (() -> Void)?
        var onNext:     (() -> Void)?
        var onClose:    (() -> Void)?

        override var acceptsFirstResponder: Bool { true }
        override func viewDidMoveToWindow() {
            window?.makeFirstResponder(self)
        }
        override func keyDown(with event: NSEvent) {
            switch event.keyCode {
            case 123, 126, 116, 115, 51:
                // ← ↑ PageUp Home Delete
                onPrevious?()
            case 124, 125, 121, 119, 49, 36:
                // → ↓ PageDown End Space Return
                onNext?()
            case 53:
                // Esc
                onClose?()
            default:
                super.keyDown(with: event)
            }
        }
    }
}
