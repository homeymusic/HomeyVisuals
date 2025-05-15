import SwiftUI
import SwiftData
import MIDIKitCore
import HomeyMusicKit

struct TonicPitchStatusWidgetInspect: View {
    @Bindable var tonicPitchStatusWidget: TonicPitchStatusWidget

    @Query(sort: \IntervalColorPalette.position, order: .forward)
    private var intervalColorPalettes: [IntervalColorPalette]

    @Query(sort: \PitchColorPalette.position, order: .forward)
    private var pitchColorPalettes: [PitchColorPalette]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
                SectionView(title: "Color Palette") {
                    VStack(spacing: 4) {
                        ForEach(intervalColorPalettes, id: \.self) { palette in
                            ColorPaletteGridRow(
                                tonalityInstrument: tonicPitchStatusWidget.tonalityInstrument,
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
                                tonalityInstrument: tonicPitchStatusWidget.tonalityInstrument,
                                colorPalette: palette
                            )
                        }
                    }
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
                switch tonicPitchStatusWidget.tonalityInstrument.midiInChannelMode {
                case .all: .all
                case .none: .none
                case .selected:
                    .selected(Int(tonicPitchStatusWidget.tonalityInstrument.midiInChannel.rawValue) + 1)
                }
            },
            set: { newValue in
                switch newValue {
                case .all:
                    tonicPitchStatusWidget.tonalityInstrument.midiInChannelMode = .all
                case .none:
                    tonicPitchStatusWidget.tonalityInstrument.midiInChannelMode = .none
                case .selected(let channel):
                    tonicPitchStatusWidget.tonalityInstrument.midiInChannelMode = .selected
                    tonicPitchStatusWidget.tonalityInstrument.midiInChannel =
                        MIDIChannel(rawValue: MIDIChannelNumber(channel - 1)) ?? .default
                }
            }
        )
    }

    private var midiOutSelection: Binding<ChannelPickerValue> {
        Binding<ChannelPickerValue>(
            get: {
                switch tonicPitchStatusWidget.tonalityInstrument.midiOutChannelMode {
                case .all: .all
                case .none: .none
                case .selected:
                    .selected(Int(tonicPitchStatusWidget.tonalityInstrument.midiOutChannel.rawValue) + 1)
                }
            },
            set: { newValue in
                switch newValue {
                case .all:
                    tonicPitchStatusWidget.tonalityInstrument.midiOutChannelMode = .all
                case .none:
                    tonicPitchStatusWidget.tonalityInstrument.midiOutChannelMode = .none
                case .selected(let channel):
                    tonicPitchStatusWidget.tonalityInstrument.midiOutChannelMode = .selected
                    tonicPitchStatusWidget.tonalityInstrument.midiOutChannel =
                        MIDIChannel(rawValue: MIDIChannelNumber(channel - 1)) ?? .default
                }
            }
        )
    }

    
    private var outlineBinding: Binding<Bool> {
        Binding<Bool>(
            get: { tonicPitchStatusWidget.tonalityInstrument.showOutlines },
            set: { newValue in
                tonicPitchStatusWidget.tonalityInstrument.showOutlines = newValue
            }
        )
    }
    
    // MARK: - Color Palette Bindings

    private var intervalColorPaletteBinding: Binding<IntervalColorPalette?> {
        Binding<IntervalColorPalette?>(
            get: {
                tonicPitchStatusWidget.tonalityInstrument.intervalColorPalette
            },
            set: { newValue in
                tonicPitchStatusWidget.tonalityInstrument.intervalColorPalette = newValue
            }
        )
    }

    private var pitchColorPaletteBinding: Binding<PitchColorPalette?> {
        Binding<PitchColorPalette?>(
            get: {
                tonicPitchStatusWidget.tonalityInstrument.pitchColorPalette
            },
            set: { newValue in
                tonicPitchStatusWidget.tonalityInstrument.pitchColorPalette = newValue
            }
        )
    }

    // MARK: - Other Bindings

    private func tonalityControlBinding(for type: TonalityControlType) -> Binding<Bool> {
        Binding(
            get: {
                tonicPitchStatusWidget.tonalityInstrument.tonalityControlTypes.contains(type)
            },
            set: { isOn in
                if isOn {
                    tonicPitchStatusWidget.tonalityInstrument.tonalityControlTypes.insert(type)
                } else {
                    tonicPitchStatusWidget.tonalityInstrument.tonalityControlTypes.remove(type)
                }
            }
        )
    }
    
    private func intervalBinding(for type: IntervalLabelType) -> Binding<Bool> {
        Binding(
            get: {
                tonicPitchStatusWidget.tonalityInstrument.intervalLabelTypes.contains(type)
            },
            set: { isOn in
                if isOn {
                    tonicPitchStatusWidget.tonalityInstrument.intervalLabelTypes.insert(type)
                } else {
                    tonicPitchStatusWidget.tonalityInstrument.intervalLabelTypes.remove(type)
                }
            }
        )
    }

    private func pitchBinding(for type: PitchLabelType) -> Binding<Bool> {
        Binding(
            get: {
                tonicPitchStatusWidget.tonalityInstrument.pitchLabelTypes.contains(type)
            },
            set: { isOn in
                if isOn {
                    tonicPitchStatusWidget.tonalityInstrument.pitchLabelTypes.insert(type)
                } else {
                    tonicPitchStatusWidget.tonalityInstrument.pitchLabelTypes.remove(type)
                }
            }
        )
    }

    private var accidentalBinding: Binding<Accidental> {
        Binding(
            get: {
                tonicPitchStatusWidget.tonalityInstrument.accidental
            },
            set: {
                tonicPitchStatusWidget.tonalityInstrument.accidental = $0
            }
        )
    }

    private var showMIDINoteBinding: Binding<Bool> {
        Binding(
            get: {
                tonicPitchStatusWidget.tonalityInstrument.pitchLabelTypes.contains(.midi)
            },
            set: { newValue in
                tonicPitchStatusWidget.tonalityInstrument.showMIDIVelocity = newValue
            }
        )
    }
    
    private var layoutBinding: Binding<TonalityInstrumentLayoutType> {
        Binding(
            get: {
                tonicPitchStatusWidget.tonalityInstrument.tonalityInstrumentLayoutType
            },
            set: {
                tonicPitchStatusWidget.tonalityInstrument.tonalityInstrumentLayoutType = $0
                buzz()
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
    let tonalityInstrument: TonalityInstrument
    let colorPalette: ColorPalette

    var body: some View {
        let isSelected: Bool = {
            switch colorPalette {
            case let interval as IntervalColorPalette:
                return tonalityInstrument.intervalColorPalette?.id == interval.id
            case let pitch as PitchColorPalette:
                return tonalityInstrument.pitchColorPalette?.id == pitch.id
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
                tonalityInstrument.intervalColorPalette = interval
                tonalityInstrument.pitchColorPalette = nil
            case let pitch as PitchColorPalette:
                tonalityInstrument.pitchColorPalette = pitch
                tonalityInstrument.intervalColorPalette = nil
            default:
                break
            }
            buzz()
        }
        .padding(.vertical, 3)
    }
}
