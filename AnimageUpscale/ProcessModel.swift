import Foundation

class processThread: Process, ObservableObject, @unchecked Sendable {
    var task: Task
    var process: Process
    init (_ task: Task) {
        self.task = task
        self.process = Process()
        self.process.launchPath = "/Resources/realcugan-ncnn-vulkan-20220728-macos/realcugan-ncnn-vulkan"
        self.process.arguments = ["-i", task.url, "-o", "\(task.parameterControl.outputDirectory)/\(task.fileNameWithoutExtension)\(task.parameterControl.suffix).\(task.fileExtension)", (task.parameterControl.TTX ? "-x" : ""), "-s", (String)(task.parameterControl.upscaleLevel), "-n", (String)(task.parameterControl.denoiseLevel), "-m", task.parameterControl.upscaleModel]
    }
}
