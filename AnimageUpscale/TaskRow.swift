import SwiftUI

struct TaskRow: View {
    let task = ImageDemo
    
    private var background: Color {
        Color(nsColor: .windowBackgroundColor)
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(task.fileName)
                        .font(.system(size: 12, design: .monospaced))
                        .lineLimit(1)
                        .truncationMode(.middle)
                    Spacer()
                    Text(task.url)
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundColor(.secondary)
                }
                HStack {
                    statusIndicator
                    Text("\(task.originalSize.width)×\(task.originalSize.height) → \(task.originalSize.width * task.upscaleLevel)×\(task.originalSize.height * task.upscaleLevel)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding(8)
        .background(background)
        .cornerRadius(4)
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

#Preview {
    TaskRow()
}
