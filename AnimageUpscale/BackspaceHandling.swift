import SwiftUI

struct KeyEventHandlingView: NSViewRepresentable {
    var onDelete: () -> Void

    class Coordinator: NSObject {
        var onDelete: () -> Void

        init(onDelete: @escaping () -> Void) {
            self.onDelete = onDelete
        }

        @objc func keyDown(with event: NSEvent) {
            if let firstResponder = NSApp.keyWindow?.firstResponder,
               firstResponder.isKind(of: NSText.classForCoder()) {
                return
            }

            if event.keyCode == 51 { // 51 = Delete (Backspace)
                onDelete()
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(onDelete: onDelete)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        _ = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            context.coordinator.keyDown(with: event)
            return event
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
