import SwiftUI
import AVFoundation
import HomeyMusicKit

struct CameraView: View {
    let cameraDeviceID: String?
    let isThumbnail: Bool

    var body: some View {
        if let device = CameraView.device(for: cameraDeviceID) {
            if isThumbnail {
                VideoIcon()
            } else {
                CameraFeed(device: device)
                    .id(device.uniqueID)
            }
        } else {
            VideoIcon(isSlashed: true)
        }
    }
    
    /// Which device types to show on each platform
    private static var deviceTypes: [AVCaptureDevice.DeviceType] {
    #if os(macOS)
        return [.builtInWideAngleCamera, .external]
    #else
        return [.builtInWideAngleCamera, .builtInUltraWideCamera, .builtInTelephotoCamera]
    #endif
    }

    /// All cameras the system can enumerate today
    public static var availableDevices: [AVCaptureDevice] {
        AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .unspecified
        ).devices
    }
    
    /// Look up a device by its uniqueID (or `nil` if none)
    public static func device(for uniqueID: String?) -> AVCaptureDevice? {
        guard let id = uniqueID else { return nil }
        return availableDevices.first { $0.uniqueID == id }
    }


}

/// A full‑screen (or cropped) live camera feed.
public struct CameraFeed: NSViewRepresentable {
    public let device: AVCaptureDevice

    public init(device: AVCaptureDevice) {
        self.device = device
    }

    public func makeNSView(context: Context) -> some NSView {
        let view = NSView(frame: .zero)
        let session = AVCaptureSession()
        session.sessionPreset = .high

        guard let input = try? AVCaptureDeviceInput(device: device) else {
            return view
        }
        session.beginConfiguration()
        session.addInput(input)
        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        view.wantsLayer = true
        view.layer = preview
        session.commitConfiguration()
        session.startRunning()
        return view
    }

    public func updateNSView(_ nsView: NSViewType, context: Context) { }

}

struct VideoIcon: View {
    let isSlashed: Bool
    
    init(isSlashed: Bool = false) {
        self.isSlashed = isSlashed
    }
    
    var body: some View {
        let symbolSystemName = isSlashed ? "video.slash.fill" : "video.fill"
        ZStack {
            Color.systemGray
            GeometryReader { geom in
                let ratio: CGFloat = CGFloat(1 / HomeyMusicKit.goldenRatio)
                let side = min(geom.size.width, geom.size.height) * ratio
                
                Image(systemName: symbolSystemName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: side, height: side)
                    .foregroundStyle(Color.systemGray6)
                    .position(x: geom.size.width/2, y: geom.size.height/2)
            }
        }
    }
}

