import SwiftUI

struct UserInterface: View {
    @ObservedObject var QueueStore: QueueControl
    @State private var selectedTaskIDs: Set<UUID> = []
    
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    QueueListView(QueueStore, selectedTaskIDs: $selectedTaskIDs)
                        .frame(width: geometry.size.width * 0.7)
                    
                    TaskDetailView(selectedTaskIDs: selectedTaskIDs, QueueStore: QueueStore)
                        .frame(width: geometry.size.width * 0.3)
                }
            }
            HStack {
                Button(action: {
                    
                }, label: {
                    Image(systemName: "ellipsis.circle")
                })
                Spacer()
                Button(action: {
                    
                }, label: {
                    Image(systemName: "apple.terminal")
                })
            }
            .padding(6)
        }
        .frame(minWidth: 1000, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: {
                    removeSelectedTasks()
                }, label: {
                    Image(systemName: "minus")
                })
                .disabled(selectedTaskIDs.isEmpty || QueueStore.Status == .running)
                Button(action: {
                    openFilePicker()
                }, label: {
                    Image(systemName: "plus")
                })
                Button(action: {
                    
                }, label: {
                    Image(systemName: "play.fill")
                })
                .disabled(QueueStore.Queue.isEmpty)
            }
        }
    }
    
    func removeSelectedTasks() {
        QueueStore.removeTasks(withIDs: selectedTaskIDs)
        selectedTaskIDs.removeAll()
    }
    
    func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.image]
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false
        
        if panel.runModal() == .OK {
            let selectedFiles = panel.urls.map { $0.path }
            
            let existingFilePaths = Set(QueueStore.Queue.map { $0.url })
            let newFiles = selectedFiles.filter { !existingFilePaths.contains($0) }
            
            let newTasks = newFiles.map { path in
                Task(url: path, fileName: (path as NSString).lastPathComponent, outputDirectory: DefaultSettings.outputDirectory)
            }
            
            QueueStore.Queue.append(contentsOf: newTasks)
        }
    }
}

struct QueueListView: View {
    @ObservedObject var QueueStore: QueueControl
    @Binding var selectedTaskIDs: Set<UUID>
    
    init(_ QueueStore: QueueControl, selectedTaskIDs: Binding<Set<UUID>>) {
        self.QueueStore = QueueStore
        self._selectedTaskIDs = selectedTaskIDs
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 5) {
                ForEach(QueueStore.Queue) { item in
                    TaskRow(item, isSelected: selectedTaskIDs.contains(item.id))
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            let isCommandPressed = NSEvent.modifierFlags.contains(.command)
                            
                            if isCommandPressed {
                                if selectedTaskIDs.contains(item.id) {
                                    selectedTaskIDs.remove(item.id)
                                } else {
                                    selectedTaskIDs.insert(item.id)
                                }
                            } else {
                                selectedTaskIDs = [item.id]
                            }
                        }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 10)
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedTaskIDs.removeAll()
        }
    }
}

struct TaskDetailView: View {
    var selectedTaskIDs: Set<UUID>
    var QueueStore: QueueControl
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .padding(10)
                .opacity(0.03)
            Group {
                if selectedTaskIDs.isEmpty {
                    Text("Select a item to edit")
                        .foregroundColor(.secondary)
                        .italic()
                } else if selectedTaskIDs.count == 1, let selectedTask = QueueStore.Queue.first(where: { selectedTaskIDs.contains($0.id) }) {
                    ImagePreviewView(imagePath: selectedTask.url)
                } else {
                    Text(" \(selectedTaskIDs.count) items selected")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.secondary)
                }
            }
        }
        
    }
}


struct ImagePreviewView: View {
    let imagePath: String
    
    init(imagePath: String) {
        self.imagePath = imagePath
    }
    
    var body: some View {
        if let image = NSImage(contentsOfFile: imagePath) {
            GeometryReader { geometry in
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(15)
                    .shadow(radius: 5)
            }
        } else {
            VStack {
                Image(systemName: "exclamationmark.circle")
                    .foregroundStyle(.red)
                Text("Failed to load image")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}


#Preview {
    UserInterface(QueueStore: QueueControl())
}
