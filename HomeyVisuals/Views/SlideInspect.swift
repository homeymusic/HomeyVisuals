import SwiftUI
import SwiftData
import HomeyMusicKit
import AVFoundation

struct SlideInspect: View {
    @Bindable var slide: Slide

    // Only wide‑angle & external on macOS; include ultra‑wide/telephoto on iOS.
    private var videoDevices: [AVCaptureDevice] {
        let types: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,
            .external
        ]

        return AVCaptureDevice.DiscoverySession(
            deviceTypes: types,
            mediaType: .video,
            position: .unspecified
        ).devices
    }

    var body: some View {
        Form {
            Section("Background") {
                Picker("Type", selection: $slide.backgroundType) {
                    Text("Color").tag(Slide.BackgroundType.color)
                    Text("Camera").tag(Slide.BackgroundType.cameraFeed)
                }
                .pickerStyle(.segmented)

                switch slide.backgroundType {
                case .color:
                    ColorPicker("Background Color", selection: $slide.backgroundColor)
                case .cameraFeed:
                    Picker("Camera", selection: Binding(
                        get: { slide.cameraDeviceID ?? "" },
                        set: { slide.cameraDeviceID = $0 }
                    )) {
                        ForEach(videoDevices, id: \.uniqueID) { device in
                            Text(device.localizedName).tag(device.uniqueID)
                        }
                    }

                    if let camID = slide.cameraDeviceID,
                       let device = videoDevices.first(where: { $0.uniqueID == camID }) {
                        CameraPreviewView(device: device)
                            .aspectRatio(CGFloat(slide.aspectRatio.ratio), contentMode: .fit)
                            .clipped()
                    } else {
                        Text("Select a camera above")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Inspect Slide")
        .padding()
    }
}
