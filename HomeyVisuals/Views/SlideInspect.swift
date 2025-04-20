import SwiftUI
import SwiftData
import HomeyMusicKit
import AVFoundation

struct SlideInspect: View {
    @Bindable var slide: Slide

    var body: some View {
        Form {
            Section("Background") {
                // Pick between solid color or camera feed
                Picker("Type", selection: $slide.backgroundType) {
                    Text("Color").tag(Slide.BackgroundType.color)
                    Text("Camera").tag(Slide.BackgroundType.cameraFeed)
                }
                .pickerStyle(.segmented)

                switch slide.backgroundType {
                case .color:
                    ColorPicker("Background Color", selection: $slide.backgroundColor)

                case .cameraFeed:
                    // Let the user select which camera
                    Picker("Camera", selection: Binding(
                        get: { slide.cameraDeviceID ?? "" },
                        set: { slide.cameraDeviceID = $0 }
                    )) {
                        ForEach(CameraView.availableDevices, id: \.uniqueID) { device in
                            Text(device.localizedName).tag(device.uniqueID)
                        }
                    }

                    // Show a live preview from the selected camera
                    if let device = CameraView.device(for: slide.cameraDeviceID) {
                        CameraView(device: device)
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

