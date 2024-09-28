//
//

#if os(macOS)

import MIDIKitIO
import MIDIKitUI
import SwiftUI
import Tonic

struct ContentView: View {
    @EnvironmentObject var midiManager: ObservableMIDIManager
    @EnvironmentObject var midiHelper: MIDIHelper
    
    @Binding var midiInSelectedID: MIDIIdentifier?
    @Binding var midiInSelectedDisplayName: String?
    
    @State private var showTonicPopover = false  // State to control the popover visibility
    
    func topTier(topHeight: CGFloat) -> some View {
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
                    .foregroundColor(Color(midiHelper.chordShapeIconColor == Color.clear ? MIDIHelper.neutralColor.opacity(0.5):  midiHelper.chordShapeIconColor))
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
                    .onChange(of: midiInSelectedID) {
                        print("MIDI In Selection was Changed")
                        midiHelper.syncHomey()
                    }
                
            }
            .frame(alignment: .trailing)
            
        }
        .frame(height: topHeight)

    }
    
    func middleTier(middleHeight: CGFloat) -> some View {
        HStack(spacing: 9) {
            let imageMaxHeight = middleHeight / 3
            Spacer()
            
            ForEach(midiHelper.paletteOfNotes.sorted(by: <), id: \.self) { note in
                Image(emojiFileName(Int8(note)))
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: imageMaxHeight)
                    .offset(imageOffset(for: note, imageMaxHeight: -imageMaxHeight))
                    .scaleEffect(x: xScaleEffect)
                    .background(Color.clear)
                    .onChange(of: midiHelper.turnedOnPitches) {
                        withAnimation(.spring()) {
                            // Handle update if needed
                        }
                    }
                    .onHover { hovering in
                        withAnimation {
                            midiHelper.hoveredNote = hovering ? note : nil
                        }
                    }
                    .overlay(noteOverlay(for: note, imageMaxHeight: -imageMaxHeight), alignment: .center)
                    .overlay(removeButton(for: note, imageMaxHeight: -imageMaxHeight), alignment: .topTrailing)
                    .animation(.spring(), value: midiHelper.turnedOnPitches.contains(note))
                    .id(note)
                    .aspectRatio(1.0, contentMode: .fit)

            }
            
            Spacer()
        }
        .frame(height: middleHeight)
        .animation(.easeInOut, value: midiHelper.paletteOfNotes)
    }

    private func imageOffset(for note: Int, imageMaxHeight: CGFloat) -> CGSize {
        midiHelper.turnedOnPitches.contains(note) ? CGSize(width: 0, height: imageMaxHeight) : .zero
    }

    private func noteOverlay(for note: Int, imageMaxHeight: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(midiHelper.hoveredNote == note ? Color(MIDIHelper.neutralColor) : Color.clear, lineWidth: 1)
            .offset(midiHelper.turnedOnPitches.contains(note) ? CGSize(width: 0, height: imageMaxHeight) : .zero)
    }

    private func removeButton(for note: Int, imageMaxHeight: CGFloat) -> some View {
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
                .offset(midiHelper.turnedOnPitches.contains(note) ? CGSize(width: 0, height: imageMaxHeight) : .zero)
                .onHover { hovering in
                     withAnimation {
                         // Show the remove button when hovering
                         midiHelper.hoveredNote = hovering ? note : nil
                     }
                 }
            }
        }
    }
    func bottomTier(bottomHeight: CGFloat) -> some View  {
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
        .frame(height: bottomHeight)

    }

    var body: some View {
        ZStack {
            Color(.sRGB, red: 0.4, green: 0.2666666667, blue: 0.2, opacity: 1.0)
                .ignoresSafeArea()
            GeometryReader { geometry in
                let topHeight    = geometry.size.height * 0.05
                let middleHeight = geometry.size.height * 0.9
                let bottomHeight = geometry.size.height * 0.05

                VStack {
                    
                    topTier(topHeight: topHeight)
                    
                    Spacer()
                    
                    middleTier(middleHeight: middleHeight)
                    
                    Spacer()
                    
                    bottomTier(bottomHeight: bottomHeight)
                    
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
