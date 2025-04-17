import SwiftUI
import SwiftData
import UniformTypeIdentifiers

@main
struct HomeyVisualsApp: App {
    var body: some Scene {
        DocumentGroup(
            editing: .visuals,
            migrationPlan: HomeyVisualsMigrationPlan.self
        ) {
            ContentView()
        }
    }
}

struct HomeyVisualsMigrationPlan: SchemaMigrationPlan {
    static var schemas: [VersionedSchema.Type] = [
        HomeyVisualsVersionedSchema.self,
    ]

    static var stages: [MigrationStage] = [
        // Stages of migration between VersionedSchema, if required.
    ]
}

struct HomeyVisualsVersionedSchema: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] = [
        Item.self,
    ]
}
