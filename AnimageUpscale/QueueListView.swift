import SwiftUI

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
