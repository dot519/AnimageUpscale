import SwiftUI

struct TaskRow: View {
    var task: Task
    let isSelected: Bool
    @State private var refreshTrigger = UUID()
    init(_ task: Task, isSelected: Bool = false) {
        self.task = task
        self.isSelected = isSelected
    }
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack {
            statusSignaller
                .onChange(of: task.status) {
                    refreshTrigger = UUID()
                }
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
                    Text("\(task.originalSize.width)×\(task.originalSize.height) → \(task.originalSize.width * task.parameterControl.upscaleLevel)×\(task.originalSize.height * task.parameterControl.upscaleLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(10)
        }
        .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color(.windowBackgroundColor))
                    .shadow(color: colorScheme == .dark ? Color.white.opacity(0.02) : Color.black.opacity(0.1), radius: isSelected ? 4 : (colorScheme == .dark ? 8 : 2), x: 2, y: 6)
        )
        .scaleEffect(isSelected ? 0.98 : 1.0) // 轻微缩小的按下效果
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var statusSignaller: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(colorForStatus(task.status))
            .opacity(opacityForStatus(task.status))
            .animation(animationForStatus(task.status), value: task.status)
    }
    
    private func colorForStatus(_ status: TaskStatus) -> Color {
        switch status {
        case .ready: return .clear
        case .running: return .blue
        case .completed: return .green.opacity(0.6)
        case .failed: return .red
        }
    }
    
    private func opacityForStatus(_ status: TaskStatus) -> Double {
        switch status {
        case .ready: return 0.0
        case .running, .completed, .failed: return 0.3
        }
    }
    
    private func animationForStatus(_ status: TaskStatus) -> Animation {
        switch status {
        case .running:
            return Animation.easeInOut(duration: 0.5).repeatCount(2, autoreverses: true)
        case .completed, .failed:
            return .easeInOut(duration: 0.3)
        default:
            return .default
        }
    }
}
