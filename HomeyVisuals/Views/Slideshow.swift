import SwiftUI
import HomeyMusicKit
import AppKit

/// Hosts one `SlideDetail` full‑screen, fixing window sizing.
struct Slideshow: View {
    let slide: Slide

    var body: some View {
        SlideDetail(slide: slide)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(slide.backgroundColor))
            .ignoresSafeArea()
    }

    /// Presents a brand‑new full‑screen window for this slide.
    static func present(slide: Slide) {
        print("▶️ Slideshow.present called – creating window")
        let view    = Slideshow(slide: slide)
        let hosting = NSHostingController(rootView: view.ignoresSafeArea())

        // Use first available screen frame
        let screenFrame = NSScreen.screens.first?.frame ?? .init(x: 0, y: 0, width: 1024, height: 768)
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

        // Ensure window is key and can receive events
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(hosting)

        // Show + toggle into full‑screen
        let controller = NSWindowController(window: window)
        controller.showWindow(nil)
        DispatchQueue.main.async {
            print("▶️ Toggling full screen")
            window.toggleFullScreen(nil)
        }
    }
}
