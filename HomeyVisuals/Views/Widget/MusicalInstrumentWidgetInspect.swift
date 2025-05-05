import SwiftUI
import MIDIKitCore
import HomeyMusicKit

struct MusicalInstrumentWidgetInspect: View {
    @Bindable var musicalInstrumentWidget: MusicalInstrumentWidget

    // 0 = All, 1–16 = channels
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
        }
        .navigationTitle("Musical Instrument Settings")
    }

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
                    // newValue is guaranteed 1…16, so newValue-1 is 0…15
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
}
