import SwiftUI
import CoreGraphics
import SwiftData
import HomeyMusicKit

// MARK: — Binding adapter for CGFloat ↔︎ Double
private extension Binding where Value == CGFloat {
    /// Expose a CGFloat binding as a Double binding.
    func asDouble() -> Binding<Double> {
        Binding<Double>(
            get: { Double(self.wrappedValue) },
            set: { self.wrappedValue = CGFloat($0) }
        )
    }
}

/// Inspector for a selected TextWidget: tabs for Style/Text/Arrange; "Arrange" default.
struct TextWidgetInspect: View {
    @Bindable var widget: TextWidget
    @State private var selectedTab: Tab = .arrange

    // Compute slide’s absolute size in points
    private var slideSize: CGSize {
        widget.slide?.size ?? .zero
    }

    // Sorted widgets by z-order
    private var sortedWidgets: [TextWidget] {
        widget.slide?.textWidgets.sorted(by: { $0.z < $1.z }) ?? [widget]
    }
    private var minZ: Int { sortedWidgets.first?.z ?? widget.z }
    private var maxZ: Int { sortedWidgets.last?.z ?? widget.z }

    enum Tab: String, CaseIterable {
        case style   = "Style"
        case text    = "Text"
        case arrange = "Arrange"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Tab picker
            Picker("", selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 8)

            Divider()

            // Content
            Group {
                switch selectedTab {
                case .arrange:
                    arrangeView
                case .style:
                    placeholderView("Style options coming soon…")
                case .text:
                    placeholderView("Text options coming soon…")
                }
            }
            .padding()

            Spacer()
        }
        .padding()
    }

    /// The Arrange tab: z-order, size, and position controls
    private var arrangeView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Z-order controls
            HStack {
                Button(action: sendToBack) {
                    Image(systemName: "square.3.layers.3d.bottom.filled")
                }
                .buttonStyle(.bordered)
                .disabled(widget.z == minZ)
                .keyboardShortcut("b", modifiers: [.shift, .command])

                Button(action: bringToFront) {
                    Image(systemName: "square.3.layers.3d.top.filled")
                }
                .buttonStyle(.bordered)
                .disabled(widget.z == maxZ)
                .keyboardShortcut("f", modifiers: [.shift, .command])

                Spacer()

                Button(action: sendBackward) {
                    Image(systemName: "square.2.layers.3d.bottom.filled")
                }
                .buttonStyle(.bordered)
                .disabled(widget.z == minZ)
                .keyboardShortcut("b", modifiers: [.option, .shift, .command])

                Button(action: bringForward) {
                    Image(systemName: "square.2.layers.3d.top.filled")
                }
                .buttonStyle(.bordered)
                .disabled(widget.z == maxZ)
                .keyboardShortcut("f", modifiers: [.option, .shift, .command])
            }

            Divider()
                .frame(maxWidth: .infinity)

            // Size controls
            Text("Size").font(.headline)
            HStack(spacing: 16) {
                LabeledField(
                    label: "Width",
                    value: $widget.width.asDouble(),
                    range: 0...Double(slideSize.width),
                    step: 1
                )
                LabeledField(
                    label: "Height",
                    value: $widget.height.asDouble(),
                    range: 0...Double(slideSize.height),
                    step: 1
                )
            }

            Divider()
                .frame(maxWidth: .infinity)

            // Position controls
            Text("Position").font(.headline)
            HStack(spacing: 16) {
                LabeledField(
                    label: "X",
                    value: $widget.x.asDouble(),
                    range: 0...Double(slideSize.width),
                    step: 1
                )
                LabeledField(
                    label: "Y",
                    value: $widget.y.asDouble(),
                    range: 0...Double(slideSize.height),
                    step: 1
                )
            }
        }
    }

    /// Placeholder for non-Arrange tabs
    private func placeholderView(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: — Z-order actions
    private func sendToBack() {
        let items = sortedWidgets
        guard let idx = items.firstIndex(of: widget) else { return }
        var newOrder = items
        newOrder.remove(at: idx)
        newOrder.insert(widget, at: 0)
        renumber(newOrder)
    }

    private func bringToFront() {
        let items = sortedWidgets
        guard let idx = items.firstIndex(of: widget) else { return }
        var newOrder = items
        newOrder.remove(at: idx)
        newOrder.append(widget)
        renumber(newOrder)
    }

    private func sendBackward() {
        let items = sortedWidgets
        guard let idx = items.firstIndex(of: widget), idx > 0 else { return }
        var newOrder = items
        newOrder.swapAt(idx, idx - 1)
        renumber(newOrder)
    }

    private func bringForward() {
        let items = sortedWidgets
        guard let idx = items.firstIndex(of: widget), idx < items.count - 1 else { return }
        var newOrder = items
        newOrder.swapAt(idx, idx + 1)
        renumber(newOrder)
    }

    /// Helper to assign z-values sequentially
    private func renumber(_ ordered: [TextWidget]) {
        for (newZ, w) in ordered.enumerated() {
            w.z = newZ
        }
    }

    // MARK: — LabeledField for numeric inputs
        // MARK: — LabeledField for numeric inputs
    struct LabeledField: View {
        let label: String
        @Binding var value: Double
        var range: ClosedRange<Double>
        var step: Double

        var body: some View {
            HStack(spacing: 16) {
                // TextField with overlayed label that doesn't affect layout
                TextField("", value: $value, format: .number)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                    .overlay(
                        Text(label)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .offset(y: 16), // adjust as needed for spacing
                        alignment: .bottom
                    )
                // Stepper stays centered vertically
                Stepper("", value: $value, in: range, step: step)
                    .labelsHidden()
                    .controlSize(.small)
            }
        }
    }
}
