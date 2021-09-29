//
//  ProjectViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/30/21.
//


import Foundation
import SwiftUI

class ProjectViewModel: ObservableObject  {
    
    @AppStorage("index") var index = 0
    
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
    

    // MARK: - Properties

//    func counterFunc(){
//        index += 1
//        print("Index: \(index)")
//    }
    
    
    func blinkCP7xLib() {
        print("blinkCP7xLib")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_Blinky_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("error retrieving blink neopixel")
            return
        }
        self.writeFile(filename: "/neopixel.mpy", data: data)
    }
    
    
    func retrieveCP7xNeopixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        print("Neopixel File Contents: \(documentsURL)")
        
        self.writeFile(filename: "/neopixel.mpy", data: data)
    }

    
    func gatherFiles() {
       print("Gather Files Function Called!")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        // Creating a File Manager Object
        let manager = FileManager.default
        
        // Creating a path to make a document directory path
        guard let url = manager.urls(for: .documentDirectory,in: .userDomainMask).first else {return}
        
        var files = [URL]()
        
        if let enumerator = FileManager.default.enumerator(at: documentsURL, includingPropertiesForKeys: [.isRegularFileKey], options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    
                    if fileAttributes.isRegularFile! {
                        
                        files.append(fileURL)
                       // counterFunc()
                        
                        print("File name: \(fileURL.deletingPathExtension().lastPathComponent)")
                        print("Path Extention: .\(fileURL.pathExtension)\n")
                        
                        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fileURL.deletingPathExtension().lastPathComponent, relativeTo: documentsURL).appendingPathExtension(fileURL.pathExtension)) else {
                            return
                        }
                        
                        index += 1
                        
                        self.writeFile(filename: "/\(fileURL.deletingPathExtension().lastPathComponent).\(fileURL.pathExtension)", data: data)

                        //MARK:- Reads Files
                        
                    }
                } catch { print(error, fileURL) }
            }
           // print(files)
        }
    }
    
    func fileLoader(fileURL: URL, documentURL: URL){
        
        print("File name: \(fileURL.deletingPathExtension().lastPathComponent)")
        print("Path Extention: .\(fileURL.pathExtension) \n")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fileURL.deletingPathExtension().lastPathComponent, relativeTo: documentURL).appendingPathExtension(fileURL.pathExtension)) else {
            return
        }
        
        index += 1
        
        self.writeFile(filename: "/\(fileURL.deletingPathExtension().lastPathComponent).\(fileURL.pathExtension)", data: data)
        
    }
    
    func ledGlassesCP7xLib() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x")
        
      //  let appFolder = documentsURL.appendingPathComponent("lib")
        
     
     //   guard let data = try? Data(contentsOf: URL(fileURLWithPath: "lib", relativeTo: documentsURL)) else {
     //       print("Transfer ERROR")
      //      return
     //   }
        
     //   self.writeFile(filename: "/lib", data: data)
    }
    
    func createLEDGlassesLib(){
        makeDirectory(path: "adafruit_is31fl3741")
        makeDirectory(path: "adafruit_register")
        
    }
    
    
    
    func testFunction(completion: @escaping ()-> Void){
        
        // SEnding first batch
        DispatchQueue.main.asyncAfter(deadline: .now()){
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
            
            guard let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
                return
            }
            print("Neopixel File Contents: \(documentsURL)")
            
            self.writeFile(filename: "/neopixel.mpy", data: data)
            completion()
        }
        
    }
    
    func secondTest(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 5){
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x")
            
            let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py"))
            print("Code File Contents: \(documentsURL)")
        
            self.writeFile(filename: "/code.py", data: data!)
        }
    }
    
    func retrieveCP7xCode() {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x")
            
            let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py"))
            print("Code File Contents: \(documentsURL)")
        
            self.writeFile(filename: "/code.py", data: data!)
        }
        
        func retrieveBlinkCP7xCode() {
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_Blinky_demo").appendingPathComponent("CircuitPython 7.x")
            
            let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py"))
            print("Code File Contents: \(documentsURL)")
        
            self.writeFile(filename: "/code.py", data: data!)
        }


    func ledGlassesCP7xCode() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("example").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py")) else {
            return
        }
        print("Code File Contents: \(documentsURL)")
    
        self.writeFile(filename: "/code.py", data: data)
    }
    
    func retrieveHWCP7xCode() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_Blinky_demo").appendingPathComponent("CircuitPython 7.x")
        
        let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py"))
        print("Code File Contents: \(documentsURL)")
    
        self.writeFile(filename: "/code.py", data: data!)
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
            case delete
            case listDirectory(numItems: Int?)
            case makeDirectory
            case error(message: String)
        }
        let type: TransmissionType
        
        var description: String {
            let modeText: String
            switch self.type {
            case .read(let data): modeText = "Received \(data.count) bytes"
            case .write(let size): modeText = "Sent \(size) bytes"
            case .delete: modeText = "Deleted file"
            case .listDirectory(numItems: let numItems): modeText = numItems != nil ? "Listed directory: \(numItems!) items" : "Listed nonexistent directory"
            case .makeDirectory: modeText = "Created directory"
            case .error(let message): modeText = message
            }
            
            return modeText
        }
    }
    @Published var lastTransmit: TransmissionLog? =  TransmissionLog(type: .write(size: 334))
    
    enum ActiveAlert: Identifiable {
        case error(error: Error)
     
        var id: Int {
            switch self {
                case .error: return 1
            }
        }
    }
    @Published var activeAlert: ActiveAlert?
    
    // Data
    private let bleManager = BleManager.shared


    // MARK: - Placeholders
    var fileNamePlaceholders: [String] = ["/hello.txt"/*, "/bye.txt"*/, "/test.txt"]

    static let defaultFileContentePlaceholder = "This is some editable text 👻😎..."
    lazy var fileContentPlaceholders: [String] = {
        
        let longText = "Far far away, behind the word mountains, far from the countries Vokalia and Consonantia, there live the blind texts. Separated they live in Bookmarksgrove right at the coast of the Semantics, a large language ocean. A small river named Duden flows by their place and supplies it with the necessary regelialia. It is a paradisematic country, in which roasted parts of sentences fly into your mouth. Even the all-powerful Pointing has no control about the blind texts it is an almost unorthographic life One day however a small line of blind text by the name of Lorem Ipsum decided to leave for the far World of Grammar. The Big Oxmox advised her not to do so, because there were thousands of bad Commas, wild Question Marks and devious Semikoli, but the Little Blind Text didn’t listen. She packed her seven versalia, put her initial into the belt and made herself on the way. When she reached the first hills of the Italic Mountains, she had a last view back on the skyline of her hometown Bookmarksgrove, the headline of Alphabet Village and the subline of her own road, the Line Lane. Pityful a rethoric question ran over her cheek"
        
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
            DLog("Error: undefined fileTransferClient")
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
        let directory = FileTransferPathUtils.pathRemovingFilename(path: filename)
        
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
                case .success:
                    self.lastTransmit = TransmissionLog(type: .delete)
                    
                case .failure(let error):
                    self.lastTransmit = TransmissionLog(type: .error(message: error.localizedDescription))
                }
                
                self.endCommand()
            }
        }
    }
    
    func makeDirectory(path: String) {
        // Make sure that the path ends with the separator
        DLog("makeDirectory: \(path)")
        isTransmiting = true
        fileTransferClient?.makeDirectory(path: path) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isTransmiting = false
                
                switch result {
                case .success(_ /*let date*/):
                  print("Success! Path made!")
                    
                case .failure(let error):
                    DLog("makeDirectory \(path) error: \(error)")
                }
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
        DLog("start readFile \(path)")
        fileTransferClient?.readFile(path: path, progress: { [weak self] read, total in
            DLog("reading progress: \( String(format: "%.1f%%", Float(read) * 100 / Float(total)) )")
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.transmissionProgress?.transmittedBytes = read
                self.transmissionProgress?.totalBytes = total
            }
        }) { result in
            if AppEnvironment.isDebug {
                switch result {
                case .success(let data):
                    DLog("readFile \(path) success. Size: \(data.count)")
                    
                case .failure(let error):
                    DLog("readFile  \(path) error: \(error)")
                }
            }
            
            completion?(result)
        }
    }
    
    private func writeFileCommand(path: String, data: Data, completion: ((Result<Date?, Error>) -> Void)?) {
        DLog("start writeFile \(path)")
        fileTransferClient?.writeFile(path: path, data: data, progress: { [weak self] written, total in
            DLog("writing progress: \( String(format: "%.1f%%", Float(written) * 100 / Float(total)) )")
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.transmissionProgress?.transmittedBytes = written
                self.transmissionProgress?.totalBytes = total
            }
        }) { result in
            if AppEnvironment.isDebug {
                switch result {
                case .success:
                    DLog("writeFile \(path) success. Size: \(data.count)")
                    
                case .failure(let error):
                    DLog("writeFile  \(path) error: \(error)")
                }
            }
            
            completion?(result)
        }
    }
    
    private func deleteFileCommand(path: String, completion: ((Result<Void, Error>) -> Void)?) {
        DLog("start deleteFile \(path)")
        fileTransferClient?.deleteFile(path: path) { result in
            if AppEnvironment.isDebug {
                switch result {
                case .success:
                    DLog("deleteFile \(path) success")
                    
                case .failure(let error):
                    DLog("deleteFile  \(path) error: \(error)")
                }
            }
            
            completion?(result)
        }
    }
    
    private func listDirectoryCommand(path: String, completion: ((Result<[BlePeripheral.DirectoryEntry]?, Error>) -> Void)?) {
        DLog("start listDirectory \(path)")
        fileTransferClient?.listDirectory(path: path) { result in
            switch result {
            case .success(let entries):
                DLog("listDirectory \(path). \(entries != nil ? "Entries: \(entries!.count)" : "Directory does not exist")")
                
            case .failure(let error):
                DLog("listDirectory \(path) error: \(error)")
            }
            
            completion?(result)
        }
    }
    
    private func makeDirectoryCommand(path: String, completion: ((Result<Date?, Error>) -> Void)?) {
        DLog("start makeDirectory \(path)")
        fileTransferClient?.makeDirectory(path: path) { result in
            switch result {
            case .success(_ /*let date*/):
                DLog("makeDirectory \(path)")
                
            case .failure(let error):
                DLog("makeDirectory \(path) error: \(error)")
            }
            
            completion?(result)
        }
    }
    
    // MARK: - BLE Notifications
    private weak var didDisconnectFromPeripheralObserver: NSObjectProtocol?

    private func registerNotifications(enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        if enabled {
          didDisconnectFromPeripheralObserver = notificationCenter.addObserver(forName: .didDisconnectFromPeripheral, object: nil, queue: .main, using: {[weak self] notification in self?.didDisconnectFromPeripheral(notification: notification)})
 
        } else {
            if let didDisconnectFromPeripheralObserver = didDisconnectFromPeripheralObserver {notificationCenter.removeObserver(didDisconnectFromPeripheralObserver)}
        }
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
