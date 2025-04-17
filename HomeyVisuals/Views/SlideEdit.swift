import SwiftUI
import SwiftData

struct SlideEdit: View {
    @Bindable var slide: Slide

    var body: some View {
        Form {
            TextField("Title", text: $slide.title)
                .frame(maxWidth: .infinity, alignment: .leading)

            DatePicker("Created",
                       selection: $slide.createdAt,
                       displayedComponents: .date)

            TextEditor(text: $slide.body)
                .textEditorStyle(.plain)
                .frame(minHeight: 200)
        }
        .padding()
        .navigationTitle(slide.title)
        .navigationSubtitle(Text(slide.createdAt, format: .dateTime.year().month().day()))
    }
}
