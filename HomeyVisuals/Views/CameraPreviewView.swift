import SwiftUI
import AVFoundation

struct CameraPreviewView: NSViewRepresentable {
    let device: AVCaptureDevice

    func makeNSView(context: Context) -> some NSView {
        let view = NSView(frame: .zero)
        let session = AVCaptureSession()
        session.sessionPreset = .high

        let input = try! AVCaptureDeviceInput(device: device)
        session.addInput(input)

        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        view.wantsLayer = true
        view.layer = layer

        session.startRunning()
        return view
    }

    func updateNSView(_ nsView: NSViewType, context: Context) { }
}
