//
//

#if os(macOS)

import MIDIKitIO
import MIDIKitUI
import SwiftUI
import Tonic

public struct IntervalEmoji {
    
    /// Brian McAuliff Mulloy 2023, International Conference on Music Perception and Cognition (ICMPC)
    public static var homey: [String] {
        ["home", 
         "stone_blue", "stone_gold", "diamond_blue", "diamond_gold", 
         "tent", "stone_orange", "tent",
         "diamond_blue", "diamond_gold", "stone_blue", "stone_gold",
        ]
    }
    
}

func modulo(_ a: Int8, _ n: Int8) -> Int8 {
    precondition(n > 0, "modulus must be positive")
    let r = a % n
    return r >= 0 ? r : r + n
}

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
            
            Text("Playing: \(midiHelper.turnedOnPitches)")
            
            Text("Integers: \(midiHelper.chordIntegerLabel)")
            
            Text("Palette: \(midiHelper.paletteOfNotes)")
            
            Spacer()
            HStack(alignment: .bottom, spacing: 9) {
                ForEach(midiHelper.paletteOfNotes.sorted(by: <), id: \.self) {
                    let imageHeight = 75.0
                    let interval = modulo(Int8(Int($0 - midiHelper.tonicNote)), 12)
                    let emojiName = IntervalEmoji.homey[Int(interval)]
                    Image(emojiName)
                        .resizable()
                        .scaledToFit()
                        .offset(y: midiHelper.turnedOnPitches.contains($0) ? -3 * imageHeight : 0 )
                        .animation(.spring(), value: midiHelper.turnedOnPitches.contains($0))
                        .scaleEffect(x: -1)
                }
            }
            .frame(height: 200)
            Spacer()
            HStack(alignment: .bottom, spacing: 9) {
                ForEach(48...84, id: \.self) {
                    let imageHeight = 75.0
                    let interval = modulo(Int8(Int($0 - midiHelper.tonicNote)), 12)
                    let emojiName = IntervalEmoji.homey[Int(interval)]
                    Image(emojiName)
                        .resizable()
                        .scaledToFit()
                        .offset(y: midiHelper.turnedOnPitches.contains($0) ? -3 * imageHeight : 0 )
                        .animation(.spring(), value: midiHelper.turnedOnPitches.contains($0))
                        .scaleEffect(x: -1)
                }
            }
            .frame(height: 75)
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
