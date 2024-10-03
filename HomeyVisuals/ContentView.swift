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
    
    @State private var allNotes: [Int] = Array(0...127)  // Full set of notes (for the bottom tier)

    // Static property to store the calculated sizes for all 128 MIDI notes
    static let normalizedSizes: [CGFloat] = {
        return ContentView.calculateNormalizedSizes()
    }()

    // Function that dynamically generates the same values as the Python code
    static func calculateNormalizedSizes() -> [CGFloat] {
        let maxSizePercent: CGFloat = 20  // Max size for MIDI note 0 as percentage
        let minSizePercent: CGFloat = 1   // Min size for MIDI note 127 as percentage
        let midiNotes = 0...127

        // Calculate initial sizes based on linear scaling
        let initialSizes = midiNotes.map { note in
            return maxSizePercent - ((maxSizePercent - minSizePercent) / 127) * CGFloat(note)
        }

        // Normalize sizes to make the sum 100%
        let totalSize = initialSizes.reduce(0, +)
        return initialSizes.map { size in
            return (size / totalSize) * 100
        }
    }

    // Function to get the relative sizes from the "all" row and scale them for the middle tier
    func getScaledSizes(midiNotes: [Int], availableWidth: CGFloat) -> [CGFloat] {
        // Get the relative sizes for the notes in the middle tier (palette)
        let paletteSizes = midiNotes.map { ContentView.normalizedSizes[$0] }

        // Scale the relative sizes so they sum to 100% of available width
        let totalPaletteSize = paletteSizes.reduce(0, +)
        return paletteSizes.map { ($0 / totalPaletteSize) * availableWidth }
    }

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
    
    func middleTier(geometry: GeometryProxy) -> some View {
        let availableHeight = geometry.size.height * 0.9  // Total height for the middle tier
        let availableWidth = geometry.size.width
        let imageMaxHeight = availableHeight * 0.6
        let paletteNotesArray = Array(midiHelper.paletteOfNotes).sorted()  // Sort the Set to maintain consistent order
        let scaledSizes = getScaledSizes(midiNotes: paletteNotesArray, availableWidth: availableWidth)

        return HStack(alignment: .bottom, spacing: 0) {
            Spacer()
            
            ForEach(Array(paletteNotesArray.enumerated()), id: \.element) { index, note in
                let emojiWidth = scaledSizes[index]
                let emojiSize = min(emojiWidth, imageMaxHeight)  // Constrain both width and height to the smallest value

                // Adjust the offset to ensure it doesn't push the emoji out of bounds
                let maxAvailableOffset = availableHeight - emojiSize * 0.5
                let offsetAmount = midiHelper.turnedOnPitches.contains(note) ? -min(emojiSize * 0.5, maxAvailableOffset) : 0

                Image(emojiFileName(Int8(note)))  // Your image loading logic
                    .resizable()
                    .scaledToFit()
                    .frame(width: emojiSize, height: emojiSize)  // Use emojiSize for both width and height
                    .offset(y: offsetAmount)  // Apply the constrained offset
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
                    .overlay(noteOverlay(for: note, offsetAmount: offsetAmount), alignment: .center)
                    .overlay(removeButton(for: note, offsetAmount: offsetAmount), alignment: .topTrailing)
                    .animation(.spring(), value: midiHelper.turnedOnPitches.contains(note))
                    .id(note)  // Use 'note' as the identifier to ensure consistency
            }
            
            Spacer()
        }
        .frame(height: availableHeight)
        .animation(.easeInOut, value: midiHelper.paletteOfNotes)
    }
    
    private func noteOverlay(for note: Int, offsetAmount: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .stroke(midiHelper.hoveredNote == note ? Color(MIDIHelper.neutralColor) : Color.clear, lineWidth: 1)
            .offset(CGSize(width: 0, height: offsetAmount))
    }

    private func removeButton(for note: Int, offsetAmount: CGFloat) -> some View {
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
                .offset(CGSize(width: 0, height: offsetAmount))
                .onHover { hovering in
                     withAnimation {
                         // Show the remove button when hovering
                         midiHelper.hoveredNote = hovering ? note : nil
                     }
                 }
            }
        }
    }
    
    func bottomTier(geometry: GeometryProxy) -> some View  {
        let availableWidth = geometry.size.width
        let availableHeight = geometry.size.height * 0.05  // Height of the containing view
        let allSizes = ContentView.normalizedSizes  // Use the pre-calculated sizes

        return HStack(alignment: .bottom, spacing: 0) {
            
            ForEach(allNotes, id: \.self) { note in
                let sizePercentage = allSizes[note] / 100.0
                let emojiWidth = sizePercentage * availableWidth
                let offsetAmount = midiHelper.turnedOnPitches.contains(note) ? -emojiWidth * 1.0 : 0
                
                // Calculate maximum allowable offset to stay within the view's height
                let maxOffset = min(offsetAmount, availableHeight - emojiWidth)

                Image(emojiFileName(Int8(note)))  // Your image loading logic
                    .resizable()
                    .scaledToFit()
                    .frame(width: emojiWidth, height: emojiWidth)
                    .offset(y: midiHelper.turnedOnPitches.contains(note) ? maxOffset : 0 )  // Apply the constrained offset
                    .animation(.spring(), value: midiHelper.turnedOnPitches.contains(note))
            }
        }
        .frame(height: availableHeight)  // Consistent height for the HStack based on availableHeight
    }
    
    var body: some View {
        ZStack {
            Color(.sRGB, red: 0.4, green: 0.2666666667, blue: 0.2, opacity: 1.0)
                .ignoresSafeArea()
            GeometryReader { geometry in
                let topHeight    = geometry.size.height * 0.05

                VStack {
                    
                    topTier(topHeight: topHeight)
                    
                    Spacer()
                    
                    middleTier(geometry: geometry)
                    
                    Spacer()
                    
                    bottomTier(geometry: geometry)
                    
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
