import SwiftUI

@available(iOS 16, macOS 13, *)
struct ViewThumbnail<Content: View>: View {
    let content: Content
    let size: CGSize

    @State private var thumbnail: Image?

    var body: some View {
        Group {
            if let thumb = thumbnail {
                thumb
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                // placeholder while rendering
                Color.clear
            }
        }
        .frame(width: size.width, height: size.height)
        .onAppear { render() }
    }

    private func render() {
        var renderer = ImageRenderer(content:
            content
                .frame(width: size.width, height: size.height)
        )
        // match device scale for crispness
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
