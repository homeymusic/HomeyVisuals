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
        let screenSize = screenSize
        let slideAspect = slideSize.width / slideSize.height
        let screenAspect = screenSize.width / screenSize.height
        
        if slideAspect > screenAspect {
            let w = screenSize.width
            return CGSize(width: w, height: w / slideAspect)
        } else {
            let h = screenSize.height
            return CGSize(width: h * slideAspect, height: h)
        }
    }
    
    private var screenSize: CGSize {
        guard
            let screen = NSScreen.main,
            screen.frame.width  > 0,
            screen.frame.height > 0
        else {
            return CGSize(width: 3840, height: 2160)
        }
        return screen.frame.size
    }
    
}
