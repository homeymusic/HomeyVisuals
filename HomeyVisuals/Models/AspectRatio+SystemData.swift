import Foundation
import SwiftData

@MainActor
extension AspectRatio {
    private static let wideSystemID      = "AspectRatio-Wide-0001"
    private static let standardSystemID  = "AspectRatio-Standard-0002"

    /// The two built‑in aspect ratios
    public static var wide = AspectRatio(
        systemIdentifier: wideSystemID,
        name: "Wide",
        width: 16, height: 9,
        position: 1
    )

    public static var standard = AspectRatio(
        systemIdentifier: standardSystemID,
        name: "Standard",
        width: 4,  height: 3,
        position: 2
    )

    /// Inserts or updates the two system ratios in your store
    public static func seedSystemAspectRatios(modelContext: ModelContext) {
        let allSystem = [wide, standard]

        for candidate in allSystem {
            guard let sysID = candidate.systemIdentifier else { continue }
            let fetch = FetchDescriptor<AspectRatio>(
                predicate: #Predicate { $0.systemIdentifier == sysID }
            )
            // fetch existing
            if let existing = (try? modelContext.fetch(fetch))?.first {
                // unify the static var to point at the existing object
                switch sysID {
                case wideSystemID:      wide     = existing
                case standardSystemID:  standard = existing
                default: break
                }
            } else {
                // insert fresh
                modelContext.insert(candidate)
            }
        }
    }
}
