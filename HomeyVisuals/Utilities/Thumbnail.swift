// Thumbnail.swift
import SwiftUI
import AppKit
import HomeyMusicKit

/// Renders the *raw* slide at its device‑presentation size,
/// then downscales to fit this container.
struct Thumbnail<Content: View>: View {
    let content: Content
    let reloadTrigger: AnyHashable
    let aspect: CGFloat

    @State private var thumbnail: Image?

    var body: some View {
        GeometryReader { geo in
            Group {
                if let img = thumbnail {
                    img
                        .resizable()
                        .aspectRatio(aspect, contentMode: .fit)
                } else {
                    Color.clear
                }
            }
            .onAppear { render(for: geo.size) }
            // now using the two‑parameter onChange signature:
            .onChange(of: reloadTrigger) { _, _ in
                render(for: geo.size)
            }
            .onChange(of: geo.size) { _, newSize in
                render(for: newSize)
            }
        }
    }

    private func render(for containerSize: CGSize) {
        // 1) Compute the slide’s full‑screen presentation size:
        let devSize = deviceSlideSize(aspect: aspect)

        // 2) Figure how to scale that into this container:
        let scale = min(containerSize.width  / devSize.width,
                        containerSize.height / devSize.height)
        let targetSize = CGSize(width:  devSize.width  * scale,
                                height: devSize.height * scale)

        // 3) Snapshot the raw slide content letter‑boxed at devSize
        let snapshot = content
            .aspectRatio(aspect, contentMode: .fit)
            .frame(width: devSize.width, height: devSize.height)

        // 4) Render & store the image
        var renderer = ImageRenderer(content: snapshot)
        renderer.proposedSize = ProposedViewSize(
            width:  targetSize.width,
            height: targetSize.height
        )
        if let cg = renderer.cgImage {
            thumbnail = Image(decorative: cg, scale: 1)
        }
    }
}
