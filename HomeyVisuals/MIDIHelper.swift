//
//  MIDIHelper.swift
//  MIDIKit • https://github.com/orchetect/MIDIKit
//  © 2021-2023 Steffan Andrews • Licensed under MIT License
//

import MIDIKitIO
import SwiftUI

/// Receiving MIDI happens as an asynchronous background callback. That means it cannot update
/// SwiftUI view state directly. Therefore, we need a helper class that conforms to
/// `ObservableObject` which contains `@Published` properties that SwiftUI can use to update views.
final class MIDIHelper: ObservableObject {
    private weak var midiManager: ObservableMIDIManager?
    
    @Published
    public private(set) var turnedOnPitches = Set<Int>() {
        didSet {
            if oldValue != self.turnedOnPitches {
                self.updateChordIntegerLabel()
                self.updateChordLabel()
                self.updateDegreeLabel()
            }
        }
    }
    public func resetTurnedOnPitches() {
        self.turnedOnPitches = []
    }
    
    
    @Published
    public var paletteOfNotes = Set<Int>()
    
    @Published
    public var hoveredNote: Int? = nil
    
    public func resetPaletteOfNotes() {
        self.paletteOfNotes = []
    }
    
    public func reset() {
        resetPaletteOfNotes()
        resetTurnedOnPitches()
    }
    
    public func togglePitchDirection() {
        reset()
        self.upwardPitchDirection.toggle()
    }
    
    @Published
    public private(set) var chordIntegerLabel: String = ""
    
    @Published
    public private(set) var chordLabel: String = ""
    
    @Published
    public private(set) var degreeLabel: String = ""
    
    @Published
    public private(set) var tonicNote: Int8 = 60 {
        didSet {
            if oldValue != self.tonicNote {
                resetPaletteOfNotes()
            }
        }
    }
    
    @Published
    public private(set) var upwardPitchDirection: Bool = true
    
    
    public var pitchDirectionIconName: String {
        if upwardPitchDirection {
            "greaterthan.square"
        } else {
            "lessthan.square"
        }
    }
    
    static public var majorColor: NSColor {
        #colorLiteral(red: 1, green: 0.6745098039, blue: 0.2, alpha: 1)
    }
    
    static public var neutralColor: NSColor {
        #colorLiteral(red: 0.952941, green: 0.866667, blue: 0.670588, alpha: 1)
    }
    
    static public var neutralDissonantColor: NSColor {
        #colorLiteral(red: 1, green: 0.333333, blue: 0, alpha: 1)
    }
    
    static public var minorColor: NSColor {
        #colorLiteral(red: 0.3647058824, green: 0.6784313725, blue: 0.9254901961, alpha: 1)
    }
    
    public var pitchDirectionIconColor: NSColor {
        if upwardPitchDirection {
            MIDIHelper.majorColor
        } else {
            MIDIHelper.minorColor
        }
    }
    
    public var chordShapeIconName: String {
        if chordLabel.contains("Diminished") || chordLabel.contains("Dominant 7th") {
            "asterisk.circle.fill"
            
        } else if chordLabel == "Major Inverted" || chordLabel == "Major 7th" || chordLabel == "Major 6th" || chordLabel == "Mixolydian Inverted" || chordLabel == "Mixolydian 6th" || chordLabel == "Mixolydian 7th" || chordLabel == "Mixolydian Phrygian 7th"{
            "xmark.circle.fill"
        } else if chordLabel == "Phrygian Dominant 7th" || chordLabel == "Phrygian 7th" || chordLabel == "Phrygian 6th" || chordLabel == "Phrygian Inverted" || chordLabel == "Minor Inverted" || chordLabel == "Minor 6th" || chordLabel == "Minor 7th" || chordLabel == "Minor Major 7th" {
            "i.circle.fill"
        } else if chordLabel == "Major" || chordLabel == "Mixolydian" {
            "plus.circle.fill"
        } else if chordLabel == "Phrygian" || chordLabel == "Minor"  {
            "minus.circle.fill"
        } else {
            "circle"
        }
    }
    
