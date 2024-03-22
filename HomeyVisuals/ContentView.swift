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
        @State var xScaleEffect: CGFloat = midiHelper.upwardPitchDirection ? +1.0 : -1.0

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

            HStack(alignment: .bottom, spacing: 50) {
                Image("home")               // P1
                    .offset(y: midiHelper.turnedOnNotes.contains(60) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(60))
                Image("stone_blue")         // m2
                    .offset(y: midiHelper.turnedOnNotes.contains(61) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(61))
                Image("stone_gold")         // M2
                    .offset(y: midiHelper.turnedOnNotes.contains(62) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(62))
                Image("diamond_blue")       // m3
                    .offset(y: midiHelper.turnedOnNotes.contains(63) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(63))
                Image("diamond_gold")       // M3
                    .offset(y: midiHelper.turnedOnNotes.contains(64) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(64))
                Image("tent")               // P4
                    .offset(y: midiHelper.turnedOnNotes.contains(65) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(65))
                Image("stone_orange")       // tt
                    .offset(y: midiHelper.turnedOnNotes.contains(66) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(66))
                Image("tent_far")           // P5
                    .offset(y: midiHelper.turnedOnNotes.contains(67) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(67))
                Image("diamond_blue_far")   // m7
                    .offset(y: midiHelper.turnedOnNotes.contains(68) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(68))
                Image("diamond_gold_far")   // M7
                    .offset(y: midiHelper.turnedOnNotes.contains(69) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(69))
                Image("stone_blue_far")     // m6
                    .offset(y: midiHelper.turnedOnNotes.contains(70) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(70))
                Image("stone_gold_far")     // M6
                    .offset(y: midiHelper.turnedOnNotes.contains(71) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(71))
                Image("home_far")           // P8
                    .offset(y: midiHelper.turnedOnNotes.contains(72) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(72))
            }
            .scaleEffect(x: xScaleEffect)

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
