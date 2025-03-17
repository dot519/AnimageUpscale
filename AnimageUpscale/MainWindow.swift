import SwiftUI

struct MainWindow: View {
    @ObservedObject var QueueStore: QueueControl
    @State private var selectedTaskIDs: Set<UUID> = []
    @State private var showPopover = false
    @StateObject var settingsViewModel = SettingsViewModel()
    @State private var showAlert = false
    @State private var showDeleteConfirmation = false
    @State private var refreshTrigger = UUID()
    
    // 添加用于检测键盘事件的变量
    @State private var commandKeyDown = false
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    if QueueStore.Queue.isEmpty {
                        VStack {
                            Text("Click add or drop a image here")
                                .font(.title)
                                .padding()
                                .opacity(0.3)
                        }
                        .frame(width: geometry.size.width * 0.7, height: geometry.size.height)
                    } else {
                        QueueListView(QueueStore, selectedTaskIDs: $selectedTaskIDs)
                            .frame(width: geometry.size.width * 0.7)
                    }
                    TaskDetailView(selectedTaskIDs: selectedTaskIDs, QueueStore: QueueStore)
                        .frame(width: geometry.size.width * 0.3)
                }
                .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                    var urls: [URL] = []
                    let group = DispatchGroup()
                    for item in providers {
                        group.enter()
                        _ = item.loadObject(ofClass: URL.self) { (url, error) in
                            if let url = url {
                                let fileExtension = url.pathExtension.lowercased()
                                if ["png", "jpg", "jpeg", "webp"].contains(fileExtension) {
                                    urls.append(url)
                                } else {
                                    DispatchQueue.main.async {
                                        QueueStore.unsupportedFileTypes.append(url.lastPathComponent)
                                    }
                                }
                            } else if let error = error {
                                print("Failed to load file: \(error.localizedDescription)")
                            }
                            group.leave()
                        }
                    }
                    
                    group.notify(queue: .main) {
                        if !urls.isEmpty {
                            QueueStore.initializeAndAddTasks(from: urls)
                        }
                    }
                    return true
                }
            }
        }
        .alert("Import Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) {
                QueueStore.failedFiles.removeAll()
                QueueStore.unsupportedFileTypes.removeAll()
                showAlert = false
            }
        } message: {
            let allFailedFiles = QueueStore.failedFiles + QueueStore.unsupportedFileTypes
            Text(allFailedFiles.joined(separator: "\n"))
        }
        .onReceive(QueueStore.objectWillChange) {
            if !showAlert && (!QueueStore.failedFiles.isEmpty || !QueueStore.unsupportedFileTypes.isEmpty) {
                showAlert = true
            }
        }
        .frame(minWidth: 1000, maxWidth: .infinity, minHeight: 600, maxHeight: .infinity)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                
                // Debug Button: Demo parameters of all tasks
                Button(action: {
                    QueueStore.printParametersOfAllTasks()
                }, label: {
                    Image(systemName: "memorychip.fill")
                })
                //
                
                Button(action: {
                    showPopover.toggle()
                }, label: {
                    Image(systemName: "ellipsis.circle")
                })
                .popover(isPresented: $showPopover) {
                    PopoverSettingsView(settingsViewModel: settingsViewModel, showPopover: $showPopover)
                }
                
                Spacer()
                
                Button(action: {
                    deleteSelectedTasks()
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
                    if QueueStore.Status == .idle {
                        print("Queue started\n")
                        QueueStore.runQueue()
                    } else {
                        QueueStore.stopQueue()
                        print("Queue ended\n")
                    }
                }, label: {
                    Image(systemName: QueueStore.Status == .idle ? "play.fill" : "stop.fill")
                })
                .disabled(QueueStore.Queue.isEmpty)
                .onChange(of: QueueStore.Status) {
                    refreshTrigger = UUID()
                }
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Confirm Deletion"),
                message: Text("Are you sure you want to delete the selected tasks?"),
                primaryButton: .destructive(Text("Delete")) {
                    removeSelectedTasks()
                },
                secondaryButton: .cancel()
            )
        }
        .background(KeyEventHandlingView(onDelete: deleteSelectedTasks))
        .onAppear {
            NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                if event.modifierFlags.contains(.command) && event.characters == "a" {
                    selectAllTasks()
                    return nil
                }
                return event
            }
        }
    }
    
    func selectAllTasks() {
        // 全选所有任务
        selectedTaskIDs = Set(QueueStore.Queue.map { $0.id })
    }
    
    func deleteSelectedTasks() {
        if !selectedTaskIDs.isEmpty {
            showDeleteConfirmation = true
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
            let selectedFiles = panel.urls
            QueueStore.initializeAndAddTasks(from: selectedFiles)
        }
    }
}

#Preview {
    MainWindow(QueueStore: QueueControl())
}
