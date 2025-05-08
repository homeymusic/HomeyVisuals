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
        .aspectRatio(contentMode: .fill)
        .clipped()
        .frame(
            width:  cameraWidget.width,
            height: cameraWidget.height,
            alignment: .center
        )
        .position(
            x: cameraWidget.x + cameraWidget.width  / 2,
            y: cameraWidget.y + cameraWidget.height / 2
        )
        .allowsHitTesting(true)
    }
}
