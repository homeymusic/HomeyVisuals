import SwiftUI
import SwiftData
import HomeyMusicKit


struct CameraWidgetInspect: View {
    @Bindable var cameraWidget: CameraWidget

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                SectionView(title: "Camera Feed") {
                    Picker("Camera", selection: Binding(
                        get: { cameraWidget.cameraDeviceID ?? "" },
                        set: { cameraWidget.cameraDeviceID = $0 }
                    )) {
                        ForEach(CameraView.availableDevices, id: \.uniqueID) { device in
                            Text(device.localizedName)
                                .tag(device.uniqueID)
                        }
                    }
                    .pickerStyle(.menu)

                    CameraView(cameraDeviceID: cameraWidget.cameraDeviceID, isThumbnail: false, isDeviceAspectRatio: true)
                }
            }
            .padding()
        }
        .navigationTitle("Camera Widget Settings")
    }

    private struct SectionView<Content: View>: View {
        let title: String
        let content: Content

        init(title: String, @ViewBuilder content: () -> Content) {
            self.title = title
            self.content = content()
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                content
            }
        }
    }
}
