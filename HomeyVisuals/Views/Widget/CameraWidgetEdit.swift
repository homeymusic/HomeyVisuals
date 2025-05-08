// CameraWidgetEdit.swift

import SwiftUI
import SwiftData
import HomeyMusicKit

struct CameraWidgetEdit: View {
    @Environment(AppContext.self) private var appContext
    @Bindable var cameraWidget: CameraWidget

    private var isEditing: Bool {
        appContext.editingWidgetID == cameraWidget.id
    }

    var body: some View {
        CameraView(
            cameraDeviceID: cameraWidget.cameraDeviceID,
            isThumbnail: false
        )
        .clipped()
        .allowsHitTesting(isEditing)
    }
}
