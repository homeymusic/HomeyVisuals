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
    
    @Published
    public private(set) var paletteOfNotes = Array<Int>() {
        didSet {
            if oldValue != self.paletteOfNotes {
            }
        }
    }
    
    @Published
    public private(set) var chordIntegerLabel: String = ""

    @Published
    public private(set) var chordLabel: String = ""

    @Published
    public private(set) var degreeLabel: String = ""

    @Published
    public private(set) var tonicNote: Int = 60 {
        didSet {
            if oldValue != self.tonicNote {
                paletteOfNotes = []
            }
        }
    }

    @Published
    public private(set) var upwardPitchDirection: Bool = true

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
            DispatchQueue.main.async {
                switch payload.controller {
                case MIDIEvent.CC.Controller.generalPurpose1:
                    self.tonicNote = payload.value.midi1Value.intValue
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
                    self.paletteOfNotes.append(payload.note.number.intValue)
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
    
    private func extraInterval(chord: Array<Int>) -> String {
        return if chord.contains(8) || chord.contains(9) ||
                    chord.contains(-8) || chord.contains(-9) {
            "6"
        } else if chord.contains(10) || chord.contains(11) ||
                    chord.contains(-10) || chord.contains(-11) {
            "7"
        } else {
            ""
        }
    }
    
    public func updateChordLabel() {
        if !turnedOnPitches.isEmpty {
            
            let chordRoot: Int = self.upwardPitchDirection ? self.turnedOnPitches.sorted(by: <).first! : self.turnedOnPitches.sorted(by: <).last!
            let chord = integerNotes()
            
            let majorMinor: String = if (chord.contains(4) && chord.contains(7)) ||
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
            DispatchQueue.main.async {
                // TODO: figure out 6th and 7th chords
                // self.chordLabel = "\(chordRoot) \(majorMinor) \(self.extraInterval(chord: chord))"
                self.chordLabel = "\(chordRoot) \(majorMinor) \(self.extraInterval(chord: chord))"
            }
        } else {
            DispatchQueue.main.async {
                self.chordLabel = ""
            }
        }
            
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
            let rootToTonicDistance = self.upwardPitchDirection ? (turnedOnNotes.first!  - self.tonicNote) : (self.tonicNote - turnedOnNotes.last!)
            
            print("rootToTonicDistance", rootToTonicDistance)
            
            scaleDegree = if (rootToTonicDistance == 0) {
                "\(prefix)1\(caret)"
            } else {
                switch mod(rootToTonicDistance, 12) {
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

    
    private func mod(_ a: Int, _ n: Int) -> Int {
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
