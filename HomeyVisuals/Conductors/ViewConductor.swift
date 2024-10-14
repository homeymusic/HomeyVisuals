import SwiftUI
import HomeyMusicKit

class ViewConductor: ObservableObject {
    let allPitches: [Pitch] = Array(0...127).map { Pitch($0) }
    @Published var allIntervals: [Interval] = []
    @Published var tonicPitch: Pitch = Pitch(60) {
        didSet {
            // Update allIntervals whenever tonicPitch changes
            self.allIntervals = self.allPitches.map { pitch in
                Interval(pitch: pitch, tonicPitch: tonicPitch)
            }
        }
    }
    
    init() {
        // Initialize allIntervals when ViewConductor is created
        self.allIntervals = self.allPitches.map { pitch in
            Interval(pitch: pitch, tonicPitch: tonicPitch)
        }
    }
}
