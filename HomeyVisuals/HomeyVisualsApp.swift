//
//  HomeyVisualsApp.swift
//  HomeyVisuals
//
//  Created by Brian McAuliff Mulloy on 3/26/25.
//

import SwiftUI

@main
struct HomeyVisualsApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: HomeyVisualsDocument()) { file in
            ContentView(document: file.$document)
        }
    }
}