    public var chordShapeIconColor: NSColor {
        if chordLabel.contains("Mixolydian Phrygian") {
            MIDIHelper.majorColor
        } else if chordLabel.contains("Minor Major") {
            MIDIHelper.minorColor
        } else if chordLabel.contains("Phrygian") || chordLabel.contains("Minor")  {
            MIDIHelper.minorColor
        } else if chordLabel.contains("Major") || chordLabel.contains("Mixolydian") || chordLabel.contains("Dominant") {
            MIDIHelper.majorColor
        } else if chordLabel == "Diminished" {
            MIDIHelper.neutralColor
        } else {
            NSColor.clear
        }
    }
    
    public init() { }
    
    public func setup(midiManager: ObservableMIDIManager) {
        self.midiManager = midiManager
        
        do {
            print("Starting MIDI services.")
            try midiManager.start()
        } catch {
            print("Error starting MIDI services:", error.localizedDescription)
        }
        
        do {
            
            try midiManager.addInputConnection(
                to: .none,
                tag: Tags.midiIn,
                receiver: .events { [weak self] events, timeStamp, source in
                    events.forEach { self?.trackNotesOn(event: $0) }
                }
            )
            
        } catch {
            print("Error creating MIDI connections:", error.localizedDescription)
        }
        
    }
    
    private func trackNotesOn(event: MIDIEvent) {
        switch event {
        case let .cc(payload):
            print("payload.controller", payload.controller)
            print("MIDIEvent.CC.Controller.generalPurpose1", MIDIEvent.CC.Controller.generalPurpose1)
            print("MIDIEvent.CC.Controller.generalPurpose2", MIDIEvent.CC.Controller.generalPurpose2)
            DispatchQueue.main.async {
                switch payload.controller {
                case MIDIEvent.CC.Controller.generalPurpose1:
                    self.tonicNote = Int8(payload.value.midi1Value.intValue)
                case MIDIEvent.CC.Controller.generalPurpose2:
                    self.upwardPitchDirection = payload.value.midi1Value.intValue == 1 ? true : false
                default:
                    print("ignoring cc \(payload.channel.intValue)")
                }
            }
        case let .noteOn(payload):
            if (!turnedOnPitches.contains(payload.note.number.intValue)) {
                DispatchQueue.main.async {
                    self.turnedOnPitches.insert(payload.note.number.intValue)
                }
            }
            if (!paletteOfNotes.contains(payload.note.number.intValue)) {
                DispatchQueue.main.async {
                    self.paletteOfNotes.insert(payload.note.number.intValue)
                }
            }
        case let .noteOff(payload):
            DispatchQueue.main.async {
                self.turnedOnPitches.remove(payload.note.number.intValue)
            }
        default:
            print("other")
        }
        print("turnedOnNotes", turnedOnPitches)
    }
    
    // MARK: - MIDI Input Connection
    
    public var midiInputConnection: MIDIInputConnection? {
        midiManager?.managedInputConnections[Tags.midiIn]
    }
    
    private func integerNotes() -> Set<Int> {
        var integerNotes: Set<Int> = Set<Int>()
        let turnedOnNotes = self.turnedOnPitches.sorted(by: <)
        if !turnedOnNotes.isEmpty {
            for note in turnedOnNotes {
                integerNotes.insert((note - (self.upwardPitchDirection ? turnedOnNotes.first! : turnedOnNotes.last!)) % 12)
            }
        }
        return integerNotes
    }
    
    public func updateChordIntegerLabel() {
        let chord = integerNotes().sorted(by: <)
        
        DispatchQueue.main.async {
            self.chordIntegerLabel = chord.map {note in
                String(note)
            }.joined(separator: ",")
        }
    }
    
