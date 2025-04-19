import SwiftUI

struct Thumbnail<Content: View>: View {
    let content: Content
    let reloadTrigger: AnyHashable

    @State private var thumbnail: Image?

    var body: some View {
        GeometryReader { geo in
            Group {
                if let img = thumbnail {
                    img
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Color.clear
                }
            }
            .onAppear        { render(for: geo.size) }
            .onChange(of: reloadTrigger) {render(for: geo.size) }
            .onChange(of: geo.size)       {_, newSize in render(for: newSize) }
        }
    }

    private func render(for size: CGSize) {
        // render at 3× for sharpness
        let renderSize = CGSize(width: size.width * 3,
                                height: size.height * 3)
        let renderer = ImageRenderer(content:
            content
                .frame(width: renderSize.width,
                       height: renderSize.height)
        )

        // on macOS we'll always use the cgImage output
        if let cgImage = renderer.cgImage {
            thumbnail = Image(decorative: cgImage, scale: 1)
        }
    }
}
