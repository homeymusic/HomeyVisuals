//  ContentView.swift
import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var presentations: [Presentation]
    @State private var selection: Slide.ID?
    
    var body: some View {
        let presentation = presentations.first ?? createPresentation()
        
        NavigationSplitView {
            SlideList(
                presentation: presentation,
                selection: $selection
            )
        } detail: {
            if let slide = selectedSlide(in: presentation) {
                SlideEdit(slide: slide)
            } else {
                ContentUnavailableView(
                    "Select a slide",
                    systemImage: "rectangle.on.rectangle.slash"
                )
            }
        }
    }
    
    private func createPresentation() -> Presentation {
        let fresh = Presentation()
        modelContext.insert(fresh)
        return fresh
    }
    
    private func selectedSlide(in pres: Presentation) -> Slide? {
        guard let id = selection else { return nil }
        return pres.slides.first(where: { $0.id == id })
    }
    
}
