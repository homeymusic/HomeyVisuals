//
//

#if os(macOS)

import MIDIKitIO
import MIDIKitUI
import SwiftUI
import AVFoundation
import HomeyMusicKit

struct ContentView: View {
    @Environment(ObservableMIDIManager.self) private var midiManager
    @EnvironmentObject var midiHelper: MIDIHelper
    
    @Binding var midiInSelectedID: MIDIIdentifier?
    @Binding var midiInSelectedDisplayName: String?
    
    @State private var showTonicPopover = false
    @State private var allNotes: [Int] = Array(0...127)
    @State private var isWebcamOn = false
    @State private var availableWebcams: [AVCaptureDevice] = []
    @State private var selectedWebcam: AVCaptureDevice?
    @State private var webcamHeightPercentage: CGFloat = 0.3  // Webcam occupies 30% of screen height by default
    @State private var dragOffset: CGFloat = 0.0
    @State private var isDragging = false
    
    // Palette and Webcam height limits
    @State private var paletteMaxHeightPercentage: CGFloat = 0.8  // Max height for the palette view
    @State private var paletteMinHeightPercentage: CGFloat = 0.2  // Min height for the palette view
    @State private var webcamMaxHeightPercentage: CGFloat = 0.5   // Max height for the webcam view
    @State private var webcamMinHeightPercentage: CGFloat = 0.2   // Min height for the webcam view
    @State private var showSettingsPopover = false
    static let topTierHeightPercentage = 0.05
    static let bottomTierHeightPercentage = 0.1
    
    // Static property to store the calculated sizes for all 128 MIDI notes
    static let normalizedSizes: [CGFloat] = {
        return ContentView.calculateNormalizedSizes()
    }()
    
