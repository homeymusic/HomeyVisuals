import SwiftUI
import MIDIKitCore
import HomeyMusicKit

struct MusicalInstrumentWidgetInspect: View {
    @Bindable var musicalInstrumentWidget: MusicalInstrumentWidget

    var body: some View {
        Form {
            Section("Audio and MIDI") {
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

            Section("Interval Notation") {
                ForEach(IntervalLabelType.allCases, id: \.self) { intervalLabelType in
                    if intervalLabelType == .symbol {
                        Divider()
                    }
                    Toggle(isOn: intervalBinding(for: intervalLabelType)) {
                        HStack {
                            intervalLabelType.image
                            Text(intervalLabelType.label)
                        }
                    }
                }
            }

            Divider()

            Section("Pitch Notation") {
                ForEach(PitchLabelType.pitchCases, id: \.self) { pitchLabelType in
                    if pitchLabelType != .accidentals {
                        Toggle(isOn: pitchBinding(for: pitchLabelType)) {
                            HStack {
                                pitchLabelType.image
                                Text(pitchLabelType.label)
                            }
                        }

                        if pitchLabelType == .fixedDo {
                            Picker("", selection: accidentalBinding) {
                                ForEach(Accidental.displayCases) { accidental in
                                    Text(accidental.icon).tag(accidental)
                                }
                            }
                            .pickerStyle(.segmented)
                        }
                    }
                }
            }
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
                case .all:
                    return .all
                case .none:
                    return .none
                case .selected:
                    return .selected(Int(musicalInstrumentWidget.musicalInstrument.midiInChannel.rawValue) + 1)
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
                case .all:
                    return .all
                case .none:
                    return .none
                case .selected:
                    return .selected(Int(musicalInstrumentWidget.musicalInstrument.midiOutChannel.rawValue) + 1)
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

    // MARK: - Label Bindings

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
                print("playSynthBinding", newValue)
                if !newValue {
                    musicalInstrumentWidget.musicalInstrument.synthConductor?.allNotesOff()
                }
                musicalInstrumentWidget.musicalInstrument.playSynthSounds = newValue
            }
        )
    }
}
