// CameraWidgetShow.swift

import SwiftUI
import SwiftData
import HomeyMusicKit

struct CameraWidgetShow: View {
    @Bindable var cameraWidget: CameraWidget

    var body: some View {
        CameraView(
            cameraDeviceID: cameraWidget.cameraDeviceID,
            isThumbnail: false
        )
        .frame(width: cameraWidget.width, height: cameraWidget.height, alignment: .leading)
        .fixedSize(horizontal: false, vertical: true)
        .position(x: cameraWidget.x, y: cameraWidget.y)
        .allowsHitTesting(false)
        .clipped()
    }
}
