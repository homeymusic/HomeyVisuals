import SwiftUI
import HomeyMusicKit
import AppKit

/// Full-screen slideshow with key navigation (including Home/End jump),
/// and a “letterbox-only” shrink+fade on close.
struct SlidePresentation: View {
    @Environment(AppContext.self)          var appContext
    @Environment(TonalContext.self)        var tonalContext
    @Environment(InstrumentalContext.self) var instrumentalContext

    let slides: [Slide]
    @State private var index: Int
    @State private var isClosing = false

    init(slides: [Slide], startIndex: Int = 0) {
        self.slides = slides
        self._index = State(initialValue: startIndex)
    }

    var body: some View {
        ZStack {
            // --- Slide area: animate only this part on close ---
            SlideShow(slide: slides[index])
                .scaleEffect(isClosing ? 0.05 : 1.0, anchor: .center)
                .opacity(isClosing ? 0 : 1)

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
        // intercept Esc/Cmd+W
        .onExitCommand { close() }
    }

    // MARK: - Navigation Actions

    private func next() {
        if index < slides.count - 1 {
            index += 1
        } else {
            fancyClose()
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
        // immediate close
        NSApp.keyWindow?.close()
    }

    private func fancyClose() {
        // Animate only the slide (letterbox) to fade & shrink
        withAnimation(.easeInOut(duration: 1 / HomeyMusicKit.goldenRatio)) {
            isClosing = true
        }
        // Then actually close the window after the animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1 / HomeyMusicKit.goldenRatio) {
            NSApp.keyWindow?.close()
        }
    }

    // MARK: - Presentation Helper

    /// Launches a new full-screen window running this slideshow.
    static func present(
        slides: [Slide],
        startIndex: Int,
        appContext: AppContext,
        tonalContext: TonalContext,
        instrumentalContext: InstrumentalContext
    ) {
        let view = SlidePresentation(slides: slides, startIndex: startIndex)
            .environment(appContext)
            .environment(tonalContext)
            .environment(instrumentalContext)

        let hosting = NSHostingController(rootView: view)
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
        // leave window.backgroundColor alone so your letterbox
        // (and any UI chrome) stays visible during the animation
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
            case 123, 126, 116, 51: onPrevious?()  // ← ↑ PgUp Del
            case 124, 125, 121, 49, 36: onNext?()  // → ↓ PgDn Space Return
            case 115: onFirst?()                   // Home
            case 119: onLast?()                    // End
            case 53:  onClose?()                   // Esc
            default:  super.keyDown(with: event)
            }
        }
    }
}
