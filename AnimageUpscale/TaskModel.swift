import Foundation

struct DefaultSettings {
    public static var upscaleLevel: Int = 4
    public static var denoiseLevel: Int = -1
    public static var upscaleModel: String = "model-se"
    public static var TTX: Bool = true
    public static var suffix: String = "-2"
    public static var outputDirectory: String = "\(FileManager.default.homeDirectoryForCurrentUser.path)/Downloads"
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
}

struct Task {
    var id = UUID()
    var url: String
    var fileName: String
    var outputDirectory: String
    var upscaleLevel: Int
    var denoiseLevel: Int
    var upscaleModel: String
    var TTX: Bool
    var suffix: String
    var originalSize: Resolution
    var status: TaskStatus = .running
    
    init (url: String,
          fileName: String,
          outputDirectory: String,
          upscaleLevel: Int = DefaultSettings.upscaleLevel,
          denoiseLevel: Int = DefaultSettings.denoiseLevel,
          upscaleModel: String = DefaultSettings.upscaleModel,
          TTX: Bool = DefaultSettings.TTX)
    {
        self.fileName = fileName
        self.url = url
        self.TTX = TTX
        self.outputDirectory = outputDirectory
        self.upscaleLevel = upscaleLevel
        self.denoiseLevel = denoiseLevel
        self.upscaleModel = upscaleModel
        self.suffix = DefaultSettings.suffix
        self.status = .ready
        self.originalSize = Resolution(width: 1920, height: 1080)
    }
}

var ImageDemo = Task(url: "/Users/mac/Downloads/input.png", fileName: "input.png", outputDirectory: "/Users/mac/Downloads/output.png")
