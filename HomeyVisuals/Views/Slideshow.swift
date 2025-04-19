import SwiftUI
import HomeyMusicKit
import AppKit

/// Full‑screen slideshow with key navigation (including Home/End jump).
struct Slideshow: View {
    let slides: [Slide]
    @State private var index: Int

    init(slides: [Slide], startIndex: Int = 0) {
        self.slides = slides
        self._index = State(initialValue: startIndex)
    }

    var body: some View {
        ZStack {
            // Render the slide
            SlideDetail(slide: slides[index])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(slides[index].backgroundColor))
                .ignoresSafeArea()

            // Invisible overlay for key handling
            KeyCatcher(
                onPrevious: previous,
                onNext:     next,
                onClose:    close,
                onFirst:    goToFirst,
                onLast:     goToLast
            )
            .allowsHitTesting(false)
        }
        // Esc or Cmd+W closes
        .onExitCommand { close() }
    }

    // MARK: - Navigation Actions

    private func next() {
        if index < slides.count - 1 {
            index += 1
        } else {
            close()
        }
    }

    private func previous() {
        if index > 0 {
            index -= 1
        }
    }

    private func goToFirst() {
        index = 0
    }

    private func goToLast() {
        index = slides.count - 1
    }

    // MARK: - Close

    private func close() {
        guard let window = NSApp.keyWindow else { return }
        
        // pick how small you want it to get:
        let finalSize: CGFloat = 20
        
        // compute a tiny rect centered in the window’s current frame:
        let currentFrame = window.frame
        let centerX = currentFrame.midX - finalSize/2
        let centerY = currentFrame.midY - finalSize/2
        let targetFrame = NSRect(x: centerX,
                                 y: centerY,
                                 width: finalSize,
                                 height: finalSize)
        
        // ensure the window is layer‑backed so frame/alpha animations run smoothly:
        window.contentView?.wantsLayer = true
        window.backgroundColor = .black
        
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 1.0
            // simultaneously fade out…
            window.animator().alphaValue = 0
            // …and shrink to the tiny rect
            window.animator().setFrame(targetFrame, display: true)
        } completionHandler: {
            window.close()
        }
    }
    // MARK: - Presentation Helper

    /// Spins up a new full‑screen window running this slideshow.
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

// MARK: - KeyCatcher

private struct KeyCatcher: NSViewRepresentable {
    let onPrevious: () -> Void
    let onNext:     () -> Void
    let onClose:    () -> Void
    let onFirst:    () -> Void
    let onLast:     () -> Void

    func makeNSView(context: Context) -> KeyCatcherView {
        let view = KeyCatcherView()
        view.onPrevious = onPrevious
        view.onNext     = onNext
        view.onClose    = onClose
        view.onFirst    = onFirst
        view.onLast     = onLast
        return view
    }

    func updateNSView(_ nsView: KeyCatcherView, context: Context) {}

    class KeyCatcherView: NSView {
        var onPrevious: (() -> Void)?
        var onNext:     (() -> Void)?
        var onClose:    (() -> Void)?
        var onFirst:    (() -> Void)?
        var onLast:     (() -> Void)?

        override var acceptsFirstResponder: Bool { true }
        override func viewDidMoveToWindow() {
            window?.makeFirstResponder(self)
        }

        override func keyDown(with event: NSEvent) {
            switch event.keyCode {
            case 123, 126, 116, 51:
                // ← (123), ↑ (126), PageUp (116), Delete (51)
                onPrevious?()
            case 124, 125, 121, 49, 36:
                // → (124), ↓ (125), PageDown (121), Space (49), Return (36)
                onNext?()
            case 115:
                // Home
                onFirst?()
            case 119:
                // End
                onLast?()
            case 53:
                // Esc
                onClose?()
            default:
                super.keyDown(with: event)
            }
        }
    }
}
