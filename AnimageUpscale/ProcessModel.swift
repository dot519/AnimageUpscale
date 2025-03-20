import Foundation
import Darwin

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

            completion()
        }
    }

    func stop() {
        print("Stopping process for task: \(task.fileName)")

        if process.isRunning {
            print("Terminating process normally...")
            process.terminate()
            usleep(500_000)  // 等待 0.5 秒，确保进程有时间响应终止信号
        }

        if process.isRunning {
            print("Force killing process...")
            kill(process.processIdentifier, SIGKILL) // 强制终止进程
        }

        DispatchQueue.main.async {
            self.task.status = .failed
        }
    }
}
