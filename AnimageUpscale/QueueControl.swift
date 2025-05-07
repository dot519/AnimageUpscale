import SwiftUI
import AppKit

enum QueueStatus {
    case idle
    case running
}

class QueueControl: ObservableObject {
    @Published var Queue: [Task] = []
    @Published var Status: QueueStatus = .idle
    @Published var failedFiles: [String] = []
    @Published var unsupportedFileTypes: [String] = []
    @Published var currentTask: Task? = nil
    @Published var processThreads: [UUID: ProcessThread] = [:]
    
    func initializeAndAddTasks(from urls: [URL]) {
        var failedFiles: [String] = []
        var unsupportedFiles: [String] = []
        
        let existingFilePaths = Set(Queue.map { $0.url })
        
        let newTasks = urls.compactMap { url -> Task? in
            if existingFilePaths.contains(url.path) {
                failedFiles.append("Existed file: \(url.path)")
                print("Existed file: \(url.path)")
                return nil
            }
            
            if let image = NSImage(contentsOfFile: url.path),
               let imageRep = image.representations.first as? NSBitmapImageRep {
                let resolution = Resolution(width: imageRep.pixelsWide, height: imageRep.pixelsHigh)
                return Task(
                    url: url.path,
                    fileName: url.lastPathComponent,
                    outputDirectory: DefaultSettings.outputDirectory,
                    upscaleLevel: DefaultSettings.upscaleLevel,
                    denoiseLevel: DefaultSettings.denoiseLevel,
                    upscaleModel: DefaultSettings.upscaleModel,
                    TTX: DefaultSettings.TTX,
                    suffix: DefaultSettings.suffix,
                    originalSize: resolution,
                    status: .ready
                )
            } else {
                unsupportedFiles.append("Unable to read image: \(url.lastPathComponent)")
                print("Unable to read image: \(url.lastPathComponent)")
                return nil
            }
        }
        
        for task in newTasks {
            task.parameterControl.updateAvailableLevels(for: task.parameterControl.upscaleModel)
        }
        
        DispatchQueue.main.async {
            self.failedFiles = failedFiles
            self.unsupportedFileTypes = unsupportedFiles
            self.objectWillChange.send()
        }
        
        self.Queue.append(contentsOf: newTasks)
    }
    
    private func printTaskDetails(_ task: Task) {
        print("""
        --- Task \(task.id) ---
        File: \(task.fileName)
        URL: \(task.url)
        Model: \(task.parameterControl.upscaleModel)
        Upscale Level: \(task.parameterControl.upscaleLevel)x
        Denoise Level: \(task.parameterControl.denoiseLevel)
        Enable TTX: \(task.parameterControl.TTX)
        Suffix: \(task.parameterControl.suffix)
        Output Directory: \(task.parameterControl.outputDirectory)
        Resolution: \(task.originalSize.width)x\(task.originalSize.height)
        Status: \(task.status)
        Avaliable upscale rate: \(task.parameterControl.availableUpscaleLevels)
        Avaliable denoise level: \(task.parameterControl.availableDenoiseLevels)
        ---------------------
        """)
    }
    
    func printParametersOfAllTasks() {
        for task in Queue {
            printTaskDetails(task)
        }
    }
    
    func removeTasks(withIDs ids: Set<UUID>) {
        Queue.removeAll { task in
            ids.contains(task.id)
        }
    }
    
    func runQueue() {
        guard Status == .idle else { return }
        Status = .running

        DispatchQueue.global(qos: .userInitiated).async {
            for task in self.Queue where task.status == .ready || task.status == .failed {
                if self.Status == .idle { break }

                DispatchQueue.main.sync {
                    self.currentTask = task
                }

                let processThread = ProcessThread(task)
                
                DispatchQueue.main.sync {
                    self.processThreads[task.id] = processThread
                }

                let semaphore = DispatchSemaphore(value: 0)
                
                processThread.run(completion: {
                    semaphore.signal()
                })
                
                DispatchQueue.main.async {
                    self.objectWillChange.send()
                }
                
                semaphore.wait()
                
                DispatchQueue.main.sync {
                    self.currentTask = nil
                }
            }

            DispatchQueue.main.sync {
                self.Status = .idle
            }
        }
    }
    
    
    func stopQueue() {
        guard Status == .running, let currentTask = currentTask else {
            print("stopQueue() called but no running task found.")
            return
        }

        print("Attempting to stop process for task: \(currentTask.fileName)")

        if let processThread = processThreads[currentTask.id] {
            print("Found running process, stopping now...")
            processThread.stop()
            processThreads.removeValue(forKey: currentTask.id)
        } else {
            print("No processThread found for task: \(currentTask.fileName)")
        }

        DispatchQueue.main.async {
            self.Status = .idle
            self.currentTask = nil
        }
    }
}
