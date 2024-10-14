import SwiftUI
import HomeyMusicKit

class ViewConductor: ObservableObject {
    let allPitches: [Pitch]
    
    init() {
        self.allPitches = Array(0...127).map {Pitch($0)}
    }
    
}