    static func calculateNormalizedSizes() -> [CGFloat] {
        let maxSizePercent: CGFloat = 100  // Max area percentage for MIDI note 0
        let minSizePercent: CGFloat = 1   // Min area percentage for MIDI note 127
        let scalingFactor: CGFloat = log(maxSizePercent / minSizePercent) / 127  // Logarithmic scaling factor
        
        // Calculate areas using exponential scaling
        let initialAreas = MIDINote.allNotes().map { note in
            return maxSizePercent * exp(-scalingFactor * CGFloat(note.number))
        }
        
        // Normalize areas so they sum to 100% of total available area
        let totalArea = initialAreas.reduce(0, +)
        let normalizedAreas = initialAreas.map { area in
            return (area / totalArea) * 100
        }
        
        // Calculate corresponding side lengths (width/height) based on area = side^2
        let sideLengths = normalizedAreas.map { area in
            return sqrt(area)  // Side length is square root of area
        }
        
        // Normalize side lengths again to ensure total sum of lengths is within bounds
        let totalSideLength = sideLengths.reduce(0, +)
        return sideLengths.map { sideLength in
            return (sideLength / totalSideLength) * 100  // Scale to fit within total space
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
                        
                        Text("\(TonalContext.shared.tonicPitch.letter(.default))\(TonalContext.shared.tonicPitch.octave)")
                            .font(.title)
                            .foregroundColor(Color(MIDIHelper.neutralColor))
                    }
                }
                .buttonStyle(PlainButtonStyle())
                .focusable(false)  // Remove the focus ring if needed
                .popover(isPresented: $showTonicPopover, arrowEdge: .bottom) {
                    // Content for the popover
                    VStack {
                        Text("Select the tonic pitch")
                            .font(.headline)
                        List(Pitch.allPitches, id: \.self) { pitch in
                            Button(action: {
                                // Do something with the selected number
                                TonalContext.shared.tonicPitch = pitch
                                showTonicPopover = false  // Dismiss the popover
                            }) {
                                Text("\(pitch.letter(.default))\(pitch.octave)")
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
                    .foregroundColor(Color(midiHelper.pitchDirection.majorMinor.color))
                    .font(.title)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(alignment: .leading)
            
            // Symbols - Centered
            VStack {
                HStack(spacing: 20) {
                    
                    Button(action: {
                        // Toggle the upwardPitchDirection state
                        midiHelper.nextPitchDirection()
                    }) {
                        Image(systemName: midiHelper.pitchDirection.icon)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color(midiHelper.pitchDirection.majorMinor.color))
                            .frame(width: 50, height: 50)  // Fixed size
                    }
                    .keyboardShortcut("=", modifiers: [])
                    .buttonStyle(PlainButtonStyle())
                    .focusable(false)  // Remove the focus ring if needed
                    
                    
                    Image(systemName: midiHelper.chordShapeIconName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(midiHelper.chordShapeIconColor == Color.clear ? MIDIHelper.neutralColor.opacity(0.5):  midiHelper.chordShapeIconColor))
                        .frame(width: 50, height: 50)  // Fixed size
                }
                
                HStack {
                    Text("\(midiHelper.mode.label)")
                        .foregroundColor(Color(midiHelper.mode.majorMinor.color))
                        .font(.title)
                        .frame(maxWidth: .infinity)

                }
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
                
                
                // upper right corner
                Button(action: {
                    showSettingsPopover.toggle()
                }) {
                    Image(systemName: "gearshape")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)  // Make the gear icon much smaller
                        .padding()
                }
                .buttonStyle(PlainButtonStyle())  // This removes any default button styling
                .focusable(false)  // Turn off the blue outline
                .popover(isPresented: $showSettingsPopover) {
                    VStack {
                        midiInConnectionView
                            .padding(5)
                            .focusable(false)
                            .onChange(of: midiInSelectedID) {
                                print("MIDI In Selection was Changed")
                                midiHelper.syncHomey()
                            }
                        
                        
                        // Webcam Toggle with Icon, Label, and Slider
                        HStack {
                            Image(systemName: "camera.fill")  // SF Symbol for the webcam icon
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(.white)  // Change color if needed
                            
                            Text("Webcam")
                                .font(.system(size: 18))
                                .foregroundColor(.white)  // Change color if needed
                            
                            Spacer()
                            
                            Toggle("", isOn: $isWebcamOn)
                                .toggleStyle(SwitchToggleStyle(tint: Color.blue))  // Slider style
                        }
                        .padding()
                        
                        Picker("", selection: $selectedWebcam) {
                            ForEach(availableWebcams, id: \.self) { webcam in
                                Text(webcam.localizedName)
                                    .tag(webcam as AVCaptureDevice?)
                            }
                        }
                        .onAppear {
                            Task {
                                await setUpCaptureSession()
                            }
                        }
                        .disabled(!isWebcamOn)
                        .padding()
                        
                    }
                    .frame(width: 300)
                    .padding()
                }
            }
            .frame(alignment: .trailing)
            
        }
        .frame(height: topHeight)
        
    }
    
    @State private var isPaletteHovered = false  // Track whether the middle tier is hovered
    
