import SwiftUI
import SwiftData
import MIDIKitCore
import HomeyMusicKit

struct TonalityInstrumentWidgetInspect: View {
    @Bindable var tonalityInstrumentWidget: TonalityInstrumentWidget

    @Query(sort: \IntervalColorPalette.position, order: .forward)
    private var intervalColorPalettes: [IntervalColorPalette]

    @Query(sort: \PitchColorPalette.position, order: .forward)
    private var pitchColorPalettes: [PitchColorPalette]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                SectionView(title: "Keyboard Layout") {
                    Text("TODO: add the ability to toggle between piano view and homey music view")
                }
                
                SectionView(title: "Audio and MIDI") {
                    Toggle(isOn: pitchBinding(for: PitchLabelType.midi)) {
                        HStack { PitchLabelType.midi.image; Text(PitchLabelType.midi.label) }
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
                
                SectionView(title: "Tonality Controls") {
                    ForEach(TonalityControlType.allCases, id: \.self) { type in
                        Toggle(isOn: tonalityControlBinding(for: type)) {
                            HStack { type.image; Text(type.label) }
                        }
                    }
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
                switch tonalityInstrumentWidget.tonalityInstrument.midiInChannelMode {
                case .all: .all
                case .none: .none
                case .selected:
                    .selected(Int(tonalityInstrumentWidget.tonalityInstrument.midiInChannel.rawValue) + 1)
                }
            },
            set: { newValue in
                switch newValue {
                case .all:
                    tonalityInstrumentWidget.tonalityInstrument.midiInChannelMode = .all
                case .none:
                    tonalityInstrumentWidget.tonalityInstrument.midiInChannelMode = .none
                case .selected(let channel):
                    tonalityInstrumentWidget.tonalityInstrument.midiInChannelMode = .selected
                    tonalityInstrumentWidget.tonalityInstrument.midiInChannel =
                        MIDIChannel(rawValue: MIDIChannelNumber(channel - 1)) ?? .default
                }
            }
        )
    }

    private var midiOutSelection: Binding<ChannelPickerValue> {
        Binding<ChannelPickerValue>(
            get: {
                switch tonalityInstrumentWidget.tonalityInstrument.midiOutChannelMode {
                case .all: .all
                case .none: .none
                case .selected:
                    .selected(Int(tonalityInstrumentWidget.tonalityInstrument.midiOutChannel.rawValue) + 1)
                }
            },
            set: { newValue in
                switch newValue {
                case .all:
                    tonalityInstrumentWidget.tonalityInstrument.midiOutChannelMode = .all
                case .none:
                    tonalityInstrumentWidget.tonalityInstrument.midiOutChannelMode = .none
                case .selected(let channel):
                    tonalityInstrumentWidget.tonalityInstrument.midiOutChannelMode = .selected
                    tonalityInstrumentWidget.tonalityInstrument.midiOutChannel =
                        MIDIChannel(rawValue: MIDIChannelNumber(channel - 1)) ?? .default
                }
            }
        )
    }

    
    private var outlineBinding: Binding<Bool> {
        Binding<Bool>(
            get: { tonalityInstrumentWidget.tonalityInstrument.showOutlines },
            set: { newValue in
                tonalityInstrumentWidget.tonalityInstrument.showOutlines = newValue
            }
        )
    }
    
    // MARK: - Color Palette Bindings

    private var intervalColorPaletteBinding: Binding<IntervalColorPalette?> {
        Binding<IntervalColorPalette?>(
            get: {
                tonalityInstrumentWidget.tonalityInstrument.intervalColorPalette
            },
            set: { newValue in
                tonalityInstrumentWidget.tonalityInstrument.intervalColorPalette = newValue
            }
        )
    }

    private var pitchColorPaletteBinding: Binding<PitchColorPalette?> {
        Binding<PitchColorPalette?>(
            get: {
                tonalityInstrumentWidget.tonalityInstrument.pitchColorPalette
            },
            set: { newValue in
                tonalityInstrumentWidget.tonalityInstrument.pitchColorPalette = newValue
            }
        )
    }

    // MARK: - Other Bindings

    private func tonalityControlBinding(for type: TonalityControlType) -> Binding<Bool> {
        Binding(
            get: {
                tonalityInstrumentWidget.tonalityInstrument.tonalityControlTypes.contains(type)
            },
            set: { isOn in
                if isOn {
                    tonalityInstrumentWidget.tonalityInstrument.tonalityControlTypes.insert(type)
                } else {
                    tonalityInstrumentWidget.tonalityInstrument.tonalityControlTypes.remove(type)
                }
            }
        )
    }
    
    private func intervalBinding(for type: IntervalLabelType) -> Binding<Bool> {
        Binding(
            get: {
                tonalityInstrumentWidget.tonalityInstrument.intervalLabelTypes.contains(type)
            },
            set: { isOn in
                if isOn {
                    tonalityInstrumentWidget.tonalityInstrument.intervalLabelTypes.insert(type)
                } else {
                    tonalityInstrumentWidget.tonalityInstrument.intervalLabelTypes.remove(type)
                }
            }
        )
    }

    private func pitchBinding(for type: PitchLabelType) -> Binding<Bool> {
        Binding(
            get: {
                tonalityInstrumentWidget.tonalityInstrument.pitchLabelTypes.contains(type)
            },
            set: { isOn in
                if isOn {
                    tonalityInstrumentWidget.tonalityInstrument.pitchLabelTypes.insert(type)
                } else {
                    tonalityInstrumentWidget.tonalityInstrument.pitchLabelTypes.remove(type)
                }
            }
        )
    }

    private var accidentalBinding: Binding<Accidental> {
        Binding(
            get: {
                tonalityInstrumentWidget.tonalityInstrument.accidental
            },
            set: {
                tonalityInstrumentWidget.tonalityInstrument.accidental = $0
            }
        )
    }

    private var showMIDINoteBinding: Binding<Bool> {
        Binding(
            get: {
                tonalityInstrumentWidget.tonalityInstrument.pitchLabelTypes.contains(.midi)
            },
            set: { newValue in
                tonalityInstrumentWidget.tonalityInstrument.showMIDIVelocity = newValue
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
