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

    @State private var showTonicPopover = false  // State to control the popover visibility

    var body: some View {
        ZStack {
            Color(#colorLiteral(red: 0.4, green: 0.2666666667, blue: 0.2, alpha: 1))
                .ignoresSafeArea()
            GeometryReader { geometry in
                VStack {
                    
                    HStack(spacing: 20) {

                        HStack {
                            
                            Button(action: {
                                showTonicPopover.toggle()  // Toggle the popover visibility
                            }) {
                                HStack {
                                    Image(systemName: "house.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color(MIDIHelper.neutralColor))
                                        .frame(width: 50, height: 50)  // Fixed size
                                    
                                    Text(String(midiHelper.tonicNote))
                                        .font(.title)
                                        .foregroundColor(Color(MIDIHelper.neutralColor))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            .focusable(false)  // Remove the focus ring if needed
                            .popover(isPresented: $showTonicPopover, arrowEdge: .bottom) {
                                // Content for the popover
                                VStack {
                                    Text("Select a number")
                                        .font(.headline)
                                    List(0...127, id: \.self) { number in
                                        Button(action: {
                                            // Do something with the selected number
                                            midiHelper.tonicNote = Int8(number)
                                            showTonicPopover = false  // Dismiss the popover
                                        }) {
                                            Text("\(number)")
                                        }
                                    }
                                    .frame(width: 150, height: 300)  // Adjust size as needed
                                }
                                .padding()
                            }

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
                        HStack(spacing: 20) {
                            
                            Button(action: {
                                // Toggle the upwardPitchDirection state
                                midiHelper.togglePitchDirection()
                            }) {
                                Image(systemName: midiHelper.pitchDirectionIconName)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundColor(Color(midiHelper.pitchDirectionIconColor))
                                    .frame(width: 50, height: 50)  // Fixed size
                            }
                            .keyboardShortcut("d", modifiers: .command)
                            .buttonStyle(PlainButtonStyle())
                            .focusable(false)  // Remove the focus ring if needed
                            

                            Image(systemName: midiHelper.chordShapeIconName)
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(Color(midiHelper.chordShapeIconColor == NSColor.clear ? MIDIHelper.neutralColor.withAlphaComponent(0.5):  midiHelper.chordShapeIconColor))
                                .frame(width: 50, height: 50)  // Fixed size
                        }

                        HStack {
                            // Chord Label - Right-aligned and expands to use available space
                            Text("\(midiHelper.rootNote()) \(midiHelper.chordLabel)")
                                .foregroundColor(Color(midiHelper.chordShapeIconColor))
                                .font(.title)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            // Spacer to balance the symbols
                            Spacer()
                            
                            Button(action: { midiHelper.reset() }) {
                                Image(systemName: "gobackward")
                            }
                            .buttonStyle(PlainButtonStyle())
                            .keyboardShortcut("r", modifiers: .command)
                            .focusable(false)  // Remove focus ring

                            midiInConnectionView
                                .padding(5)
                                .focusable(false)

                        }
                        .frame(alignment: .trailing)

                    }
                    .frame(height: geometry.size.height * 0.05)
                    
                    Spacer()
                    HStack(alignment: .bottom, spacing: 9) {
                        ForEach(midiHelper.paletteOfNotes.sorted(by: <), id: \.self) { note in
                            var foreverAnimation: Animation {
                                Animation.linear(duration: 2.0)
                                    .repeatForever(autoreverses: false)
                            }
                            Image(emojiFileName(Int8(note)))
                                .resizable()
                                .scaledToFit()
                                .offset(midiHelper.turnedOnPitches.contains(note) ? imageOffset : .zero )
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
                                .onHover { hovering in
                                    withAnimation {
                                        // Show the remove button when hovering
                                        midiHelper.hoveredNote = hovering ? note : nil
                                    }
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(midiHelper.hoveredNote == note ? Color(MIDIHelper.neutralColor) : Color.clear, lineWidth: 1)
                                        .offset(midiHelper.turnedOnPitches.contains(note) ? imageOffset : .zero)
                                        .scaleEffect(x: xScaleEffect),
                                    alignment: .center
                                )
                                // Apply the button in a separate overlay in the top-right corner
                                .overlay(
                                    Group {
                                        if midiHelper.hoveredNote == note {
                                            Button(action: {
                                                midiHelper.paletteOfNotes.remove(note)
                                            }) {
                                                Image(systemName: "clear.fill")
                                                    .foregroundColor(Color(MIDIHelper.neutralColor))
                                                    .padding(4)
                                            }
                                            .buttonStyle(PlainButtonStyle())
                                            .transition(.opacity)
                                            .offset(midiHelper.turnedOnPitches.contains(note) ? imageOffset : .zero)  // Apply the same offset
                                            .scaleEffect(x: xScaleEffect)  // Apply the same scale effect
                                            .onHover { hovering in
                                                withAnimation {
                                                    // Show the remove button when hovering
                                                    midiHelper.hoveredNote = hovering ? note : nil
                                                }
                                            }
                                        }
                                    },
                                    alignment: .topTrailing
                                )
                                .animation(.spring(), value: midiHelper.turnedOnPitches.contains(note))
                                .id(note)
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
        MIDIOutputsPicker(
            title: "",
            selectionID: $midiInSelectedID,
            selectionDisplayName: $midiInSelectedDisplayName,
            showIcons: true,
            hideOwned: false
        )
        .updatingInputConnection(withTag: MIDIHelper.Tags.midiIn)
        .frame(maxWidth: 300)
        .focusable(false)
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
