import SwiftUI
import SwiftData
import MIDIKitCore
import HomeyMusicKit

struct MusicalInstrumentWidgetInspect: View {
    @Bindable var musicalInstrumentWidget: MusicalInstrumentWidget

    @Query(sort: \IntervalColorPalette.position, order: .forward)
    private var intervalColorPalettes: [IntervalColorPalette]

    @Query(sort: \PitchColorPalette.position, order: .forward)
    private var pitchColorPalettes: [PitchColorPalette]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                if let keyboardInstrument = musicalInstrumentWidget.musicalInstrument as? KeyboardInstrument {
                    SectionView(title: "Keyboard Layout") {
                        RowsColsPickerInspectView(keyboardInstrument: keyboardInstrument)
                    }
                }

                SectionView(title: "Color Palette") {
                    VStack(spacing: 4) {
                        ForEach(intervalColorPalettes, id: \.self) { palette in
                            ColorPaletteGridRow(
                                musicalInstrument: musicalInstrumentWidget.musicalInstrument,
                                colorPalette: palette
                            )
                        }

                        Divider()
                            .padding(.vertical, 4)

                        Toggle("Outline", isOn: outlineBinding)
                            .tint(.gray)
                            .foregroundColor(.white)
                            .onChange(of: outlineBinding.wrappedValue) {
                                buzz()
                            }

                        Divider()
                            .padding(.vertical, 4)

                        ForEach(pitchColorPalettes, id: \.self) { palette in
                            ColorPaletteGridRow(
                                musicalInstrument: musicalInstrumentWidget.musicalInstrument,
                                colorPalette: palette
                            )
                        }
                    }
                }
                
                SectionView(title: "Audio and MIDI") {
                    Toggle(isOn: playSynthBinding) {
                        Label("Play Synthesizer", systemImage: "speaker.wave.2")
                    }
                    Picker("MIDI Input", selection: midiInSelection) {
                        Text("All").tag(ChannelPickerValue.all)
                        Text("None").tag(ChannelPickerValue.none)
                        ForEach(1...16, id: \.self) { channel in
                            Text("\(channel)").tag(ChannelPickerValue.selected(channel))
                        }
                    }
                    .pickerStyle(.menu)
                    Picker("MIDI Output", selection: midiOutSelection) {
                        Text("All").tag(ChannelPickerValue.all)
                        Text("None").tag(ChannelPickerValue.none)
                        ForEach(1...16, id: \.self) { channel in
                            Text("\(channel)").tag(ChannelPickerValue.selected(channel))
                        }
                    }
                    .pickerStyle(.menu)
                }

                SectionView(title: "Interval Notation") {
                    ForEach(IntervalLabelType.allCases, id: \.self) { type in
                        if type == .symbol { Divider() }
                        Toggle(isOn: intervalBinding(for: type)) {
                            HStack { type.image; Text(type.label) }
                        }
                    }
                }

                Divider()

