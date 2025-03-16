import SwiftUI

struct TaskDetailView: View {
    var selectedTaskIDs: Set<UUID>
    @State private var refreshTrigger = UUID()
    @ObservedObject var QueueStore: QueueControl
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .padding(10)
                .opacity(0.06)
                .shadow(radius: 10)
            
                if selectedTaskIDs.isEmpty {
                    Text("Select an item to edit")
                        .foregroundColor(.secondary)
                        .italic()
                } else if selectedTaskIDs.count == 1, let selectedTaskIndex = QueueStore.Queue.firstIndex(where: { selectedTaskIDs.contains($0.id) }) {
                    
                    let selectedTaskBinding = $QueueStore.Queue[selectedTaskIndex]
                    
                    VStack {
                        ImagePreviewView(imagePath: selectedTaskBinding.wrappedValue.url)
                        Spacer()
                        Group {
                            Picker("Upscale Model", selection: selectedTaskBinding.parameterControl.upscaleModel) {
                                Text("models-se").tag("models-se")
                                Text("models-pro").tag("models-pro")
                                Text("models-nose").tag("models-nose")
                            }
                            .pickerStyle(MenuPickerStyle())
                            .id(refreshTrigger)
                            .onChange(of: selectedTaskBinding.wrappedValue.parameterControl.upscaleModel) {
                                selectedTaskBinding.wrappedValue.updateAvaliableParameters()
                                
                                if !selectedTaskBinding.wrappedValue.parameterControl.availableUpscaleLevels.contains(selectedTaskBinding.wrappedValue.parameterControl.upscaleLevel) {
                                    selectedTaskBinding.wrappedValue.parameterControl.upscaleLevel = selectedTaskBinding.wrappedValue.parameterControl.availableUpscaleLevels.first ?? 2
                                }
                                
                                if !selectedTaskBinding.wrappedValue.parameterControl.availableDenoiseLevels.contains(selectedTaskBinding.wrappedValue.parameterControl.denoiseLevel) {
                                    selectedTaskBinding.wrappedValue.parameterControl.denoiseLevel = selectedTaskBinding.wrappedValue.parameterControl.availableDenoiseLevels.first ?? -1
                                }
                                refreshTrigger = UUID()
                            }
                            
                            Picker("Upscale Rate", selection: selectedTaskBinding.parameterControl.upscaleLevel) {
                                ForEach(selectedTaskBinding.wrappedValue.parameterControl.availableUpscaleLevels, id: \.self) { level in
                                    Text("\(level)x").tag(level)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: selectedTaskBinding.wrappedValue.parameterControl.availableUpscaleLevels) {
                                selectedTaskBinding.wrappedValue.updateAvaliableParameters()
                            }
                            
                            Picker("Denoise Level", selection: selectedTaskBinding.parameterControl.denoiseLevel) {
                                ForEach(selectedTaskBinding.wrappedValue.parameterControl.availableDenoiseLevels, id: \.self) { level in
                                    Text("\(level)").tag(level)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .onChange(of: selectedTaskBinding.wrappedValue.parameterControl.availableDenoiseLevels) {
                                selectedTaskBinding.wrappedValue.updateAvaliableParameters()
                            }
                            HStack{
                                Toggle("Enable TTX", isOn: selectedTaskBinding.parameterControl.TTX)
                                Spacer()
                            }
                            HStack {
                                Text("Suffix")
                                TextField("Suffix", text: selectedTaskBinding.parameterControl.suffix)
                            }
                        }
                        .padding()
                    }
                    .padding()
                } else {
                    Text("\(selectedTaskIDs.count) items selected")
                        .font(.headline)
                        .padding()
                        .foregroundColor(.secondary)
                }
            }
    }
}
