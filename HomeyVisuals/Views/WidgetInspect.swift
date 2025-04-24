import SwiftUI
import CoreGraphics

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

// MARK: — Inspection View

struct WidgetInspect: View {
    @Bindable var widget: TextWidget

    /// Slide’s absolute size in points
    private var slideSize: CGSize {
        widget.slide?.size ?? .zero
    }

    var body: some View {
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
            Section("Text") {
                TextField("Content", text: $widget.text)
            }
        }
        .navigationTitle("Inspect Text-Box")
        .padding()
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
