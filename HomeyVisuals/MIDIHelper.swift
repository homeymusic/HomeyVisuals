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
    public private(set) var paletteOfNotes = Set<Int>()
    
    public func resetPaletteOfNotes() {
        self.paletteOfNotes = []
    }
    
    public func reset() {
        resetPaletteOfNotes()
        resetTurnedOnPitches()
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
    
    static public var majorColor: Color {
        Color(#colorLiteral(red: 1, green: 0.6745098039, blue: 0.2, alpha: 1))
    }
    
    static public var neutralColor: Color {
        Color(#colorLiteral(red: 0.9529411765, green: 0.8666666667, blue: 0.6705882353, alpha: 1))
    }
    
    static public var minorColor: Color {
        Color(#colorLiteral(red: 0.3647058824, green: 0.6784313725, blue: 0.9254901961, alpha: 1))
    }
    
    public var pitchDirectionIconColor: Color {
        if upwardPitchDirection {
            MIDIHelper.majorColor
        } else {
            MIDIHelper.minorColor
        }
    }
    
    public var chordShapeIconName: String {
        if chordLabel.contains("Major Inverted") || chordLabel.contains("Mixolydian Inverted") {
            "xmark.square.fill"
        } else if chordLabel.contains("Phrygian Inverted") || chordLabel.contains("Minor Inverted")  {
            "i.square.fill"
        } else if chordLabel.contains("Major") || chordLabel.contains("Mixolydian") {
            "plus.square.fill"
        } else if chordLabel.contains("Phrygian") || chordLabel.contains("Minor")  {
            "minus.square.fill"
        } else {
            "plusminus"
        }
    }
    
    public var chordShapeIconColor: Color {
        if chordLabel.contains("Major") || chordLabel.contains("Mixolydian") {
            MIDIHelper.majorColor
        } else if chordLabel.contains("Phrygian") || chordLabel.contains("Minor")  {
            MIDIHelper.minorColor
        } else {
            Color.clear
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
    
    private func integerNotes() -> Array<Int> {
        var integerNotes: Array<Int> = Array<Int>()
        let turnedOnNotes = self.turnedOnPitches.sorted(by: <)
        if !turnedOnNotes.isEmpty {
            for note in turnedOnNotes {
                integerNotes.append((note - (self.upwardPitchDirection ? turnedOnNotes.first! : turnedOnNotes.last!)) % 12)
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

            var majorMinor: String = if (chord.contains(4) && chord.contains(7)) ||
            (chord.contains(3) && chord.contains(8)) ||
            (chord.contains(5) && chord.contains(9)) {
                "Major"
            } else if (chord.contains(-3) && chord.contains(-7)) ||
                        (chord.contains(-4) && chord.contains(-9)) ||
                        (chord.contains(-5) && chord.contains(-8)) {
                "Mixolydian"
            } else if (chord.contains(3) && chord.contains(7)) ||
                        (chord.contains(4) && chord.contains(9)) ||
                        (chord.contains(5) && chord.contains(8)) {
                "Minor"
            } else if (chord.contains(-4) && chord.contains(-7)) ||
                        (chord.contains(-3) && chord.contains(-8)) ||
                        (chord.contains(-5) && chord.contains(-9)) {
                "Phrygian"
            } else {
                ""
            }
            majorMinor = majorMinor + (span(of: self.turnedOnPitches) > 7 ? " Inverted" : "")
            DispatchQueue.main.async {
                self.chordLabel = "\(majorMinor)"
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
            
            scaleDegree = if (rootToTonicDistance == 0) {
                "\(prefix)1\(caret)"
            } else {
                switch MIDIHelper.mod(rootToTonicDistance, 12) {
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
                case 0:
                    "\(prefix)8\(caret)"
                default: ""
                }
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
