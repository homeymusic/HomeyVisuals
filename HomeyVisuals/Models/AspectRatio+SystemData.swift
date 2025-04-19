import Foundation
import SwiftData

extension AspectRatio {
    private static let wideID     = "AspectRatio‑Wide‑0001"
    private static let standardID = "AspectRatio‑Standard‑0002"

    static func fetchDescriptor(systemID: String) -> FetchDescriptor<AspectRatio> {
        let predicate: Predicate<AspectRatio> = #Predicate { $0.systemIdentifier == systemID }
        return FetchDescriptor(predicate: predicate)
    }

    static func fetchDescriptor(id: UUID) -> FetchDescriptor<AspectRatio> {
        let predicate: Predicate<AspectRatio> = #Predicate { $0.id == id }
        return FetchDescriptor(predicate: predicate)
    }

    @MainActor
    public static func seedSystemAspectRatios(in context: ModelContext) {
        let definitions = [
            (id: wideID,     name: "Wide",     w: 16, h: 9, pos: 1),
            (id: standardID, name: "Standard", w: 4,  h: 3, pos: 2),
        ]

        for def in definitions {
            let fetch = fetchDescriptor(systemID: def.id)
            if (try? context.fetch(fetch).first) != nil { continue }
            let ratio = AspectRatio(
                systemIdentifier: def.id,
                name:             def.name,
                width:            def.w,
                height:           def.h,
                position:         def.pos
            )
            context.insert(ratio)
        }
    }

    @MainActor
    public static func wide(in context: ModelContext) -> AspectRatio {
        let fetch = fetchDescriptor(systemID: wideID)
        return (try! context.fetch(fetch).first)!
    }
}
