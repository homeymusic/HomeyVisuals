import SwiftUI
import SwiftData
import MIDIKitCore
import HomeyMusicKit

struct MIDIMonitorWidgetInspect: View {
    @Bindable var midiMonitorWidget: MIDIMonitorWidget

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
                                tonalityInstrument: midiMonitorWidget.tonalityInstrument,
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
                                tonalityInstrument: midiMonitorWidget.tonalityInstrument,
                                colorPalette: palette
                            )
                        }
                    }
                }

                SectionView(title: "Audio and MIDI") {
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
                switch midiMonitorWidget.tonalityInstrument.midiInChannelMode {
                case .all: .all
                case .none: .none
                case .selected:
                    .selected(Int(midiMonitorWidget.tonalityInstrument.midiInChannel.rawValue) + 1)
                }
            },
            set: { newValue in
                switch newValue {
                case .all:
                    midiMonitorWidget.tonalityInstrument.midiInChannelMode = .all
                case .none:
                    midiMonitorWidget.tonalityInstrument.midiInChannelMode = .none
                case .selected(let channel):
                    midiMonitorWidget.tonalityInstrument.midiInChannelMode = .selected
                    midiMonitorWidget.tonalityInstrument.midiInChannel =
                        MIDIChannel(rawValue: MIDIChannelNumber(channel - 1)) ?? .default
                }
            }
        )
    }

    private var midiOutSelection: Binding<ChannelPickerValue> {
        Binding<ChannelPickerValue>(
            get: {
                switch midiMonitorWidget.tonalityInstrument.midiOutChannelMode {
                case .all: .all
                case .none: .none
                case .selected:
                    .selected(Int(midiMonitorWidget.tonalityInstrument.midiOutChannel.rawValue) + 1)
                }
            },
            set: { newValue in
                switch newValue {
                case .all:
                    midiMonitorWidget.tonalityInstrument.midiOutChannelMode = .all
                case .none:
                    midiMonitorWidget.tonalityInstrument.midiOutChannelMode = .none
                case .selected(let channel):
                    midiMonitorWidget.tonalityInstrument.midiOutChannelMode = .selected
                    midiMonitorWidget.tonalityInstrument.midiOutChannel =
                        MIDIChannel(rawValue: MIDIChannelNumber(channel - 1)) ?? .default
                }
            }
        )
    }

    
    private var outlineBinding: Binding<Bool> {
        Binding<Bool>(
            get: { midiMonitorWidget.tonalityInstrument.showOutlines },
            set: { newValue in
                midiMonitorWidget.tonalityInstrument.showOutlines = newValue
            }
        )
    }
    
    // MARK: - Other Bindings

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