    func palette(geometry: GeometryProxy, remainingHeight: CGFloat) -> some View {
        let availableHeight = remainingHeight // Shrinks as webcam grows
        let availableWidth = geometry.size.width
        let imageMaxHeight = availableHeight * 0.8  // Constrain the image size relative to available height
        let paletteNotesArray = Array(midiHelper.paletteOfNotes).sorted()  // Sort the Set to maintain consistent order
        let scaledSizes = getScaledSizes(midiNotes: paletteNotesArray, availableWidth: availableWidth)
        
        // Determine the height of the largest image
        let scaleMax = scaledSizes.max() ?? imageMaxHeight
        let scalingFactor = scaleMax > imageMaxHeight ? imageMaxHeight / scaleMax : 1.0
        let largestEmojiHeight = scaleMax * scalingFactor
        
        return HStack(alignment: .bottom, spacing: 0) {
            Spacer()
            
            ForEach(Array(paletteNotesArray.enumerated()), id: \.element) { index, note in
                let emojiSize = scaledSizes[index] * scalingFactor
                
                // Calculate available space above the current image, relative to the largest image
                let availableSpaceAboveImage = (availableHeight - largestEmojiHeight) / 2
                
                // Adjust the offset to ensure it doesn't push the emoji out of bounds
                let offsetAmount = midiHelper.turnedOnPitches.contains(note)
                ? -min(availableSpaceAboveImage, 2.0 * largestEmojiHeight)  // Ensure offset stays within bounds
                : 0
                
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
                            isPaletteHovered = hovering
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
        .frame(width: availableWidth, height: availableHeight)
        .overlay(paletteOverlay(), alignment: .center)  // Overlay for RoundedRectangle and Clear Button
        .onHover { hovering in
            withAnimation {
                isPaletteHovered = hovering
            }
        }
        .animation(.easeInOut, value: midiHelper.paletteOfNotes)
    }
    
    // Overlay for the entire HStack
    private func paletteOverlay() -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 10)
                .stroke(isPaletteHovered ? Color(MIDIHelper.neutralColor) : Color.clear, lineWidth: 1)
                .background(Color.clear)
            
            Button(action: {
                midiHelper.paletteOfNotes.removeAll()  // Clear the entire palette of notes
            }) {
                Image(systemName: "clear.fill")
                    .foregroundColor(isPaletteHovered && !midiHelper.paletteOfNotes.isEmpty ? Color(MIDIHelper.neutralColor) : Color.clear)
                    .padding(4)
            }
            .keyboardShortcut("r", modifiers: .command)  // Add keyboard shortcut to clear the palette
            .buttonStyle(PlainButtonStyle())
            .focusable(false)
            .transition(.opacity)
        }
        .padding(0)
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
        let availableHeight = geometry.size.height * ContentView.bottomTierHeightPercentage  // Height of the containing view
        let imageMaxHeight = availableHeight * 0.95  // Constrain the image size relative to available height
        let allSizes = ContentView.normalizedSizes  // Use the pre-calculated sizes
        
        // Scale sizes proportionally to fill the available width
        let totalRelativeSize = allSizes.reduce(0, +)
        let scaledSizes = allNotes.map { note in (allSizes[note] / totalRelativeSize) * availableWidth }
        
        // Determine the largest image size
        let scaleMax = scaledSizes.max() ?? 0  // Safely unwrap by providing a default value (0) if the array is empty
        let scalingFactor = scaleMax > imageMaxHeight ? imageMaxHeight / scaleMax : 1.0
        let largestEmojiHeight = scaleMax * scalingFactor
        
        let bottomPadding = 10.0
        
