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

            // Tab content
            Group {
                switch selectedTab {
                case .arrange:
                    arrangeView
                case .style:
                    Text("Style options coming soon…")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .text:
                    Text("Text options coming soon…")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding([.horizontal, .bottom])

            Spacer()
        }
        .padding()
    }

    /// The Arrange tab: z-order controls + position & size fields
    private var arrangeView: some View {
        Form {
            Section {
                HStack {
                    Button(action: sendToBack) {
                        Image(systemName: "square.3.layers.3d.bottom.filled")
                    }
                    .buttonStyle(.bordered)
                    .disabled(widget.z == minZ)

                    Button(action: bringToFront) {
                        Image(systemName: "square.3.layers.3d.top.filled")
                    }
                    .buttonStyle(.bordered)
                    .disabled(widget.z == maxZ)

                    Spacer()

                    Button(action: sendBackward) {
                        Image(systemName: "square.2.layers.3d.bottom.filled")
                    }
                    .buttonStyle(.bordered)
                    .disabled(widget.z == minZ)

                    Button(action: bringForward) {
                        Image(systemName: "square.2.layers.3d.top.filled")
                    }
                    .buttonStyle(.bordered)
                    .disabled(widget.z == maxZ)
                }
            }

            Section("Position & Size") {
                FieldControl(
                    label: "X",
                    value: $widget.x.asDouble(),
                    range: 0...Double(slideSize.width),
                    step: 1
                )
                FieldControl(
                    label: "Y",
                    value: $widget.y.asDouble(),
                    range: 0...Double(slideSize.height),
                    step: 1
                )
                FieldControl(
                    label: "Width",
                    value: $widget.width.asDouble(),
                    range: 0...Double(slideSize.width),
                    step: 1
                )
            }
        }
    }

    // MARK: — Z-order actions (operate on sortedWidgets)
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

    // MARK: — Reusable FieldControl
    struct FieldControl: View {
        let label: String
        @Binding var value: Double
        var range: ClosedRange<Double> = 0...1
        var step: Double = 0.01

        var body: some View {
            HStack {
                Text(label)
                TextField("", value: $value, format: .number)
                    .frame(width: 60)
                    .textFieldStyle(.roundedBorder)
                Stepper("", value: $value, in: range, step: step)
                    .labelsHidden()
                    .controlSize(.small)
            }
        }
    }
}
