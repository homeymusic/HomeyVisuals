import SwiftUI
import SwiftData
import HomeyMusicKit
import AVFoundation

/// Inspector for a selected Slide: shows a subtle gray “Slide” header, top-aligned, and the Arrange tab.
struct SlideInspect: View {
    @Bindable var slide: Slide

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Text("Slide")
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
            Divider()

            // Arrange section (only tab for now)
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
                            ForEach(CameraView.availableDevices, id: \.uniqueID) { device in
                                Text(device.localizedName).tag(device.uniqueID)
                            }
                        }
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
            .padding(.top, 8)

            Spacer()
        }
        // ensure top alignment in available space
        .frame(maxHeight: .infinity, alignment: .top)
        .padding()
    }
}

