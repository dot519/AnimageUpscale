import Foundation

struct DefaultSettings {
    public static var upscaleLevel: Int = 4 {
        didSet {
            UserDefaults.standard.set(upscaleLevel, forKey: "upscaleLevel")
        }
    }
    
    public static var denoiseLevel: Int = -1 {
        didSet {
            UserDefaults.standard.set(denoiseLevel, forKey: "denoiseLevel")
        }
    }
    
    public static var upscaleModel: String = "models-se" {
        didSet {
            UserDefaults.standard.set(upscaleModel, forKey: "upscaleModel")
        }
    }
    
    public static var TTX: Bool = true {
        didSet {
            UserDefaults.standard.set(TTX, forKey: "TTX")
        }
    }
    
    public static var suffix: String = "-2" {
        didSet {
            UserDefaults.standard.set(suffix, forKey: "suffix")
        }
    }
    
    public static var outputDirectory: String = "\(FileManager.default.homeDirectoryForCurrentUser.path)/Downloads" {
        didSet {
            UserDefaults.standard.set(outputDirectory, forKey: "outputDirectory")
        }
    }
    
    static func loadSettings() {
        if let savedUpscaleLevel = UserDefaults.standard.value(forKey: "upscaleLevel") as? Int {
            upscaleLevel = savedUpscaleLevel
        }
        if let savedDenoiseLevel = UserDefaults.standard.value(forKey: "denoiseLevel") as? Int {
            denoiseLevel = savedDenoiseLevel
        }
        if let savedUpscaleModel = UserDefaults.standard.value(forKey: "upscaleModel") as? String {
            upscaleModel = savedUpscaleModel
        }
        if let savedTTX = UserDefaults.standard.value(forKey: "TTX") as? Bool {
            TTX = savedTTX
        }
        if let savedSuffix = UserDefaults.standard.value(forKey: "suffix") as? String {
            suffix = savedSuffix
        }
        if let savedOutputDirectory = UserDefaults.standard.value(forKey: "outputDirectory") as? String {
            outputDirectory = savedOutputDirectory
        }
    }
}

enum TaskStatus {
    case ready
    case running
    case completed
    case failed
}

struct Resolution {
    var width: Int
    var height: Int
    
    init (width: Int, height: Int) {
        self.height = height
        self.width = width
    }
}

class Task: Identifiable, ObservableObject {
    var id = UUID()
    
    @Published var url: String
    @Published var fileName: String
    @Published var originalSize: Resolution
    @Published var status: TaskStatus
    @Published var parameterControl: SettingsViewModel = SettingsViewModel()
    
    init(url: String, fileName: String, outputDirectory: String, upscaleLevel: Int, denoiseLevel: Int, upscaleModel: String, TTX: Bool, suffix: String, originalSize: Resolution, status: TaskStatus) {
        self.url = url
        self.fileName = fileName
        self.originalSize = originalSize
        self.status = status
        parameterControl.updateAvailableLevels(for: self.parameterControl.upscaleModel)
    }
    
    func updateAvaliableParameters() {
        parameterControl.updateAvailableLevels(for: self.parameterControl.upscaleModel)
        self.objectWillChange.send()
    }
}


extension Task {
    func withResolution(width: Int, height: Int) -> Task {
        self.originalSize = Resolution(width: width, height: height)
        return self
    }
}
