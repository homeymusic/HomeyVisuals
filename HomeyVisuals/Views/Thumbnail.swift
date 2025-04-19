import SwiftUI
import HomeyMusicKit

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
            .onAppear { render(for: geo.size) }
            .onChange(of: reloadTrigger) {render(for: geo.size) }
            .onChange(of: geo.size) {_, newSize in render(for: newSize) }
        }
    }
    
    private func render(for size: CGSize) {
        let renderSize = traditionalRenderSize(for: size)
        let renderer = ImageRenderer(content:
            content
              .frame(width:  renderSize.width,
                     height: renderSize.height)
        )
        if let cgImage = renderer.cgImage {
            thumbnail = Image(decorative: cgImage, scale: 1)
        }
    }
    
    private func traditionalRenderSize(for slideSize: CGSize) -> CGSize {
        let screen4k = CGSize(width: 3840, height: 2160)
        
        // slide aspect ratio and screen aspect ratio
        let slideAspect  = slideSize.width / slideSize.height
        let screenAspect = screen4k.width    / screen4k.height
        
        if slideAspect > screenAspect {
            // slide is “wider” than screen: fill width, letter‑box vertically
            let w = screen4k.width
            let h = w / slideAspect
            return CGSize(width: w, height: h)
        } else {
            // slide is “taller” than screen: fill height, pillar‑box horizontally
            let h = screen4k.height
            let w = h * slideAspect
            return CGSize(width: w, height: h)
        }
    }

}
