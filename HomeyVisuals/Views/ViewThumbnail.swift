// HomeyVisuals/Views/ViewThumbnail.swift

import SwiftUI

@available(iOS 16, macOS 13, *)
struct ViewThumbnail<Content: View>: View {
    let content: Content
    let displaySize: CGSize
    let reloadTrigger: AnyHashable

    @State private var thumbnail: Image?

    var body: some View {
        Group {
            if let img = thumbnail {
                img
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Color.clear
            }
        }
        .frame(width: displaySize.width, height: displaySize.height)
        .onAppear { render() }
        .onChange(of: reloadTrigger) { render() }
    }

    private func render() {
        // Render at 3× for layout fidelity
        let renderSize = CGSize(width: displaySize.width * 3,
                                height: displaySize.height * 3)

        var renderer = ImageRenderer(content:
            content
                .frame(width: renderSize.width,
                       height: renderSize.height)
        )

        // Keep a high-enough pixel density
        #if os(iOS)
        renderer.scale = UIScreen.main.scale
        #endif

        #if os(iOS)
        if let uiImage = renderer.uiImage {
            thumbnail = Image(uiImage: uiImage)
        }
        #else
        if let cg = renderer.cgImage {
            thumbnail = Image(decorative: cg, scale: 1)
        }
        #endif
    }
}
