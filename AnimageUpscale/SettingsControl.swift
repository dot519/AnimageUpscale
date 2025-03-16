import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var upscaleLevel: Int
    @Published var denoiseLevel: Int
    @Published var upscaleModel: String
    @Published var TTX: Bool
    @Published var suffix: String
    @Published var outputDirectory: String
    @Published var availableUpscaleLevels: [Int] = []
    @Published var availableDenoiseLevels: [Int] = []
    
    private var modelToUpscaleLevels: [String: [Int]] = [
        "models-se": [4, 3, 2],
        "models-pro": [3, 2],
        "models-nose": [2]
    ]
    
    private var modelToDenoiseLevels: [String: [Int]] = [
        "models-se": [-1, 0, 3],
        "models-pro": [-1, 0, 3],
        "models-nose": [-1]
    ]
    
    init() {
        self.upscaleLevel = DefaultSettings.upscaleLevel
        self.denoiseLevel = DefaultSettings.denoiseLevel
        self.upscaleModel = DefaultSettings.upscaleModel
        self.TTX = DefaultSettings.TTX
        self.suffix = DefaultSettings.suffix
        self.outputDirectory = DefaultSettings.outputDirectory
        
        updateAvailableLevels(for: self.upscaleModel)
    }
    
    func saveSettings() {
        DefaultSettings.upscaleLevel = upscaleLevel
        DefaultSettings.denoiseLevel = denoiseLevel
        DefaultSettings.upscaleModel = upscaleModel
        DefaultSettings.TTX = TTX
        DefaultSettings.suffix = suffix
        DefaultSettings.outputDirectory = outputDirectory
    }
    
    public func updateAvailableLevels(for model: String) {
            self.availableUpscaleLevels = self.modelToUpscaleLevels[model] ?? []
            self.availableDenoiseLevels = self.modelToDenoiseLevels[model] ?? []

            if !self.availableUpscaleLevels.contains(self.upscaleLevel) {
                self.upscaleLevel = self.availableUpscaleLevels.first ?? 2
            }
            if !self.availableDenoiseLevels.contains(self.denoiseLevel) {
                self.denoiseLevel = self.availableDenoiseLevels.first ?? -1
            }
            self.objectWillChange.send()
            
    }
}
