//
//  ContentView.swift
//  HomeyVisuals
//
//  Created by Brian McAuliff Mulloy on 3/26/25.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: HomeyVisualsDocument

    var body: some View {
        TextEditor(text: $document.text)
    }
}

#Preview {
    ContentView(document: .constant(HomeyVisualsDocument()))
}
