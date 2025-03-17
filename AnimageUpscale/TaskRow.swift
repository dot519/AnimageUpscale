import SwiftUI

struct TaskRow: View {
    let task: Task
    let isSelected: Bool
    @State private var refreshTrigger = UUID()
    init(_ task: Task, isSelected: Bool = false) {
        self.task = task
        self.isSelected = isSelected
    }
    
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.fileName)
                        .font(.system(size: 13, design: .default))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Text(task.url)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                HStack {
                    statusIndicator
                        .onChange(of: task.status) {
                            refreshTrigger = UUID()
                        }
                    Text("\(task.originalSize.width)×\(task.originalSize.height) → \(task.originalSize.width * task.parameterControl.upscaleLevel)×\(task.originalSize.height * task.parameterControl.upscaleLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(.windowBackgroundColor))
                .shadow(color: colorScheme == .dark ? Color.white.opacity(0.02) : Color.black.opacity(0.1), radius: isSelected ? 4 : (colorScheme == .dark ? 8 : 2), x: 2, y: 6)
        )
        .scaleEffect(isSelected ? 0.98 : 1.0) // 轻微缩小的按下效果
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var statusIndicator: some View {
        Circle()
            .frame(width: 8, height: 8)
            .foregroundColor({
                switch task.status {
                case .ready: return .gray
                case .running: return .blue
                case .completed: return .green
                case .failed: return .red
                }
            }())
    }
}
