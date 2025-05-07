import Foundation
import Combine

class SettingsViewModel: ObservableObject, Equatable{
    @Published var upscaleLevel: Int {
        didSet { saveSettings() }
    }
    @Published var denoiseLevel: Int {
        didSet { saveSettings() }
    }
    @Published var upscaleModel: String {
        didSet { saveSettings() }
    }
    @Published var TTX: Bool {
        didSet { saveSettings() }
    }
    @Published var suffix: String {
        didSet { saveSettings() }
    }
    @Published var outputDirectory: String {
        didSet { saveSettings() }
    }
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
        print("""
            Current Default Parameters:
                Model: \(DefaultSettings.upscaleModel)
                Upscale rate: \(DefaultSettings.upscaleLevel)
                Deniose level: \(DefaultSettings.denoiseLevel)
                TTX: \(DefaultSettings.TTX)
                Suffix: \(DefaultSettings.suffix)
                Output Directory: \(DefaultSettings.outputDirectory)
            """)
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
        
        print("Current Model: \(self.upscaleModel)\nAvailable Upscale Levels: \(self.availableUpscaleLevels)\nAvailable Denoise Levels: \(self.availableDenoiseLevels)\n")
        self.objectWillChange.send()
        
    }
    
    static func == (lhs: SettingsViewModel, rhs: SettingsViewModel) -> Bool {
        return (lhs.TTX == rhs.TTX) && (lhs.upscaleModel == rhs.upscaleModel) && (lhs.outputDirectory == rhs.outputDirectory) && (lhs.suffix == rhs.suffix)
    }
    
    func showCurrentSettings() {
        print("Current Settings:")
        print("Upscale Model: \(self.upscaleModel)")
        print("Upscale Level: \(self.upscaleLevel)")
        print("Denoise Level: \(self.denoiseLevel)")
        print("TTX: \(self.TTX)")
        print("Output Directory: \(self.outputDirectory)")
    }
}
