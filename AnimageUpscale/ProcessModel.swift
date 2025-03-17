import Foundation

class ProcessThread: ObservableObject, @unchecked Sendable {
    var task: Task
    private var process: Process

    init(_ task: Task) {
        self.task = task
        self.process = Process()
        self.process.launchPath = Bundle.main.resourcePath! + "/realcugan-ncnn-vulkan-20220728-macos/realcugan-ncnn-vulkan"
        self.process.arguments = [
            "-i", task.url,
            "-o", "\(task.parameterControl.outputDirectory)/\(task.fileNameWithoutExtension)\(task.parameterControl.suffix).\(task.fileExtension)",
            "-s", "\(task.parameterControl.upscaleLevel)",
            "-n", "\(task.parameterControl.denoiseLevel)",
            "-m", "\(task.parameterControl.upscaleModel)"
        ]
        
        if (task.parameterControl.TTX == true) {
            self.process.arguments?.append("-x")
        }
    }

    func run(completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.task.status = .running
            }

            do {
                try self.process.run()
                self.process.waitUntilExit()
                DispatchQueue.main.async {
                    self.task.status = self.process.terminationStatus == 0 ? .completed : .failed
                }
            } catch {
                DispatchQueue.main.async {
                    self.task.status = .failed
                }
            }

            // **任务完成，调用回调**
            completion()
        }
    }

    func stop() {
        process.terminate()
        DispatchQueue.main.async {
            self.task.status = .failed
        }
    }
}
