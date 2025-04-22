import SwiftUI

struct WidgetInspect: View {
  @Bindable var widget: TextWidget

  var body: some View {
    Form {
      Section("Position & Size") {
        FieldControl(label: "X",     value: $widget.x)
        FieldControl(label: "Y",     value: $widget.y)
        FieldControl(label: "Width", value: $widget.width)
      }
      Section("Text") {
        TextField("Content", text: $widget.text)
      }
    }
    .navigationTitle("Inspect Text‑Box")
    .padding()
  }
}

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