        return HStack(alignment: .bottom, spacing: 0) {
            ForEach(allNotes, id: \.self) { note in
                let emojiSize = scaledSizes[note] * scalingFactor
                
                // Calculate available space above the current emoji, relative to the largest emoji
                let availableSpaceAboveEmoji = (availableHeight - largestEmojiHeight - bottomPadding)
                
                // Adjust the offset to ensure it doesn't push the emoji out of bounds
                let offsetAmount = midiHelper.turnedOnPitches.contains(note)
                ? -availableSpaceAboveEmoji  // Ensure offset stays within bounds
                : 0
                
                Image(emojiFileName(Int8(note)))  // Your image loading logic
                    .resizable()
                    .scaledToFit()
                    .frame(width: emojiSize, height: emojiSize)
                    .offset(y: offsetAmount)  // Apply the constrained offset
                    .scaleEffect(x: xScaleEffect)
                    .animation(.spring(), value: midiHelper.turnedOnPitches.contains(note))
            }
        }
        .padding(.bottom, bottomPadding)
        .frame(width: availableWidth, height: availableHeight, alignment: .bottom)
    }
    
    // Function to fetch available webcams (including external cameras)
    func fetchAvailableWebcams() -> [AVCaptureDevice] {
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera, AVCaptureDevice.DeviceType.external],
            mediaType: .video,
            position: .unspecified
        )
        
        return discoverySession.devices
    }
    
    // Async function to set up capture session based on authorization
    func setUpCaptureSession() async {
        guard await isAuthorized else {
            print("Camera access not authorized.")
            return
        }
        
        // Fetch available webcams
        availableWebcams = fetchAvailableWebcams()
        selectedWebcam = availableWebcams.first // Select the first webcam by default
    }
    
    // Async property to check if the app is authorized to access the camera
    var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            
            // Determine if the user previously authorized camera access.
            var isAuthorized = status == .authorized
            
            // If the system hasn't determined the user's authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            
            return isAuthorized
        }
    }
    
    struct WebcamContainerView: View {
        @Binding var isWebcamOn: Bool
        @Binding var selectedWebcam: AVCaptureDevice?
        var availableWebcams: [AVCaptureDevice]
        
        var body: some View {
            VStack {
                if isWebcamOn, let selectedWebcam = selectedWebcam {
                    let formatDescription = selectedWebcam.activeFormat.formatDescription
                    let dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription)
                    let aspectRatio = CGFloat(dimensions.width) / CGFloat(dimensions.height)
                    
                    WebcamView(isWebcamOn: $isWebcamOn, selectedWebcam: $selectedWebcam)
                        .aspectRatio(aspectRatio, contentMode: .fit)
                        .border(MIDIHelper.darkBrownColor, width: 5)
                        .padding()
                        .id(selectedWebcam.uniqueID)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color(.sRGB, red: 0.4, green: 0.2666666667, blue: 0.2, opacity: 1.0)
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    topTier(topHeight: geometry.size.height * ContentView.topTierHeightPercentage)
                    
                    Spacer()
                    
                    let paletteHeightPercentage = isWebcamOn
                    ? min(max((1.0 - webcamHeightPercentage), paletteMinHeightPercentage), paletteMaxHeightPercentage)
                    : paletteMaxHeightPercentage + 0.1 // Add a bit more height to the palette when webcam is off
                    
                    // Then in your `palette` view:
                    palette(geometry: geometry, remainingHeight: geometry.size.height * (paletteHeightPercentage - ContentView.topTierHeightPercentage - ContentView.bottomTierHeightPercentage - 0.01))
                        .frame(height: geometry.size.height * paletteHeightPercentage)
                        .frame(minHeight: geometry.size.height * paletteMinHeightPercentage)  // Ensure minimum height
                        .frame(maxHeight: geometry.size.height * paletteMaxHeightPercentage + 0.1)  // Ensure maximum height
                    
                    Spacer()
                    
                    bottomTier(geometry: geometry)
                    
                    // Webcam Section with resizable height
                    // Webcam Section with resizable height
                    if isWebcamOn {
                        // Webcam Section with resizable height
                        
                        // Webcam Section with resizable height
                        VStack {
                            Rectangle()
                                .fill(isDragging ? Color.gray.opacity(0.7) : Color.gray.opacity(0.4))
                                .frame(width: 60, height: 5)
                                .cornerRadius(2.5)
                                .padding(.top, 4)
                                .onHover { hover in
                                    if hover { NSCursor.resizeUpDown.push() } else { NSCursor.pop() }
                                }
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            isDragging = true
                                            // Adjust the webcam height percentage based on the drag
                                            let newHeight = webcamHeightPercentage - (value.translation.height / geometry.size.height)
                                            // Ensure it stays within reasonable limits
                                            webcamHeightPercentage = min(max(newHeight, webcamMinHeightPercentage), webcamMaxHeightPercentage)
                                        }
                                        .onEnded { _ in
                                            isDragging = false
                                        }
                                )
                        }
                        .frame(height: 20)
                        .background(Color.clear)
                        
                        if isWebcamOn {
                            WebcamContainerView(
                                isWebcamOn: $isWebcamOn,
                                selectedWebcam: $selectedWebcam,
                                availableWebcams: availableWebcams
                            )
                            .transition(.opacity)  // Apply the fade effect
                            .frame(height: geometry.size.height * webcamHeightPercentage)
                            .padding(.horizontal)
                        }
                    }
                    
                    Spacer()
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
        } else {
            return ["home",
                    "stone_blue_hare", "stone_gold", "diamond_blue", "diamond_gold_sun",
                    "tent_blue", "disco", "tent_gold",
                    "diamond_blue_rain", "diamond_gold", "stone_blue", "stone_gold_hare",
            ][Int(interval)]
        }
    }
    
    private var xScaleEffect: CGFloat {
        midiHelper.pitchDirection == .upward ? -1.0 : 1.0
    }
    
}

#endif
