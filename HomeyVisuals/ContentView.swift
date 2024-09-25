//
//

#if os(macOS)

import MIDIKitIO
import MIDIKitUI
import SwiftUI
import Tonic

//func modulo(_ a: Int8, _ n: Int8) -> Int8 {
//    precondition(n > 0, "modulus must be positive")
//    let r = a % n
//    return r >= 0 ? r : r + n
//}
//
struct ContentView: View {
    @EnvironmentObject var midiManager: ObservableMIDIManager
    @EnvironmentObject var midiHelper: MIDIHelper
    
    @Binding var midiInSelectedID: MIDIIdentifier?
    @Binding var midiInSelectedDisplayName: String?

    @State private var imageOffset: CGSize = .zero
    @State private var imageSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.4, green: 0.2666666667, blue: 0.2, alpha: 1))
                .ignoresSafeArea()
            GeometryReader { geometry in
                VStack {
                    
                    HStack(spacing: 20) {

                        HStack {
                            // Spacer to push the symbols and balance the text
                            Spacer()
                            
                            // Degree Label - Left-aligned and expands to use available space
                            Text(midiHelper.degreeLabel)
                                .foregroundColor(Color(midiHelper.pitchDirectionIconColor))
                                .font(.title)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                        }
                        .frame(alignment: .leading)

                        // Symbols - Centered
                        HStack(spacing: 5) {
                            Image(systemName: midiHelper.pitchDirectionIconName)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(midiHelper.pitchDirectionIconColor))
                                .frame(width: 50, height: 50)  // Fixed size

                            Image(systemName: midiHelper.chordShapeIconName)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(midiHelper.chordShapeIconColor))
                                .frame(width: 50, height: 50)  // Fixed size
                        }

                        HStack {
                            // Chord Label - Right-aligned and expands to use available space
                            Text(midiHelper.chordLabel)
                                .foregroundColor(Color(midiHelper.chordShapeIconColor))
                                .font(.title)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // Spacer to balance the symbols
                            Spacer()

                            Button(action: { midiHelper.reset() }, label: {
                                Image(systemName: "gobackward")
                                    .foregroundColor(Color(MIDIHelper.neutralColor))
                            })
                            .focusable(false)
                            
                            midiInConnectionView
                                .padding(5)
                                .focusable(false)

                        }
                        .frame(alignment: .trailing)

                    }
                    .frame(height: geometry.size.height * 0.05)
                    
                    Spacer()
                    HStack(alignment: .bottom, spacing: 9) {
                        ForEach(midiHelper.paletteOfNotes.sorted(by: <), id: \.self) {
                            var foreverAnimation: Animation {
                                Animation.linear(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                            }
                            Image(emojiFileName(Int8($0)))
                                .resizable()
                                .scaledToFit()
                                .offset(midiHelper.turnedOnPitches.contains($0) ? imageOffset : .zero )
                                .animation(.spring(), value: midiHelper.turnedOnPitches.contains($0))
                                .scaleEffect(x: xScaleEffect)
                                .background(
                                    GeometryReader { imageGeometry in
                                        Color.clear.onAppear {
                                            imageSize = imageGeometry.size
                                        }
                                    }
                                )
                                .onAppear {
                                    withAnimation(.spring()) {
                                        // Calculate a safe offset to keep the image within bounds
                                        let maxY = min(300, (geometry.size.height - imageSize.height) / 2)

                                        imageOffset = CGSize(width: 0, height: -maxY)
                                    }
                                }
                        }
                    }
                    .frame(height: geometry.size.height * 0.9)
                    .animation(.easeInOut, value: midiHelper.paletteOfNotes)
                    
                    Spacer()
                    HStack(spacing: 9) {
                        ForEach(0...127, id: \.self) {
                            Image(emojiFileName(Int8($0)))
                                .resizable()
                                .scaledToFit()
                                .offset(y: midiHelper.turnedOnPitches.contains($0) ? -50 : 0 )
                                .animation(.spring(), value: midiHelper.turnedOnPitches.contains($0))
                                .scaleEffect(x: xScaleEffect)
                        }
                    }
                    .frame(height: geometry.size.height * 0.05)
                }
            }
            .multilineTextAlignment(.center)
            .lineLimit(nil)
            .padding()
            .frame(minWidth: 700, minHeight: 660)
        }
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
            .aspectRatio(5.0, contentMode: .fit)
        }
    }
    
    public func emojiFileName(_ note: Int8) -> String {
        let interval = MIDIHelper.mod(Int(note) - Int(midiHelper.tonicNote), 12)
        if midiHelper.tonicNote == note {
            return "home_tortoise_tree"
        } else if midiHelper.upwardPitchDirection {
            return ["home",
                    "stone_blue_hare", "stone_gold", "diamond_blue", "diamond_gold_sun",
                    "tent_blue", "disco", "tent_gold",
                    "diamond_blue_rain", "diamond_gold", "stone_blue", "stone_gold_hare",
            ][Int(interval)]
        } else {
            return ["home",
                    "stone_blue_hare", "stone_gold", "diamond_blue", "diamond_gold_sun",
                    "tent_blue", "disco", "tent_gold",
                    "diamond_blue_rain", "diamond_gold", "stone_blue", "stone_gold_hare",
            ][Int(interval)]
        }
    }
    
    private var xScaleEffect: CGFloat {
        midiHelper.upwardPitchDirection ? -1.0 : 1.0
    }
    
}

#endif
