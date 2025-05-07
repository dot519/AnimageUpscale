import SwiftUI

struct PopoverSettingsView: View {
    @ObservedObject var settingsViewModel: SettingsViewModel
    @Binding var showPopover: Bool
    @State private var isDirectoryPickerOpen = false

    var body: some View {
        VStack(spacing: 20) {
            Text("Default Settings")
                .font(.headline)
            
            VStack(alignment: .leading) {
                Picker("Upscale Model", selection: $settingsViewModel.upscaleModel) {
                    Text("models-se").tag("models-se")
                    Text("models-pro").tag("models-pro")
                    Text("models-nose").tag("models-nose")
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: settingsViewModel.upscaleModel) { oldValue, newValue in
                    settingsViewModel.updateAvailableLevels(for: newValue)
                }
                
                Picker("Upscale Level", selection: $settingsViewModel.upscaleLevel) {
                    ForEach(settingsViewModel.availableUpscaleLevels, id: \.self) { level in
                        Text("\(level)x").tag(level)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Picker("Denoise Level", selection: $settingsViewModel.denoiseLevel) {
                    ForEach(settingsViewModel.availableDenoiseLevels, id: \.self) { level in
                        Text("\(level)").tag(level)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                Toggle("Enable TTX", isOn: $settingsViewModel.TTX)
                HStack {
                    Text("Suffix")
                    TextField("Suffix", text: $settingsViewModel.suffix)
                }
                
                HStack {
                    Text("Output Directory")
                    Button(action: {
                        openDirectoryPicker()
                    }) {
                        Text(settingsViewModel.outputDirectory.isEmpty ? "Select Directory" : settingsViewModel.outputDirectory)
                            .foregroundColor(settingsViewModel.outputDirectory.isEmpty ? .blue : .black)
                    }
                    .padding(.leading, 10)
                }
            }
            .padding()
        }
        .padding(.top)
        .background(GeometryReader { geometry in
            Color.clear
                .onTapGesture {
                    if !geometry.frame(in: .global).contains(NSPoint(x: NSEvent.mouseLocation.x, y: NSEvent.mouseLocation.y)) {
                        showPopover = false
                    }
                }
        })
        .onChange(of: isDirectoryPickerOpen) { isdirectoryPickerOpen, _ in
            if !isDirectoryPickerOpen {
                showPopover = true
            }
        }
    }
    
    private func openDirectoryPicker() {
        isDirectoryPickerOpen = true
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.canChooseFiles = false
        panel.allowsMultipleSelection = false
        panel.message = "Please select an output directory."
        
        if panel.runModal() == .OK, let directoryURL = panel.urls.first {
            settingsViewModel.outputDirectory = directoryURL.absoluteString
            let prefixRange = settingsViewModel.outputDirectory.startIndex..<settingsViewModel.outputDirectory.index(settingsViewModel.outputDirectory.startIndex, offsetBy: 7)
            settingsViewModel.outputDirectory.removeSubrange(prefixRange)
        }
        
        isDirectoryPickerOpen = false
    }
}

#Preview {
    PopoverSettingsView(settingsViewModel: SettingsViewModel(), showPopover: .constant(true))
}
