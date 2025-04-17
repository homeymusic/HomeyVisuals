import SwiftUI
import SwiftData
import CoreTransferable

struct SlideList: View {
    @Bindable var presentation: Presentation
    @Binding   var selection: Slide.ID?
    var onAddSlide:   (Slide.ID?) -> Void
    var onDeleteSlide:()         -> Void

    // Build the raw List by itself
    @ViewBuilder
    private var rawList: some View {
        List(selection: $selection) {
            ForEach(Array(presentation.slides.enumerated()), id: \.element.id) { index, slide in
                NavigationLink(value: slide.id) {
                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                        Text("\(index + 1)")
                            .font(.system(.caption2))
                            .foregroundStyle(.secondary)
                        Text("\(slide.id)")
                    }
                }
                .tag(slide.id)
            }
            .onMove { from, to in
                presentation.slides.move(fromOffsets: from, toOffset: to)
            }
        }
    }

    // Which SlideRecord(s) to copy
    private var copyableRecords: [SlideRecord] {
        guard
            let sel   = selection,
            let slide = presentation.slides.first(where: { $0.id == sel })
        else { return [] }
        return [slide.record]
    }

    var body: some View {
        rawList
            // Copy-only for ⌘C
            .copyable(copyableRecords)

            // Cut (⌘X): you must return the items to place on the clipboard,
            // and then perform your delete logic. No parameters allowed.
            .cuttable(for: SlideRecord.self) {
                // 1️⃣ capture what should go on the pasteboard
                let items = copyableRecords
                // 2️⃣ delete the slide
                onDeleteSlide()
                // 3️⃣ return them for the system
                return items
            }

            // Paste (⌘V)
            .pasteDestination(for: SlideRecord.self) { records in
                for rec in records {
                    let newSlide = Slide(record: rec)
                    if
                        let sel = selection,
                        let idx = presentation.slides.firstIndex(where: { $0.id == sel })
                    {
                        presentation.slides.insert(newSlide, at: idx + 1)
                    } else {
                        presentation.slides.append(newSlide)
                    }
                    selection = newSlide.id
                }
            }

            .toolbar {
                ToolbarItem {
                    Button { onAddSlide(selection) } label: {
                        Label("New Slide", systemImage: "plus")
                    }
                    .keyboardShortcut("n")
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
    }
}
