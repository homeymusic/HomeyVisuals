// SlideList.swift

import SwiftUI
import SwiftData
import CoreTransferable

struct SlideList: View {
    @Bindable var presentation: Presentation
    @Binding   var selection: Slide.ID?
    var onAddSlide: (Slide.ID?) -> Void

    // 1) Build the raw list by itself
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

    // 2) Compute which SlideRecord(s) should be copied
    private var copyableRecords: [SlideRecord] {
        guard
            let sel = selection,
            let slide = presentation.slides.first(where: { $0.id == sel })
        else {
            return []
        }
        return [slide.record]
    }

    var body: some View {
        rawList
            // Enable ⌘C for the selected slide
            .copyable(copyableRecords)
            // Handle ⌘V or drag‑drop of SlideRecord
            .pasteDestination(for: SlideRecord.self) { records in
                for rec in records {
                    presentation.slides.append(Slide(record: rec))
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
