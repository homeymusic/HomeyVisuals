import SwiftUI
import MIDIKitCore
import HomeyMusicKit

struct MusicalInstrumentWidgetInspect: View {
    @Bindable var musicalInstrumentWidget: MusicalInstrumentWidget

    private let channelIndices = Array(0...16)

    var body: some View {
        Form {
            Section("MIDI Input Channel") {
                Picker("In", selection: inSelection) {
                    ForEach(channelIndices, id: \.self) { idx in
                        Text(idx == 0 ? "All" : "\(idx)").tag(idx)
                    }
                }
                .pickerStyle(.menu)
            }

            Section("MIDI Output Channel") {
                Picker("Out", selection: outSelection) {
                    ForEach(channelIndices, id: \.self) { idx in
                        Text(idx == 0 ? "All" : "\(idx)").tag(idx)
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
                        Label(intervalLabelType.label, systemImage: intervalLabelType.icon)
                    }
                }
            }

            Divider()
            
            Section("Pitch Notation") {
                ForEach(PitchLabelType.pitchCases, id: \.self) { pitchLabelType in
                    if pitchLabelType != .accidentals {
                        Toggle(isOn: pitchBinding(for: pitchLabelType)) {
                            Label(pitchLabelType.label, systemImage: pitchLabelType.icon)
                        }

                        if pitchLabelType == .fixedDo {
                            Picker("Accidentals", selection: accidentalBinding) {
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

    // MARK: - MIDI Channel Bindings

    private var inSelection: Binding<Int> {
        Binding<Int>(
            get: {
                musicalInstrumentWidget.musicalInstrument.allMIDIInChannels
                    ? 0
                    : Int(musicalInstrumentWidget.musicalInstrument.midiInChannel.rawValue) + 1
            },
            set: { newValue in
                if newValue == 0 {
                    musicalInstrumentWidget.musicalInstrument.allMIDIInChannels = true
                } else {
                    musicalInstrumentWidget.musicalInstrument.allMIDIInChannels = false
                    let raw = MIDIChannelNumber(newValue - 1)
                    musicalInstrumentWidget.musicalInstrument.midiInChannel =
                        MIDIChannel(rawValue: raw) ?? .default
                }
            }
        )
    }

    private var outSelection: Binding<Int> {
        Binding<Int>(
            get: {
                musicalInstrumentWidget.musicalInstrument.allMIDIOutChannels
                    ? 0
                    : Int(musicalInstrumentWidget.musicalInstrument.midiOutChannel.rawValue) + 1
            },
            set: { newValue in
                if newValue == 0 {
                    musicalInstrumentWidget.musicalInstrument.allMIDIOutChannels = true
                } else {
                    musicalInstrumentWidget.musicalInstrument.allMIDIOutChannels = false
                    let raw = MIDIChannelNumber(newValue - 1)
                    musicalInstrumentWidget.musicalInstrument.midiOutChannel =
                        MIDIChannel(rawValue: raw) ?? .default
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
}
