import SwiftUI

struct KeyEventHandlingView: NSViewRepresentable {
    var onDelete: () -> Void

    class Coordinator: NSObject {
        var onDelete: () -> Void

        init(onDelete: @escaping () -> Void) {
            self.onDelete = onDelete
        }

        @objc func keyDown(with event: NSEvent) {
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
        let eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            context.coordinator.keyDown(with: event)
            return event
        }
        context.coordinator.onDelete = onDelete
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {}
}
