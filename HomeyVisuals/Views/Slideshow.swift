//
//  Slideshow.swift
//

import SwiftUI
import HomeyMusicKit

@available(macOS 15.0, iOS 16.0, *)
struct Slideshow: View {
    let slides: [Slide]
    @Binding var isPresented: Bool      // for iOS dismissal
    @State private var index: Int       // current slide index
    @Environment(\.dismiss) private var dismiss  // fallback for macOS

    init(slides: [Slide], startIndex: Int = 0, isPresented: Binding<Bool>) {
        self.slides = slides
        self._index = State(initialValue: startIndex)
        self._isPresented = isPresented
    }

    var body: some View {
        ZStack {
            // 1) Your full‑screen slide
            SlideDetail(slide: slides[index])
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(slides[index].backgroundColor))
                .ignoresSafeArea()

            // 2) Invisible key‑event catcher on top
            #if os(macOS)
            KeyCatcher(
                onPrevious: previous,
                onNext:     next,
                onClose:    closeSlideshow
            )
            .allowsHitTesting(false)     // don't intercept mouse clicks
            #endif
        }
        // 3) Escape key on iOS / tvOS also works
        .onExitCommand { closeSlideshow() }
    }

    // MARK: - Navigation

    private func next() {
        guard index < slides.count - 1 else { return }
        index += 1
    }

    private func previous() {
        guard index > 0 else { return }
        index -= 1
    }

    // MARK: - Dismissal

    private func closeSlideshow() {
        #if os(iOS)
        isPresented = false
        #else
        dismiss()
        #endif
    }
}

// MARK: - macOS presentation helper

#if os(macOS)
extension Slideshow {
    /// Presents a brand‑new full‑screen window running our Slideshow.
    static func present(slides: [Slide], startIndex: Int) {
        // Build the view
        let view = Slideshow(
            slides:      slides,
            startIndex:  startIndex,
            isPresented: .constant(false)
        )

        // Host in NSHostingController
        let hosting = NSHostingController(rootView: view.ignoresSafeArea())

        // Make the window
        let screenFrame = NSScreen.main?.frame ?? .zero
        let window = NSWindow(
            contentRect:   screenFrame,
            styleMask:     [.titled, .fullSizeContentView, .closable],
            backing:       .buffered,
            defer:         false
        )
        window.collectionBehavior      = [.fullScreenPrimary]
        window.titlebarAppearsTransparent = true
        window.titleVisibility        = .hidden
        window.contentViewController  = hosting

        // Ensure it’s key and first responder for key events
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(hosting)

        // Close on exit full‑screen
        NotificationCenter.default.addObserver(
            forName: NSWindow.willExitFullScreenNotification,
            object: window,
            queue: .main
        ) { _ in window.close() }

        // Show and toggle into full‑screen
        let wc = NSWindowController(window: window)
        wc.showWindow(nil)
        DispatchQueue.main.async { window.toggleFullScreen(nil) }
    }
}
#endif

// MARK: - Key‑event catcher for macOS

#if os(macOS)
import AppKit

/// An NSViewRepresentable that grabs keyDown events
/// and dispatches them to your closures.
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

    func updateNSView(_: KeyCatcherView, context: Context) {}

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
                // ← 123, ↑ 126, PageUp 116, Home 115, Delete 51
                onPrevious?()
            case 124, 125, 121, 119, 49, 36:
                // → 124, ↓ 125, PageDown 121, End 119, Space 49, Return 36
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
#endif
