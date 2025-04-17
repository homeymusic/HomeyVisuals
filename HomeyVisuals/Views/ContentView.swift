//  ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var presentations: [Presentation]
    
    var body: some View {
        let presentation = thePresentation()
        
        NavigationSplitView {
            List {
                ForEach(presentation.slides) { slide in
                    NavigationLink {
                        Text("Slide: \(slide.title)")
                    } label: {
                        Text("Slide Label: \(slide.createdAt)")
                    }
                }                
                .onMove { from, to in
                    presentation.slides.move(fromOffsets: from, toOffset: to)
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar {
                ToolbarItem {
                    Button(action: { addSlide(to: presentation) }) {
                        Label("New Slide", systemImage: "plus")
                    }
                    .keyboardShortcut("n", modifiers: .command)
                }
            }
        } detail: {
            Text("Select an item")
        }
    }
    
    // MARK: - Helpers
    private func thePresentation() -> Presentation {
        if let existing = presentations.first {
            return existing
        } else {
            let fresh = Presentation()
            modelContext.insert(fresh)
            return fresh
        }
    }
    
    private func addSlide(to presentation: Presentation) {
        withAnimation {
            let slide = Slide()
            presentation.slides.append(slide)
        }
    }
    
}
