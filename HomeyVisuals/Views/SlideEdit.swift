import SwiftUI
import SwiftData

struct SlideEdit: View {
    @Bindable var slide: Slide                      // two‑way binding
    
    var body: some View {
        Form {
            TextField("Title", text: $slide.title)
            DatePicker("Created", selection: $slide.createdAt, displayedComponents: .date)
            TextEditor(text: $slide.body)
                .frame(minHeight: 200)
        }
        .padding()
        .navigationTitle(slide.title)
    }
}
