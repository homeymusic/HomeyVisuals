//
//

#if os(macOS)

import MIDIKitIO
import MIDIKitUI
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var midiManager: ObservableMIDIManager
    @EnvironmentObject var midiHelper: MIDIHelper
    
    @Binding var midiInSelectedID: MIDIIdentifier?
    @Binding var midiInSelectedDisplayName: String?
    
    var body: some View {
        VStack {
            midiInConnectionView
                .padding(5)
            
            Text("Degree: \(midiHelper.degreeLabel)")

            Text("Chord: \(midiHelper.chordLabel)")

            Text("Tonic:   \(midiHelper.tonicNote)")

            Text("Upward:  \(midiHelper.upwardPitchDirection)")

            Text("Playing: \(midiHelper.turnedOnNotes)")            

            Text("Integers: \(midiHelper.chordIntegerLabel)")
            

            Spacer()
        }
        .multilineTextAlignment(.center)
        .lineLimit(nil)
        .padding()
        .frame(minWidth: 700, minHeight: 660)
    }
    
    private var midiInConnectionView: some View {
        GroupBox {
            MIDIOutputsPicker(
                title: "MIDI In",
                selectionID: $midiInSelectedID,
                selectionDisplayName: $midiInSelectedDisplayName,
                showIcons: true,
                hideOwned: false
            )
            .updatingInputConnection(withTag: MIDIHelper.Tags.midiIn)
            .padding([.leading, .trailing], 60)
            
        }
    }
    
}

#endif