                SectionView(title: "Pitch Notation") {
                    ForEach(PitchLabelType.pitchCases, id: \.self) { type in
                        if type != .accidentals {
                            Toggle(isOn: pitchBinding(for: type)) {
                                HStack { type.image; Text(type.label) }
                            }

                            if type == .fixedDo {
                                Picker("", selection: accidentalBinding) {
                                    ForEach(Accidental.displayCases) { acc in
                                        Text(acc.icon).tag(acc)
                                    }
                                }
                                .pickerStyle(.segmented)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Musical Instrument Settings")
    }
    // MARK: - Channel Picker Enum

    private enum ChannelPickerValue: Hashable {
        case all
        case none
        case selected(Int)
    }

    // MARK: - MIDI Channel Bindings

    private var midiInSelection: Binding<ChannelPickerValue> {
        Binding<ChannelPickerValue>(
            get: {
                switch musicalInstrumentWidget.musicalInstrument.midiInChannelMode {
                case .all: .all
                case .none: .none
                case .selected:
                    .selected(Int(musicalInstrumentWidget.musicalInstrument.midiInChannel.rawValue) + 1)
                }
            },
            set: { newValue in
                switch newValue {
                case .all:
                    musicalInstrumentWidget.musicalInstrument.midiInChannelMode = .all
                case .none:
                    musicalInstrumentWidget.musicalInstrument.midiInChannelMode = .none
                case .selected(let channel):
                    musicalInstrumentWidget.musicalInstrument.midiInChannelMode = .selected
                    musicalInstrumentWidget.musicalInstrument.midiInChannel =
                        MIDIChannel(rawValue: MIDIChannelNumber(channel - 1)) ?? .default
                }
            }
        )
    }

    private var midiOutSelection: Binding<ChannelPickerValue> {
        Binding<ChannelPickerValue>(
            get: {
                switch musicalInstrumentWidget.musicalInstrument.midiOutChannelMode {
                case .all: .all
                case .none: .none
                case .selected:
                    .selected(Int(musicalInstrumentWidget.musicalInstrument.midiOutChannel.rawValue) + 1)
                }
            },
            set: { newValue in
                switch newValue {
                case .all:
                    musicalInstrumentWidget.musicalInstrument.midiOutChannelMode = .all
                case .none:
                    musicalInstrumentWidget.musicalInstrument.midiOutChannelMode = .none
                case .selected(let channel):
                    musicalInstrumentWidget.musicalInstrument.midiOutChannelMode = .selected
                    musicalInstrumentWidget.musicalInstrument.midiOutChannel =
                        MIDIChannel(rawValue: MIDIChannelNumber(channel - 1)) ?? .default
                }
            }
        )
    }

    
    private var outlineBinding: Binding<Bool> {
        Binding<Bool>(
            get: { musicalInstrumentWidget.musicalInstrument.showOutlines },
            set: { newValue in
                musicalInstrumentWidget.musicalInstrument.showOutlines = newValue
            }
        )
    }
    
    // MARK: - Color Palette Bindings

    private var intervalColorPaletteBinding: Binding<IntervalColorPalette?> {
        Binding<IntervalColorPalette?>(
            get: {
                musicalInstrumentWidget.musicalInstrument.intervalColorPalette
            },
            set: { newValue in
                musicalInstrumentWidget.musicalInstrument.intervalColorPalette = newValue
            }
        )
    }

    private var pitchColorPaletteBinding: Binding<PitchColorPalette?> {
        Binding<PitchColorPalette?>(
            get: {
                musicalInstrumentWidget.musicalInstrument.pitchColorPalette
            },
            set: { newValue in
                musicalInstrumentWidget.musicalInstrument.pitchColorPalette = newValue
            }
        )
    }

    // MARK: - Other Bindings

    private func intervalBinding(for type: IntervalLabelType) -> Binding<Bool> {
        Binding(
            get: {
                musicalInstrumentWidget.musicalInstrument.intervalLabelTypes.contains(type)
            },
            set: { isOn in
                if isOn {
                    musicalInstrumentWidget.musicalInstrument.intervalLabelTypes.insert(type)
                } else {
                    musicalInstrumentWidget.musicalInstrument.intervalLabelTypes.remove(type)
                }
            }
        )
    }

    private func pitchBinding(for type: PitchLabelType) -> Binding<Bool> {
        Binding(
            get: {
                musicalInstrumentWidget.musicalInstrument.pitchLabelTypes.contains(type)
            },
            set: { isOn in
                if isOn {
                    musicalInstrumentWidget.musicalInstrument.pitchLabelTypes.insert(type)
                } else {
                    musicalInstrumentWidget.musicalInstrument.pitchLabelTypes.remove(type)
                }
            }
        )
    }

    private var accidentalBinding: Binding<Accidental> {
        Binding(
            get: {
                musicalInstrumentWidget.musicalInstrument.accidental
            },
            set: {
                musicalInstrumentWidget.musicalInstrument.accidental = $0
            }
        )
    }

    private var playSynthBinding: Binding<Bool> {
        Binding(
            get: {
                musicalInstrumentWidget.musicalInstrument.playSynthSounds
            },
            set: { newValue in
                if !newValue {
                    musicalInstrumentWidget.musicalInstrument.synthConductor?.allNotesOff()
                }
                musicalInstrumentWidget.musicalInstrument.playSynthSounds = newValue
            }
        )
    }
}
private struct SectionView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            content
        }
    }
}
private struct ColorPaletteGridRow: View {
    let musicalInstrument: any MusicalInstrument
    let colorPalette: ColorPalette

    var body: some View {
        let isSelected: Bool = {
            switch colorPalette {
            case let interval as IntervalColorPalette:
                return musicalInstrument.intervalColorPalette?.id == interval.id
            case let pitch as PitchColorPalette:
                return musicalInstrument.pitchColorPalette?.id == pitch.id
            default:
                return false
            }
        }()

        HStack {
            switch colorPalette {
            case let interval as IntervalColorPalette:
                IntervalColorPaletteImage(intervalColorPalette: interval)
                    .foregroundColor(.white)
            case let pitch as PitchColorPalette:
                PitchColorPaletteImage(pitchColorPalette: pitch)
                    .foregroundColor(.white)
            default:
                EmptyView()
            }

            Text(colorPalette.name)
                .lineLimit(1)
                .foregroundColor(.white)

            Spacer()

            Image(systemName: "checkmark")
                .foregroundColor(isSelected ? .white : .clear)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            switch colorPalette {
            case let interval as IntervalColorPalette:
                musicalInstrument.intervalColorPalette = interval
                musicalInstrument.pitchColorPalette = nil
            case let pitch as PitchColorPalette:
                musicalInstrument.pitchColorPalette = pitch
                musicalInstrument.intervalColorPalette = nil
            default:
                break
            }
            buzz()
        }
        .padding(.vertical, 3)
    }
}
