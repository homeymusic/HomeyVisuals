import SwiftUI
import MIDIKitCore
import HomeyMusicKit

struct InstrumentWidgetInspect: View {
    @Bindable var instrumentWidget: InstrumentWidget

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
        .navigationTitle("Instrument Settings")
    }

    private var inSelection: Binding<Int> {
        Binding<Int>(
            get: {
                instrumentWidget.instrument.allMIDIInChannels
                    ? 0
                    : Int(instrumentWidget.instrument.midiInChannel.rawValue) + 1
            },
            set: { newValue in
                if newValue == 0 {
                    instrumentWidget.instrument.allMIDIInChannels = true
                } else {
                    instrumentWidget.instrument.allMIDIInChannels = false
                    // newValue is guaranteed 1…16, so newValue-1 is 0…15
                    let raw = MIDIChannelNumber(newValue - 1)
                    instrumentWidget.instrument.midiInChannel =
                        MIDIChannel(rawValue: raw) ?? .default
                }
            }
        )
    }

    private var outSelection: Binding<Int> {
        Binding<Int>(
            get: {
                instrumentWidget.instrument.allMIDIOutChannels
                    ? 0
                    : Int(instrumentWidget.instrument.midiOutChannel.rawValue) + 1
            },
            set: { newValue in
                if newValue == 0 {
                    instrumentWidget.instrument.allMIDIOutChannels = true
                } else {
                    instrumentWidget.instrument.allMIDIOutChannels = false
                    let raw = MIDIChannelNumber(newValue - 1)
                    instrumentWidget.instrument.midiOutChannel =
                        MIDIChannel(rawValue: raw) ?? .default
                }
            }
        )
    }
}
