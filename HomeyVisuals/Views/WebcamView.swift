import AVFoundation
import SwiftUI

struct WebcamView: NSViewRepresentable {
    @Binding var isWebcamOn: Bool
    @Binding var selectedWebcam: AVCaptureDevice?

    let captureSession = AVCaptureSession()

    func makeNSView(context: Context) -> NSView {
        let nsView = NSView(frame: .zero)
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspect
        nsView.layer = previewLayer
        return nsView
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        // If webcam is on and selected, configure the session with the selected webcam
        if isWebcamOn, let selectedWebcam = selectedWebcam {
            reconfigureWebcam(session: captureSession, with: selectedWebcam)

            if let previewLayer = nsView.layer as? AVCaptureVideoPreviewLayer {
                previewLayer.session = captureSession
                previewLayer.frame = nsView.bounds
            }
        } else {
            // Stop the webcam if it's turned off or no webcam is selected
            stopWebcam(session: captureSession)
        }
    }

    func reconfigureWebcam(session: AVCaptureSession, with device: AVCaptureDevice) {
        session.beginConfiguration()

        // Remove any existing input
        if let currentInput = session.inputs.first {
            session.removeInput(currentInput)
        }

        // Add new input for the selected webcam
        do {
            let input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
            session.commitConfiguration()

            if !session.isRunning {
                session.startRunning()
            }
        } catch {
            print("Error switching to webcam: \(error)")
        }
    }

    func stopWebcam(session: AVCaptureSession) {
        if session.isRunning {
            session.stopRunning()
        }
    }
}