    public func updateChordLabel() {
        if !turnedOnPitches.isEmpty {
            
            let chord = integerNotes()
            print("Integer notes: \(chord)")
            let chordLabel: String =
            if chord == [0,4,7] {
                "Major"
            } else if chord == [0,4,7,9] {
                "Major 6th"
            } else if chord == [0,4,7,11] {
                "Major 7th"
            } else if chord == [0,4,7,10] {
                "Dominant 7th"
            } else if chord == [0,3,8] || chord == [0,5,9] {
                "Major Inverted"
            } else if chord == [0,-3,-7] {
                "Mixolydian"
            } else if chord == [0,-3,-7,-9] {
                "Mixolydian 6th"
            } else if chord == [0,-3,-7,-10] {
                "Mixolydian 7th"
            } else if chord == [0,-3,-7,-11] {
                "Mixolydian Phrygian 7th"
            } else if chord == [0,-4,-9] || chord == [0,-5,-8] {
                "Mixolydian Inverted"
            } else if chord == [0,3,7] {
                "Minor"
            } else if chord == [0,3,7,9] {
                "Minor 6th"
            } else if chord == [0,3,7,10] {
                "Minor 7th"
            } else if chord == [0,3,7,11] {
                "Minor Major 7th"
            } else if chord == [0,4,9] || chord == [0,5,8] {
                "Minor Inverted"
            } else if chord == [0,-4,-7] {
                "Phrygian"
            } else if chord == [0,-4,-7,-9] {
                "Phrygian 6th"
            } else if chord == [0,-4,-7,-11] {
                "Phrygian 7th"
            } else if chord == [0,-4,-7,-10] {
                "Phrygian Dominant 7th"
            } else if chord == [0,-3,-8] || chord == [0,-5,-9] {
                "Phrygian Inverted"
            } else if chord == [0,3,6] || chord == [0,-3,-6] ||
                        chord == [0,6,9] || chord == [0,-6,-9] ||
                        chord == [0,3,9] || chord == [0,-3,-9] {
                "Diminished"
            } else {
                ""
            }
            DispatchQueue.main.async {
                self.chordLabel = chordLabel
            }
        } else {
            DispatchQueue.main.async {
                self.chordLabel = ""
            }
        }
        
    }
    
    public func span(of set: Set<Int>) -> Int {
        guard let minValue = set.min(), let maxValue = set.max() else {
            return 0
        }
        return maxValue - minValue
    }
    
    public func updateDegreeLabel() {
        var scaleDegree: String = ""
        if !turnedOnPitches.isEmpty {
            
            let accidental = self.upwardPitchDirection ? "♭" : "♯"
            let prefix = self.upwardPitchDirection ? "" : "<"
            let caret = "\u{0302}"
            let tritone = self.upwardPitchDirection ? "\(prefix)♭5\(caret)" : "\(prefix)♯5\(caret)"
            let turnedOnNotes = self.turnedOnPitches.sorted(by: <)
            print("turnedOnNotes.last!", turnedOnNotes.last!)
            let rootToTonicDistance = self.upwardPitchDirection ? (Int(turnedOnNotes.first!)  - Int(self.tonicNote)) : (Int(self.tonicNote) - Int(turnedOnNotes.last!))
            
            print("rootToTonicDistance", rootToTonicDistance)
            
            scaleDegree = switch MIDIHelper.mod(rootToTonicDistance, 12) {
            case 0:
                "\(prefix)1\(caret)"
            case 1:
                "\(prefix)\(accidental)2\(caret)"
            case 2:
                "\(prefix)2\(caret)"
            case 3:
                "\(prefix)\(accidental)3\(caret)"
            case 4:
                "\(prefix)3\(caret)"
            case 5:
                "\(prefix)4\(caret)"
            case 6:
                tritone
            case 7:
                "\(prefix)5\(caret)"
            case 8:
                "\(prefix)\(accidental)6\(caret)"
            case 9:
                "\(prefix)6\(caret)"
            case 10:
                "\(prefix)\(accidental)7\(caret)"
            case 11 :
                "\(prefix)7\(caret)"
            default: ""
            }
        }
        DispatchQueue.main.async {
            self.degreeLabel = scaleDegree
        }
    }
    
    
    public static func mod(_ a: Int, _ n: Int) -> Int {
        precondition(n > 0, "modulus must be positive")
        let r = a % n
        return r >= 0 ? r : r + n
    }
}

// MARK: - String Constants

extension MIDIHelper {
    enum Tags {
        static let midiIn = "SelectedInputConnection"
    }
    
    enum PrefKeys {
        static let midiInID = "SelectedMIDIInID"
        static let midiInDisplayName = "SelectedMIDIInDisplayName"
    }
    
    enum Defaults {
        static let selectedDisplayName = "None"
    }
}
