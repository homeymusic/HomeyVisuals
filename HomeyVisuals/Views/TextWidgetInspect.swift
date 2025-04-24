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

/// Inspector for a selected TextWidget: shows a segmented picker (Style/Text/Arrange) and defaults to Arrange.
struct TextWidgetInspect: View {
    @Bindable var widget: TextWidget
    @State private var selectedTab: Tab = .arrange

    private var slideSize: CGSize {
        widget.slide?.size ?? .zero
    }

    enum Tab: String, CaseIterable {
        case style   = "Style"
        case text    = "Text"
        case arrange = "Arrange"
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with segmented picker
            Picker("", selection: $selectedTab) {
                ForEach(Tab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.vertical, 8)

            Divider()

            // Content for each tab (Arrange only for now)
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
            .padding()

            Spacer()
        }
        .padding()
    }

    /// The Arrange tab: position & size controls
    private var arrangeView: some View {
        Form {
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
}

// MARK: — Reusable FieldControl

struct FieldControl: View {
    let label: String
    @Binding var value: Double
    var range: ClosedRange<Double> = 0...1
    var step: Double = 0.01
    var disabled: Bool = false

    var body: some View {
        HStack {
            Text(label)
            TextField("", value: $value, format: .number)
                .frame(width: 60)
                .textFieldStyle(.roundedBorder)
                .disabled(disabled)
            Stepper("", value: $value, in: range, step: step)
                .labelsHidden()
                .controlSize(.small)
                .disabled(disabled)
        }
    }
}
