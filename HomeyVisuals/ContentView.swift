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

            HStack(alignment: .bottom, spacing: 9) {
                Image("home_far")           // P8
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(48) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(48))
                    .scaleEffect(x: -1)
                Image("stone_blue_far")     // m6
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(49) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(49))
                    .scaleEffect(x: -1)
                Image("stone_gold_far")     // M6
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(50) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(50))
                    .scaleEffect(x: -1)
                Image("diamond_blue_far")   // m7
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(51) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(51))
                    .scaleEffect(x: -1)
                Image("diamond_gold_far")   // M7
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(52) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(52))
                    .scaleEffect(x: -1)
                Image("tent_far")           // P5
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(53) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(53))
                    .scaleEffect(x: -1)
                Image("stone_orange_far")       // tt
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(54) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(54))
                    .scaleEffect(x: -1)
                Image("tent_far")           // P5
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(55) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(55))
                    .scaleEffect(x: -1)
                Image("diamond_blue_far")   // m7
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(56) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(56))
                    .scaleEffect(x: -1)
                Image("diamond_gold_far")   // M7
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(57) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(57))
                    .scaleEffect(x: -1)
                Image("stone_blue_far")     // m6
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(58) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(58))
                    .scaleEffect(x: -1)
                Image("stone_gold_far")     // M6
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(59) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(59))
                    .scaleEffect(x: -1)
                Image("home")               // P1
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(60) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(60))
                Image("stone_blue")         // m2
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(61) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(61))
                Image("stone_gold")         // M2
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(62) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(62))
                Image("diamond_blue")       // m3
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(63) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(63))
                Image("diamond_gold")       // M3
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(64) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(64))
                Image("tent")               // P4
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(65) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(65))
                Image("stone_orange")       // tt
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(66) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(66))
                Image("tent")               // P4
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(67) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(67))
                Image("diamond_blue")       // m3
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(68) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(68))
                Image("diamond_gold")       // M3
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(69) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(69))
                Image("stone_blue")         // m2
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(70) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(70))
                Image("stone_gold")         // M2
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(71) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(71))
                Image("home")           // P8
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(72) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(72))
                Image("stone_blue_far")     // m6
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(73) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(73))
                Image("stone_gold_far")     // M6
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(74) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(74))
                Image("diamond_blue_far")   // m7
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(75) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(75))
                Image("diamond_gold_far")   // M7
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(76) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(76))
                Image("tent_far")           // P5
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(77) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(77))
                Image("stone_orange_far")       // tt
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(78) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(78))
                Image("tent_far")           // P5
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(79) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(79))
                Image("diamond_blue_far")   // m7
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(80) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(80))
                Image("diamond_gold_far")   // M7
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(81) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(81))
                Image("stone_blue_far")     // m6
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(82) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(82))
                Image("stone_gold_far")     // M6
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(83) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(83))
                Image("home_far")           // P8
                    .resizable()
                    .scaledToFit()
                    .offset(y: midiHelper.turnedOnNotes.contains(84) ? -300 : 0 )
                    .animation(.spring(), value: midiHelper.turnedOnNotes.contains(84))
            }

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
