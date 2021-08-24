//
//  ProjectViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/30/21.
//


import Foundation
import SwiftUI

class ProjectViewModel: ObservableObject  {
    
    // MARK: - Properties

    func retrieveCP7xNeopixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy"))
        print("Neopixel File Contents: \(documentsURL)")
        
        self.writeFile(filename: "/neopixel.mpy", data: data!)
    }
    
    func retrieveCP7xCode() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x")
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py"))
        print("Code File Contents: \(documentsURL)")
    
        self.writeFile(filename: "/code.py", data: data!)
    }
    

    @Published var bootUpInfo = ""
    @Published var fileArray: [ContentFile] = []
    
    @Published var showingDownloadAlert = false
    
    @Published var entries = [BlePeripheral.DirectoryEntry]()
    @Published var isTransmiting = false
    @Published var isRootDirectory = false
    @Published var directory = ""
    
    @Published var counter: Int = 0
    
    @Published var fileTransferClient: FileTransferClient?
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    
    
    func setup(fileTransferClient: FileTransferClient?, directory: String) {
        self.fileTransferClient = fileTransferClient
        
        // Clean directory name
        let directoryName = FileTransferUtils.pathRemovingFilename(path: directory)
        //  self.directory = directoryName
        
        // List directory
        listDirectory(directory: directoryName)
    }
    
    func listDirectory(directory: String) {
        isRootDirectory = directory == "/"
        entries.removeAll()
        isTransmiting = true
        
        fileTransferClient?.listDirectory(path: directory) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isTransmiting = false
                
                switch result {
                case .success(let entries):
                    if let entries = entries {
                        self.setEntries(entries)
                        //                        self.directory = directory
                    }
                    else {
                        print("listDirectory: nonexistent directory")
                    }
                    
                case .failure(let error):
                    print("listDirectory \(directory) error: \(error)")
                }
            }
        }
    }
    
    private func setEntries(_ entries: [BlePeripheral.DirectoryEntry]) {
        // Order by directory and as a second criteria order by name
        self.entries = entries.sorted(by: {
            if case .directory = $0.type, case .directory = $1.type  {    // Both directories: order alphabetically
                return $0.name < $1.name
            }
            else if case .file = $0.type, case .file = $1.type {          // Both files: order alphabetically
                
                return $0.name < $1.name
            }
            else {      // Compare directory and file
                if case .directory = $0.type { return true } else { return false }
            }
        })
    }
    
    func CPFolder(){
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x")
        
        
        if FileManager.default.fileExists(atPath: path.absoluteString) {
            print("It does exist!")
        } else {
            print("nope!")
        }
    }
    
    func startup() {
        print("Running Startup")
        
        print("Directory Path: \(directoryPath.path)")
        print("Caches Directory Path: \(cachesPath.path)")
        
        
        do {
            
            let contents = try FileManager.default.contentsOfDirectory(at: directoryPath, includingPropertiesForKeys: nil,options: [.skipsHiddenFiles])
            
            for file in contents {
                print("File Content: \(file.lastPathComponent)")
                
                
                let addedFile = ContentFile(title: file.lastPathComponent)
                self.fileArray.append(addedFile)
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    func makeFileDirectory() {
        // Creating a folder
        let pyleapProjectFolderURL = directoryPath.appendingPathComponent("PyLeap Project Folder")
        
        do {
            
            try FileManager.default.createDirectory(at: pyleapProjectFolderURL,
                                                    withIntermediateDirectories: true,
                                                    attributes: [:])
        } catch {
            print(error)
        }
    }
    
    func gatherFiles() {
        // Creating a File Manager Object
        let manager = FileManager.default
        
        // Creating a path to make a document directory path
        guard let url = manager.urls(for: .documentDirectory,in: .userDomainMask).first else {return}
        
        var files = [URL]()
        
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        
                        files.append(fileURL)
                        print("\(fileURL.lastPathComponent) \n")
                        
                        //MARK:- Reads Files
                        
                    }
                } catch { print(error, fileURL) }
            }
            print(files)
        }
    }
    
    func editableTextExitor (variable double1: Double) -> String{
        
        var code: String = """
            Hello \(String(double1))
            """
        return code
    }
    
    func sendCPSevenNeopixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy"))
        print(documentsURL)
        
        writeFile(filename: "/neopixel.mpy", data: data!)
        
        
    }
    
    func sendCPSixNeopixel() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 6.x").appendingPathComponent("lib")
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy"))
        print(documentsURL)
        
        writeFile(filename: "/neopixel.mpy", data: data!)
    }
    
    func sendProjectFile() {
        if let data = ProjectData.inRainbowsSampleProject.pythonCode.data(using: .utf8) {
            writeFile(filename: "/code.py", data: data)
            
        }
    }
    
    struct TransmissionProgress {
        var description: String
        var transmittedBytes: Int
        var totalBytes: Int?
        
        init (description: String) {
            self.description = description
            transmittedBytes = 0
        }
    }
    
    @Published var transmissionProgress: TransmissionProgress?
    
    struct TransmissionLog: Equatable {
        enum TransmissionType: Equatable {
            case read(data: Data)
            case write(size: Int)
            case delete(success: Bool)
            case listDirectory(numItems: Int?)
            case makeDirectory(success: Bool)
            case error(message: String)
        }
        let type: TransmissionType
        
        var description: String {
            let modeText: String
            switch self.type {
            case .read(let data): modeText = "Received \(data.count) bytes"
            case .write(let size): modeText = "Sent \(size) bytes"
            case .delete(let success): modeText = "Deleted file: \(success ? "success":"failed")"
            case .listDirectory(numItems: let numItems): modeText = numItems != nil ? "Listed directory: \(numItems!) items" : "Listed nonexistent directory"
            case .makeDirectory(let success): modeText = "Created directory: \(success ? "success":"failed")"
            case .error(let message): modeText = message
            }
            
            return modeText
        }
    }
    @Published var lastTransmit: TransmissionLog? =  TransmissionLog(type: .write(size: 334))
    
    // Data
    private let bleManager = BleManager.shared
    
    
    // MARK: - Placeholders
    var fileNamePlaceholders: [String] = ["/hello.txt"/*, "/bye.txt"*/, "/test.txt"]
    
    static let defaultFileContentePlaceholder = """
        import time
        import board
        import neopixel
        
        pixels = neopixel.NeoPixel(board.NEOPIXEL, 10, brightness=0.2, auto_write=False)
        rainbow_cycle_demo = 1
        
        def wheel(pos):
                    if pos < 0 or pos > 255:
                        return (0, 0, 0)
                    if pos < 85:
                        return (255 - pos * 3, pos * 3, 0)
                    if pos < 170:
                        pos -= 85
                        return (0, 255 - pos * 3, pos * 3)
                    pos -= 170
                    return (pos * 3, 0, 255 - pos * 3)
        
        def rainbow_cycle(wait):
                    for j in range(255):
                        for i in range(10):
                            rc_index = (i * 256 // 10) + j * 5
                            pixels[i] = wheel(rc_index & 255)
                        pixels.show()
                        time.sleep(wait)
        
        while True:
                    if rainbow_cycle_demo:
                        rainbow_cycle(0.05)
        
        """
    lazy var fileContentPlaceholders: [String] = {
        
        let longText =  "Far far away, behind the word mountains, far from the countries Vokalia and Consonantia, there live the blind texts. Separated they live in Bookmarksgrove right at the coast of the Semantics, a large language ocean. A small river named Duden flows by their place and supplies it with the necessary regelialia. It is a paradisematic country, in which roasted parts of sentences fly into your mouth. Even the all-powerful Pointing has no control about the blind texts it is an almost unorthographic life One day however a small line of blind text by the name of Lorem Ipsum decided to leave for the far World of Grammar. The Big Oxmox advised her not to do so, because there were thousands of bad Commas, wild Question Marks and devious Semikoli, but the Little Blind Text didn’t listen. She packed her seven versalia, put her initial into the belt and made herself on the way. When she reached the first hills of the Italic Mountains, she had a last view back on the skyline of her hometown Bookmarksgrove, the headline of Alphabet Village and the subline of her own road, the Line Lane. Pityful a rethoric question ran over her cheek"
        
        let sortedText = (1...500).map{"\($0)"}.joined(separator: ", ")
        
        return [Self.defaultFileContentePlaceholder, longText, sortedText]
    }()
    
    init() {
        /*
         if AppEnvironment.inXcodePreviewMode {
         transmissionProgress = TransmissionProgress(description: "test")
         transmissionProgress?.transmittedBytes = 33
         transmissionProgress?.totalBytes = 66
         }*/
    }
    
    // MARK: - Setup
    func onAppear(fileTransferClient: FileTransferClient?) {
        registerNotifications(enabled: true)
        setup(fileTransferClient: fileTransferClient)
    }
    
    func onDissapear() {
        registerNotifications(enabled: false)
    }
    
    private func setup(fileTransferClient: FileTransferClient?) {
        guard let fileTransferClient = fileTransferClient else {
            print("Error: undefined fileTransferClient")
            return
        }
        
        self.fileTransferClient = fileTransferClient
    }
    
    // MARK: - Actions
    func disconnectAndForgetPairing() {
        Settings.clearAutoconnectPeripheral()
        if let blePeripheral = fileTransferClient?.blePeripheral {
            bleManager.disconnect(from: blePeripheral)
        }
    }
    
    func readFile(filename: String) {
        startCommand(description: "Reading \(filename)")
        readFileCommand(path: filename) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.lastTransmit = TransmissionLog(type: .read(data: data))
                    let str = String(decoding: data, as: UTF8.self)
                    print("Read: \(str)")
                    self.bootUpInfo = str
                case .failure(let error):
                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
                }
                
                self.endCommand()
            }
        }
    }
    
    func writeFile(filename: String, data: Data) {
        startCommand(description: "Writing \(filename)")
        writeFileCommand(path: filename, data: data) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.lastTransmit = TransmissionLog(type: .write(size: data.count))
                    
                case .failure(let error):
                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
                }
                
                self.endCommand()
            }
        }
    }
    
    func listDirectory(filename: String) {
        let directory = FileTransferUtils.pathRemovingFilename(path: filename)
        
        startCommand(description: "List directory")
        
        listDirectoryCommand(path: directory) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let entries):
                    self.lastTransmit = TransmissionLog(type: .listDirectory(numItems: entries?.count))
                    
                case .failure(let error):
                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
                }
                
                self.endCommand()
            }
        }
    }
    
    func deleteFile(filename: String) {
        startCommand(description: "Deleting \(filename)")
        
        deleteFileCommand(path: filename) { [weak self]  result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.lastTransmit = TransmissionLog(type: .delete(success: success))
                    
                case .failure(let error):
                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
                }
                
                self.endCommand()
            }
        }
    }
    
    func makeDirectory(filename: String) {
        startCommand(description: "Creating \(filename)")
        
        makeDirectoryCommand(path: filename) { [weak self]  result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                switch result {
                case .success(let success):
                    self.lastTransmit = TransmissionLog(type: .makeDirectory(success: success))
                    
                case .failure(let error):
                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
                }
                
                self.endCommand()
            }
        }
    }
    
    // MARK: - Command Status
    private func startCommand(description: String) {
        transmissionProgress = TransmissionProgress(description: description)    // Start description with no progress 0 and undefined Total
        lastTransmit = nil
    }
    
    private func endCommand() {
        transmissionProgress = nil
    }
    
    private func readFileCommand(path: String, completion: ((Result<Data, Error>) -> Void)?) {
        print("start readFile \(path)")
        fileTransferClient?.readFile(path: path, progress: { [weak self] read, total in
            print("reading progress: \( String(format: "%.1f%%", Float(read) * 100 / Float(total)) )")
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.transmissionProgress?.transmittedBytes = read
                self.transmissionProgress?.totalBytes = total
            }
        }) { result in
            if AppEnvironment.isDebug {
                switch result {
                case .success(let data):
                    print("readFile \(path) success. Size: \(data.count)")
                    
                case .failure(let error):
                    print("readFile  \(path) error: \(error)")
                }
            }
            
            completion?(result)
        }
    }
    
    private func writeFileCommand(path: String, data: Data, completion: ((Result<Void, Error>) -> Void)?) {
        print("start writeFile \(path)")
        fileTransferClient?.writeFile(path: path, data: data, progress: { [weak self] written, total in
            print("writing progress: \( String(format: "%.1f%%", Float(written) * 100 / Float(total)) )")
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.transmissionProgress?.transmittedBytes = written
                self.transmissionProgress?.totalBytes = total
            }
        }) { result in
            if AppEnvironment.isDebug {
                switch result {
                case .success:
                    print("writeFile \(path) success. Size: \(data.count)")
                    

                //Maybe post here Saber
                
                
                case .failure(let error):
                    print("writeFile  \(path) error: \(error)")
                }
            }
            
            completion?(result)
        }
    }
    
    private func deleteFileCommand(path: String, completion: ((Result<Bool, Error>) -> Void)?) {
        print("start deleteFile \(path)")
        fileTransferClient?.deleteFile(path: path) { result in
            if AppEnvironment.isDebug {
                switch result {
                case .success(let success):
                    print("deleteFile \(path) \(success ? "success":"failed")")
                    
                case .failure(let error):
                    print("deleteFile  \(path) error: \(error)")
                }
            }
            
            completion?(result)
        }
    }
    
    private func listDirectoryCommand(path: String, completion: ((Result<[BlePeripheral.DirectoryEntry]?, Error>) -> Void)?) {
        print("start listDirectory \(path)")
        fileTransferClient?.listDirectory(path: path) { result in
            switch result {
            case .success(let entries):
                print("listDirectory \(path). \(entries != nil ? "Entries: \(entries!.count)" : "Directory does not exist")")
                
            case .failure(let error):
                print("listDirectory \(path) error: \(error)")
            }
            
            completion?(result)
        }
    }
    
    private func makeDirectoryCommand(path: String, completion: ((Result<Bool, Error>) -> Void)?) {
        print("start makeDirectory \(path)")
        fileTransferClient?.makeDirectory(path: path) { result in
            switch result {
            case .success(let success):
                print("makeDirectory \(path) \(success ? "success":"failed")")
                
            case .failure(let error):
                print("makeDirectory \(path) error: \(error)")
            }
            
            completion?(result)
        }
    }
    
    // MARK: - BLE Notifications
    private weak var didDisconnectFromPeripheralObserver: NSObjectProtocol?
    
    private var didSendFile: NSObjectProtocol?
    
    private var didFinishDownload: NSObjectProtocol?
    
    private func registerNotifications(enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        if enabled {
            didFinishDownload = notificationCenter.addObserver(forName: Notification.Name("onFinishDownload"), object: nil, queue: nil, using: {[weak self] notification in self?.didSendFileToPeripheral(notification: notification)})
            
            didSendFile = notificationCenter.addObserver(forName: Notification.Name("Testing"), object: nil, queue: nil, using: {[weak self] notification in self?.didSendFileToPeripheral(notification: notification)})
            //Saber
            
            didDisconnectFromPeripheralObserver = notificationCenter.addObserver(forName: .didDisconnectFromPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.didDisconnectFromPeripheral(notification: notification)})
            
        } else {
            if let didDisconnectFromPeripheralObserver = didDisconnectFromPeripheralObserver {notificationCenter.removeObserver(didDisconnectFromPeripheralObserver)}
        }
    }
    
    func didFinishedDownloadingToDevice(notification: Notification) {
        print("Downloaded")
        showingDownloadAlert.toggle()
        sendProjectFile()
        
    }
    
    private func didSendFileToPeripheral(notification: Notification) {
        print("It works")
        sendProjectFile()
        
    }
    
    private func didDisconnectFromPeripheral(notification: Notification) {
        let peripheral = bleManager.peripheral(from: notification)
        
        let currentlyConnectedPeripheralsCount = bleManager.connectedPeripherals().count
        guard let selectedPeripheral = fileTransferClient?.blePeripheral, selectedPeripheral.identifier == peripheral?.identifier || currentlyConnectedPeripheralsCount == 0 else {        // If selected peripheral is disconnected or if there are no peripherals connected (after a failed dfu update)
            return
        }
        
        // Disconnect
        fileTransferClient = nil
    }
}
