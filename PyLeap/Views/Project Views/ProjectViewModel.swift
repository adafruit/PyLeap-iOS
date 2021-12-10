//
//  ProjectViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 6/30/21.
//


import Foundation
import SwiftUI
import FileTransferClient

class ProjectViewModel: ObservableObject  {
    
    var networkMonitor = NetworkMonitor()
    
    @Published var sendingBundle = false
    
    @AppStorage("index") var index = 0
    private weak var fileTransferClient: FileTransferClient?
    
    @Published var fileArray: [ContentFile] = []
    @Published var directoryArray: [ContentFile] = []
    
    @Published var bootUpInfo = ""
    
    @Published var entries = [BlePeripheral.DirectoryEntry]()
    @Published var isTransmiting = false
    @Published var isRootDirectory = false
    @Published var directory = ""
    
    @Published var numOfFiles = 0
    @Published var counter = 0
    @Published var showAlert = false
    
    @Published var didDownload = false
    
    @Published var isConnectedToInternet = false
    
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let cachesPath = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    
    @Published var newBundleDownloaded = false
    @Published var didCompleteTranfer = false
    
    func completedTransfer() {
        
        didCompleteTranfer = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.didCompleteTranfer = false
            
        }
    }
    
    func downloadCheck(at filePath: URL){
       
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            print("Download Check!")
            do {
                
                if FileManager.default.fileExists(atPath: filePath.path) {
                    self.didDownload = true
                    
                    
                    DispatchQueue.main.async {
                        print("FILES AVAILABLE")
                        self.didDownload = false
                        self.didDownload = true
                        self.filesDownloaded(url: filePath)
                        
                    }
                } else {
                    DispatchQueue.main.async {
                        print("FILES NOT DOWNLOADED")
                       
                        
                    }
                }
            } catch {
                print(error)
            }
        }
       
        
        
    }
    
    func internetMonitoring() {

        networkMonitor.startMonitoring()
        
            networkMonitor.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("We're connected!")
                
                DispatchQueue.main.async {
                    self.showAlert = false
                    self.isConnectedToInternet = true
                }
                
                
                
            } else {
                print("No connection.")
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.isConnectedToInternet = false
                }
                
            }

            print("isExpensive :\(path.isExpensive)")
        }
        
    }
    
    enum ProjectViewError: LocalizedError {
        case fileTransferUndefined
    }
    
    
    
    var num = Int()
    // MARK: - View Startup
    func startup(url: URL) {
        print("Running Startup")
        
        print("Directory Path: \(directoryPath.path)")
        print("Caches Directory Path: \(cachesPath.path)")
        
        
        do {
            
            let contents = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil,options: [])
            let subDirs = contents.filter{ $0.isFileURL }
            fileArray.removeAll()
            
            for file in subDirs {
                print("File Content: \(file.lastPathComponent)")
                
                
                let addedFile = ContentFile(title: file.lastPathComponent, fileSize: 0)
                self.fileArray.append(addedFile)
            }
        } catch {
            print("Error: \(error)")
        }
        
    }
    
    // Deletes all files and dic. on Bluefruit device *Except boot_out.txt*
    func removeAllFiles(){
        self.listDirectoryCommand(path: "") { result in
            
            switch result {
                
            case .success(let contents):
                
                print("Listed Content")
                
                for i in contents! where i.name != "boot_out.txt" {
                    self.deleteFileCommand(path: i.name) { deletionResult in
                        switch deletionResult {
                        case .success:
                            print("Successfully Deleted")
                        case .failure:
                            print("Failed to delete.")
                        }
                    }
                }
                
            case .failure:
                print("No content listed")
            }
        }
    }
    
    // MARK: - Test Functions
    /*
     Function takes in a URL path of files downloaded
     Enumerate through the files and sending each one
     - using a result completion handler
     
     */
    let group = DispatchGroup()
    
    
    
    func fileTransferTest2(url: URL) {
        print("Start fileTransferTest")
        
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_Blinky_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        var files = [URL]()
        
        if let enumerator = FileManager.default.enumerator(at: documentsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        
                        print(files.count)
                        files.append(fileURL)
                        print("TEST")
                        print("File name: \(fileURL.deletingPathExtension().lastPathComponent)")
                        print("Path Extention:.\(fileURL.pathExtension)\n")
                        
                        //                        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fileURL.deletingPathExtension().lastPathComponent, relativeTo: url).appendingPathExtension(fileURL.pathExtension)) else {
                        //                             print("error retrieving file")
                        //                             return
                        //                         }
                        //
                        
                        //                        self.writeFileCommand(path: "/\(fileURL.deletingPathExtension().lastPathComponent).\(fileURL.pathExtension)", data: data) { result in
                        //
                        //                            switch result {
                        //                            case .success:
                        //
                        //                                    print("Success")
                        //
                        //
                        //                               // self.sendBlinkCode()
                        //                            case .failure:
                        //                                print("Faliure")
                        //                            }
                        //                        }
                        
                    }
                } catch { print(error, fileURL) }
                
                for index in files {
                    
                    
                    guard let data = try? Data(contentsOf: URL(fileURLWithPath: fileURL.deletingPathExtension().lastPathComponent, relativeTo: documentsURL ).appendingPathExtension(fileURL.pathExtension)) else {
                        print("error retrieving file")
                        return
                    }
                    group.enter()
                    //async function
                    writeFileCommand(path: "/\(index.deletingPathExtension().lastPathComponent).\(fileURL.pathExtension)", data: data) { result in
                        switch result {
                            
                        case .success(_):
                            do { self.group.leave() }
                        case .failure(_):
                            print("Failed to write \(index.deletingPathExtension().lastPathComponent)")
                        }
                    }
                }
                
                print("xxFiles: \(files)")
            }
            
        }
    }
    
    func filesDownloaded(url: URL){
        print("Files downloaded")
        fileArray.removeAll()
        
        var files = [URL]()
        
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey, .addedToDirectoryDateKey,.isDirectoryKey])
                    if fileAttributes.isRegularFile!  {
                        
                        files.append(fileURL)
                        
                        print("File name: \(fileURL.deletingPathExtension().lastPathComponent)")
                        print("Path Extention:.\(fileURL.pathExtension)\n")
                        
                        let resources = try fileURL.resourceValues(forKeys:[.fileSizeKey])
                        let fileSize = resources.fileSize!
                        
                        print("Path Size:\(fileSize) kb\n")
                        
                        let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: fileSize)
                        fileArray.append(addedFile)
                    }
                    
                    if fileAttributes.isDirectory! {
                        
                        
                        //                        let resources = try fileURL.resourceValues(forKeys:[.fileSizeKey])
                        //                        let fileSize = resources.fileSize!
                        
                        let addedFile = ContentFile(title: fileURL.lastPathComponent, fileSize: 0)
                        directoryArray.append(addedFile)
                        print("directory name: \(fileURL.deletingPathExtension().lastPathComponent)")
                    }
                    
                } catch { print(error, fileURL) }
            }
            numOfFiles = fileArray.count
            print("File Count: \(self.fileArray.count)")
            print("\(files)")
        }
    }
    
    func filesTest(url: URL){
        print("Files downloaded at this URL...")
        
        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey, .addedToDirectoryDateKey,.isDirectoryKey])
                    if fileAttributes.isRegularFile!  {
                        
                        num += 1
                        print("File name: \(fileURL.deletingPathExtension().lastPathComponent)")
                        print("Path Extention:.\(fileURL.pathExtension)\n")
                        print("Number: \(num)")
                        
                        
                        
                        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fileURL.deletingPathExtension().lastPathComponent, relativeTo: url).appendingPathExtension(fileURL.pathExtension)) else {
                            print("Failed to get file from path.")
                            return
                        }
                        
                        
                        writeFileCommand(path: "/\(fileURL.deletingPathExtension().lastPathComponent).\(fileURL.pathExtension)", data: data) { result in
                            switch result {
                            case .success:
                                
                                
                                print("Successful File Transfer: \(fileURL.lastPathComponent)")
                                
                                
                                
                            case .failure:
                                print("Failure - File Transfer")
                                
                            }
                            
                        }
                        
                    }
                    
                    if fileAttributes.isDirectory! {
                        
                        print("Directory name: \(fileURL.deletingPathExtension().lastPathComponent)")
                    }
                    
                } catch { print(error, fileURL) }
            }
            
        }
    }
    
    func fileTransferTest(){
        print("Start fileTransferTest")
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x")
        
        
        var files = [URL]()
        
        if let enumerator = FileManager.default.enumerator(at: documentsURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsPackageDescendants]) {
            for case let fileURL as URL in enumerator {
                do {
                    let fileAttributes = try fileURL.resourceValues(forKeys:[.isRegularFileKey])
                    if fileAttributes.isRegularFile! {
                        
                        print(files.count)
                        files.append(fileURL)
                        print("TEST")
                        print("File name: \(fileURL.deletingPathExtension().lastPathComponent)")
                        print("Path Extention:.\(fileURL.pathExtension)\n")
                        
                        guard let data = try? Data(contentsOf: URL(fileURLWithPath: fileURL.deletingPathExtension().lastPathComponent, relativeTo: documentsURL).appendingPathExtension(fileURL.pathExtension)) else {
                            print("error retrieving file")
                            return
                        }
                        
                        
                        self.writeFileCommand(path: "/\(fileURL.deletingPathExtension().lastPathComponent).\(fileURL.pathExtension)", data: data) { result in
                            
                            switch result {
                            case .success:
                                
                                print("Success")
                                
                                
                                // self.sendBlinkCode()
                            case .failure:
                                print("Faliure")
                            }
                        }
                        
                        
                        
                        
                    }
                } catch { print(error, fileURL) }
                print("xxFiles: \(files)")
            }
            
        }
    }
    
    
    
    
    
    
    
    // MARK: - Bluefruit Playback MP3
    
    func MP3ProjCheck() {
        listDirectoryCommand(path: "") { result in
            
            switch result {
                
            case .success(let contents):
                
                if contents!.contains(where: { name in name.name == "lib"}) {
                    print("lib directory exist")
                    self.sendPlayMP3Code()
                    
                    DispatchQueue.main.async {
                        self.sendingBundle = true
                    }
                    
                } else {
                    print("lib directory does not exist")
                    self.sendPlayMP3Proj()
                }
                
            case .failure:
                print("failure")
                
            }
            
        }
    }
    
    
    func sendPlayMP3Proj() {
        
        self.makeDirectoryCommand(path: "lib") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitCPPlayMP3()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func createAdafruitCPPlayMP3(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_circuitplayground") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitBusDevicePlayMP3()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func createAdafruitBusDevicePlayMP3(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_bus_device") { result in
            switch result {
            case .success:
                print("Success")
                self.sendPlayMP3Code()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func sendPlayMP3Code(){
        
        
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("error retrieving wav project")
            return
        }
        
        DispatchQueue.main.async {
            self.sendingBundle = true
        }
        
        self.writeFileCommand(path: "/code.py", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                self.sendBeatsPlayMP3()
            case .failure:
                print("Faliure")
            }
        }
        
        
    }
    
    
    func sendBeatsPlayMP3(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "beats", relativeTo: documentsURL).appendingPathExtension("mp3")) else {
            print("error retrieving wav project")
            return
        }
        
        self.writeFileCommand(path: "/beats.mp3", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                self.sendHappyPlayMP3()
            case .failure:
                print("Faliure")
            }
        }
    }
    
    
    func sendHappyPlayMP3(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "happy", relativeTo: documentsURL).appendingPathExtension("mp3")) else {
            print("error retrieving mp3 project")
            return
        }
        
        self.writeFileCommand(path: "/happy.mp3", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                self.mp3init_File()
            case .failure:
                print("Faliure")
            }
        }
    }
    
    
    // MARK: - Adafruit Bus
    func mp3init_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("Fail wavinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/__init__.py", data: data) { result in
            switch result {
            case .success:
                self.mp3i2c_device_File()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func mp3i2c_device_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/i2c_device.mpy", data: data) { result in
            switch result {
            case .success:
                
                self.mp3spi_device_File()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func mp3spi_device_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "spi_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/spi_device.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPinit_FilePlayMP3()
                //self.createAdafruitCP()
                print("Success")
                
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    // MARK: - Adafruit CircuitPlayground
    
    func adafruitCPinit_FilePlayMP3() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/__init__.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPBluefruit_FilePlayMP3()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPBluefruit_FilePlayMP3() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "bluefruit", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/bluefruit.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPbase_FilePlayMP3()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPbase_FilePlayMP3() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "circuit_playground_base", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/circuit_playground_base.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPExpress_FilePlayMP3()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPExpress_FilePlayMP3() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "express", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/express.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_lis3dh_FilePlayMP3()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_lis3dh_FilePlayMP3() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_lis3dh", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_lis3dh.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_pixelBuf_FilePlayMP3()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_pixelBuf_FilePlayMP3() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_pixelbuf", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_pixelbuf.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_thermistor_FilePlayMP3()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_thermistor_FilePlayMP3() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_thermistor", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail thermistor")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_thermistor.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_neopixelPlayMP3()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_neopixelPlayMP3() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_MP3").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail neopixel")
            return
        }
        
        self.writeFileCommand(path: "/lib/neopixel.mpy", data: data) { result in
            switch result {
            case .success:
                
                print("All Done - Play MP3")
                self.completedTransfer()
                DispatchQueue.main.async {
                    self.sendingBundle = false
                    self.counter = 0
                }
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Bluefruit Sound Meter
    
    
    func soundMeterProjCheck() {
        listDirectoryCommand(path: "") { result in
            
            switch result {
                
            case .success(let contents):
                
                if contents!.contains(where: { name in name.name == "lib"}) {
                    print("lib directory exist")
                    self.sendSoundMeterCode()
                    
                    DispatchQueue.main.async {
                        self.sendingBundle = true
                    }
                    
                    
                } else {
                    print("lib directory does not exist")
                    self.sendSoundMeterProj()
                }
                
            case .failure:
                print("failure")
                
            }
            
        }
    }
    
    func sendSoundMeterProj() {
        self.makeDirectoryCommand(path: "lib") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitCPSoundMeter()
            case .failure:
                print("")
            }
        }
    }
    
    
    func createAdafruitCPSoundMeter(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_circuitplayground") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitBusDeviceSoundMeter()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func createAdafruitBusDeviceSoundMeter(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_bus_device") { result in
            switch result {
            case .success:
                print("Success")
                self.sendSoundMeterCode()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func sendSoundMeterCode(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("error retrieving light meter project")
            return
        }
        
        DispatchQueue.main.async {
            self.sendingBundle = true
        }
        
        
        self.writeFileCommand(path: "/code.py", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                self.wavinit_FileSoundMeter()
            case .failure:
                print("Faliure")
            }
        }
        
        
    }
    
    
    // MARK: - Adafruit Bus
    
    func wavinit_FileSoundMeter() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("Fail wavinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/__init__.py", data: data) { result in
            switch result {
            case .success:
                self.wavi2c_device_FileSoundMeter()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func wavi2c_device_FileSoundMeter() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/i2c_device.mpy", data: data) { result in
            switch result {
            case .success:
                
                self.wavspi_device_FileSoundMeter()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func wavspi_device_FileSoundMeter() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "spi_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/spi_device.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPinit_FileSoundMeter()
                //self.createAdafruitCP()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    // MARK: - Adafruit CircuitPlayground
    
    
    func adafruitCPinit_FileSoundMeter() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/__init__.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPBluefruit_FileSoundMeter()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPBluefruit_FileSoundMeter() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "bluefruit", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/bluefruit.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPbase_FileSoundMeter()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPbase_FileSoundMeter() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "circuit_playground_base", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/circuit_playground_base.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPExpress_FileSoundMeter()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPExpress_FileSoundMeter() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "express", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/express.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_lis3dh_FileSoundMeter()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_lis3dh_FileSoundMeter() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_lis3dh", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_lis3dh.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_pixelBuf_FileSoundMeter()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_pixelBuf_FileSoundMeter() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_pixelbuf", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_pixelbuf.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_thermistor_FileSoundMeter()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_thermistor_FileSoundMeter() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_thermistor", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail thermistor")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_thermistor.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_neopixelSoundMeter()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_neopixelSoundMeter() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Sound_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail neopixel")
            return
        }
        
        self.writeFileCommand(path: "/lib/neopixel.mpy", data: data) { result in
            switch result {
            case .success:
                
                print("All Done - Sound Meter")
                self.completedTransfer()
                DispatchQueue.main.async {
                    self.sendingBundle = false
                    self.counter = 0
                }
                
                
                
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    // MARK: End
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Bluefruit Touch Tone Piano
    
    func pianoNeoPixelProjCheck() {
        listDirectoryCommand(path: "") { result in
            
            switch result {
                
            case .success(let contents):
                
                if contents!.contains(where: { name in name.name == "lib"}) {
                    print("lib directory exist")
                    self.sendPianoNeoPixelCode()
                    
                    DispatchQueue.main.async {
                        self.sendingBundle = true
                    }
                    
                } else {
                    print("lib directory does not exist")
                    self.sendPianoNeoPixelProj()
                }
                
            case .failure:
                print("failure")
                
            }
            
        }
    }
    
    func sendPianoNeoPixelProj() {
        self.makeDirectoryCommand(path: "lib") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitCPPianoNeoPixel()
            case .failure:
                print("")
            }
        }
    }
    
    
    func createAdafruitCPPianoNeoPixel(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_circuitplayground") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitBusDevicePianoNeoPixel()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func createAdafruitBusDevicePianoNeoPixel(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_bus_device") { result in
            switch result {
            case .success:
                print("Success")
                self.sendPianoNeoPixelCode()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func sendPianoNeoPixelCode(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("error retrieving light meter project")
            return
        }
        
        self.writeFileCommand(path: "/code.py", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                
                DispatchQueue.main.async {
                    self.sendingBundle = true
                }
                
                self.wavinit_FilePianoNeoPixel()
            case .failure:
                print("Faliure")
            }
        }
        
        
    }
    
    
    // MARK: - Adafruit Bus
    
    func wavinit_FilePianoNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("Fail wavinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/__init__.py", data: data) { result in
            switch result {
            case .success:
                self.wavi2c_device_FilePianoNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func wavi2c_device_FilePianoNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/i2c_device.mpy", data: data) { result in
            switch result {
            case .success:
                
                self.wavspi_device_FilePianoNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func wavspi_device_FilePianoNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "spi_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/spi_device.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPinit_FilePianoNeoPixel()
                //self.createAdafruitCP()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    // MARK: - Adafruit CircuitPlayground
    
    
    func adafruitCPinit_FilePianoNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/__init__.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPBluefruit_FilePianoNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPBluefruit_FilePianoNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "bluefruit", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/bluefruit.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPbase_FilePianoNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPbase_FilePianoNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "circuit_playground_base", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/circuit_playground_base.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPExpress_FilePianoNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPExpress_FilePianoNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "express", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/express.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_lis3dh_FilePianoNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_lis3dh_FilePianoNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_lis3dh", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_lis3dh.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_pixelBuf_FilePianoNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_pixelBuf_FilePianoNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_pixelbuf", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_pixelbuf.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_thermistor_FilePianoNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_thermistor_FilePianoNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_thermistor", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail thermistor")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_thermistor.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_neopixelPianoNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_neopixelPianoNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Tone_Piano").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail neopixel")
            return
        }
        
       
        
        self.writeFileCommand(path: "/lib/neopixel.mpy", data: data) { result in
            switch result {
            case .success:
                
                print("All Done - Bluefruit Touch Tone Piano")
                self.completedTransfer()
                
                DispatchQueue.main.async {
                    self.sendingBundle = false
                    self.counter = 0
                }
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    // MARK: End
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Button Controlled NeoPixels
    
    func controlledNeoPixelProjCheck() {
        listDirectoryCommand(path: "") { result in
            
            switch result {
                
            case .success(let contents):
                
                if contents!.contains(where: { name in name.name == "lib"}) {
                    print("lib directory exist")
                    self.sendControlledNeoPixelCode()
                    
                    DispatchQueue.main.async {
                        self.sendingBundle = true
                    }
                    
                } else {
                    print("lib directory does not exist")
                    self.sendControlledNeoPixelProj()
                }
                
            case .failure:
                print("failure")
                
            }
            
        }
    }
    
    func sendControlledNeoPixelProj() {
        self.makeDirectoryCommand(path: "lib") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitCPControlledNeoPixel()
            case .failure:
                print("")
            }
        }
    }
    
    
    func createAdafruitCPControlledNeoPixel(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_circuitplayground") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitBusDeviceControlledNeoPixel()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func createAdafruitBusDeviceControlledNeoPixel(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_bus_device") { result in
            switch result {
            case .success:
                print("Success")
                self.sendControlledNeoPixelCode()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func sendControlledNeoPixelCode(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("error retrieving light meter project")
            return
        }
        
        DispatchQueue.main.async {
            self.sendingBundle = true
        }
        
        self.writeFileCommand(path: "/code.py", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                self.wavinit_FileControlledNeoPixel()
            case .failure:
                print("Faliure")
            }
        }
        
        
    }
    
    
    // MARK: - Adafruit Bus
    
    func wavinit_FileControlledNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("Fail wavinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/__init__.py", data: data) { result in
            switch result {
            case .success:
                self.wavi2c_device_FileControlledNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func wavi2c_device_FileControlledNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/i2c_device.mpy", data: data) { result in
            switch result {
            case .success:
                
                self.wavspi_device_FileControlledNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func wavspi_device_FileControlledNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "spi_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/spi_device.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPinit_FileControlledNeoPixel()
                //self.createAdafruitCP()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    // MARK: - Adafruit CircuitPlayground
    
    
    func adafruitCPinit_FileControlledNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/__init__.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPBluefruit_FileControlledNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPBluefruit_FileControlledNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "bluefruit", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/bluefruit.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPbase_FileControlledNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPbase_FileControlledNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "circuit_playground_base", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/circuit_playground_base.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPExpress_FileControlledNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPExpress_FileControlledNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "express", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/express.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_lis3dh_FileControlledNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_lis3dh_FileControlledNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_lis3dh", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_lis3dh.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_pixelBuf_FileControlledNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_pixelBuf_FileControlledNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_pixelbuf", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_pixelbuf.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_thermistor_FileControlledNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_thermistor_FileControlledNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_thermistor", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail thermistor")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_thermistor.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_neopixelControlledNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_neopixelControlledNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Button_Half_NeoPixel_Control").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail neopixel")
            return
        }
        
        self.writeFileCommand(path: "/lib/neopixel.mpy", data: data) { result in
            switch result {
            case .success:
                
                print("All Done - Button Control")
                self.completedTransfer()
                DispatchQueue.main.async {
                    self.sendingBundle = false
                    self.counter = 0
                }
                
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    // MARK: End
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Touch NeoPixel Rainbow
    
    func touchNeoPixelProjCheck() {
        listDirectoryCommand(path: "") { result in
            
            switch result {
                
            case .success(let contents):
                
                if contents!.contains(where: { name in name.name == "lib"}) {
                    print("lib directory exist")
                    self.sendTouchNeoPixelCode()
                    
                    DispatchQueue.main.async {
                        self.sendingBundle = true
                    }
                    
                } else {
                    print("lib directory does not exist")
                    self.sendTouchNeoPixelProj()
                }
                
            case .failure:
                print("failure")
                
            }
            
        }
    }
    
    func sendTouchNeoPixelProj() {
        self.makeDirectoryCommand(path: "lib") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitCPTouchNeoPixel()
            case .failure:
                print("")
            }
        }
    }
    
    
    func createAdafruitCPTouchNeoPixel(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_circuitplayground") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitBusDeviceTouchNeoPixel()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func createAdafruitBusDeviceTouchNeoPixel(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_bus_device") { result in
            switch result {
            case .success:
                print("Success")
                self.sendTouchNeoPixelCode()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func sendTouchNeoPixelCode(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("error retrieving light meter project")
            return
        }
        
        DispatchQueue.main.async {
            self.sendingBundle = true
        }
        
        self.writeFileCommand(path: "/code.py", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                self.wavinit_FileTouchNeoPixel()
            case .failure:
                print("Faliure")
            }
        }
        
        
    }
    
    
    // MARK: - Adafruit Bus
    
    func wavinit_FileTouchNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("Fail wavinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/__init__.py", data: data) { result in
            switch result {
            case .success:
                self.wavi2c_device_FileTouchNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func wavi2c_device_FileTouchNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/i2c_device.mpy", data: data) { result in
            switch result {
            case .success:
                
                self.wavspi_device_FileTouchNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func wavspi_device_FileTouchNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "spi_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/spi_device.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPinit_FileTouchNeoPixel()
                //self.createAdafruitCP()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    // MARK: - Adafruit CircuitPlayground
    
    
    func adafruitCPinit_FileTouchNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/__init__.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPBluefruit_FileTouchNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPBluefruit_FileTouchNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "bluefruit", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/bluefruit.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPbase_FileTouchNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPbase_FileTouchNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "circuit_playground_base", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/circuit_playground_base.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPExpress_FileTouchNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPExpress_FileTouchNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "express", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/express.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_lis3dh_FileTouchNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_lis3dh_FileTouchNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_lis3dh", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_lis3dh.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_pixelBuf_FileLM()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_pixelBuf_FileTouchNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_pixelbuf", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_pixelbuf.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_thermistor_FileTouchNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_thermistor_FileTouchNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_thermistor", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail thermistor")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_thermistor.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_neopixelTouchNeoPixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_neopixelTouchNeoPixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Touch_NeoPixel_Rainbow").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail neopixel")
            return
        }
        
        self.writeFileCommand(path: "/lib/neopixel.mpy", data: data) { result in
            switch result {
            case .success:
                
                print("All Done - Touch Rainbow")
                self.completedTransfer()
                DispatchQueue.main.async {
                    self.sendingBundle = false
                    self.counter = 0
                }
                
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    // MARK: End
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - NeoPixel Light Meter
    
    func lightMeterProjCheck() {
        listDirectoryCommand(path: "") { result in
            
            switch result {
                
            case .success(let contents):
                
                if contents!.contains(where: { name in name.name == "lib"}) {
                    print("lib directory exist")
                    self.sendLightMeterCode()
                    
                    DispatchQueue.main.async {
                        self.sendingBundle = true
                    }
                    
                    
                } else {
                    print("lib directory does not exist")
                    self.sendLightMeterProj()
                }
                
            case .failure:
                print("failure")
                
            }
            
        }
    }
    
    func sendLightMeterProj() {
        self.makeDirectoryCommand(path: "lib") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitCPLightMeter()
            case .failure:
                print("")
            }
        }
    }
    
    
    func createAdafruitCPLightMeter(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_circuitplayground") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitBusDeviceLightMeter()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func createAdafruitBusDeviceLightMeter(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_bus_device") { result in
            switch result {
            case .success:
                print("Success")
                self.sendLightMeterCode()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func sendLightMeterCode(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("error retrieving light meter project")
            return
        }
        
        DispatchQueue.main.async {
            self.sendingBundle = true
        }
        
        self.writeFileCommand(path: "/code.py", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                self.wavinit_FileLM()
            case .failure:
                print("Faliure")
            }
        }
        
        
    }
    
    
    // MARK: - Adafruit Bus
    
    func wavinit_FileLM() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("Fail wavinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/__init__.py", data: data) { result in
            switch result {
            case .success:
                self.wavi2c_device_FileLM()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func wavi2c_device_FileLM() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/i2c_device.mpy", data: data) { result in
            switch result {
            case .success:
                
                self.wavspi_device_FileLM()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func wavspi_device_FileLM() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "spi_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/spi_device.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPinit_FileLM()
                //self.createAdafruitCP()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    // MARK: - Adafruit CircuitPlayground
    
    
    func adafruitCPinit_FileLM() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/__init__.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPBluefruit_FileLM()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPBluefruit_FileLM() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "bluefruit", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/bluefruit.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPbase_FileLM()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPbase_FileLM() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "circuit_playground_base", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/circuit_playground_base.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPExpress_FileLM()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPExpress_FileLM() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "express", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/express.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_lis3dh_FileLM()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_lis3dh_FileLM() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_lis3dh", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_lis3dh.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_pixelBuf_FileLM()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_pixelBuf_FileLM() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_pixelbuf", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_pixelbuf.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_thermistor_FileLM()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_thermistor_FileLM() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_thermistor", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail thermistor")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_thermistor.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_neopixelLM()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_neopixelLM() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_Light_Meter").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail neopixel")
            return
        }
        
        self.writeFileCommand(path: "/lib/neopixel.mpy", data: data) { result in
            switch result {
            case .success:
                
                print("All Done - Light Meter")
                self.completedTransfer()
                DispatchQueue.main.async {
                    self.sendingBundle = false
                    self.counter = 0
                }
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    // MARK: - End
    
    
    
    
    
    
    
    
    // MARK: - Bluefruit Playback WAV
    
    func playWAVProjCheck() {
        listDirectoryCommand(path: "") { result in
            
            switch result {
                
            case .success(let contents):
                
                if contents!.contains(where: { name in name.name == "lib"}) {
                    print("lib directory exist")
                    self.sendwavCode()
                    
                    DispatchQueue.main.async {
                        self.sendingBundle = true
                    }
                    
                } else {
                    print("lib directory does not exist")
                    self.sendPlayWAVProj()
                }
                
            case .failure:
                print("failure")
                
            }
            
        }
    }
    
    
    func sendPlayWAVProj() {
        
        self.makeDirectoryCommand(path: "lib") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitCP()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func createAdafruitCP(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_circuitplayground") { result in
            switch result {
            case .success:
                print("Success")
                self.createAdafruitBusDevice()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func createAdafruitBusDevice(){
        //adafruit_bus_device
        self.makeDirectoryCommand(path: "lib/adafruit_bus_device") { result in
            switch result {
            case .success:
                print("Success")
                self.sendwavCode()
            case .failure:
                print("")
            }
        }
        
    }
    
    
    func sendwavCode(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("error retrieving wav project")
            return
        }
        
        DispatchQueue.main.async {
            self.sendingBundle = true
        }
        
        self.writeFileCommand(path: "/code.py", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                self.sendDipWav()
            case .failure:
                print("Faliure")
            }
        }
        
        
    }
    
    
    func sendDipWav(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "dip", relativeTo: documentsURL).appendingPathExtension("wav")) else {
            print("error retrieving wav project")
            return
        }
        
        self.writeFileCommand(path: "/dip.wav", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                self.sendRiseWav()
            case .failure:
                print("Faliure")
            }
        }
    }
    
    
    func sendRiseWav(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "rise", relativeTo: documentsURL).appendingPathExtension("wav")) else {
            print("error retrieving wav project")
            return
        }
        
        self.writeFileCommand(path: "/rise.wav", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                self.wavinit_File()
            case .failure:
                print("Faliure")
            }
        }
    }
    
    
    // MARK: - Adafruit Bus
    func wavinit_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("Fail wavinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/__init__.py", data: data) { result in
            switch result {
            case .success:
                self.wavi2c_device_File()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func wavi2c_device_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/i2c_device.mpy", data: data) { result in
            switch result {
            case .success:
                
                self.wavspi_device_File()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func wavspi_device_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_bus_device")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "spi_device", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail i2c_device_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_bus_device/spi_device.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPinit_File()
                //self.createAdafruitCP()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    // MARK: - Adafruit CircuitPlayground
    
    func adafruitCPinit_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPinit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/__init__.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPBluefruit_File()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPBluefruit_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "bluefruit", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/bluefruit.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPbase_File()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPbase_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "circuit_playground_base", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/circuit_playground_base.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruitCPExpress_File()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruitCPExpress_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_circuitplayground")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "express", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruitCPBluefruit_File")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_circuitplayground/express.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_lis3dh_File()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_lis3dh_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_lis3dh", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_lis3dh.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_pixelBuf_File()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_pixelBuf_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_pixelbuf", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail adafruit_lis3dh")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_pixelbuf.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_thermistor_File()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_thermistor_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_thermistor", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail thermistor")
            return
        }
        
        self.writeFileCommand(path: "/lib/adafruit_thermistor.mpy", data: data) { result in
            switch result {
            case .success:
                self.adafruit_neopixel()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    
    func adafruit_neopixel() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_Bluefruit_WAV").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("Fail neopixel")
            return
        }
        
        self.writeFileCommand(path: "/lib/neopixel.mpy", data: data) { result in
            switch result {
            case .success:
                
                print("All Done - Bluefruit WAV")
                self.completedTransfer()
                DispatchQueue.main.async {
                    self.sendingBundle = false
                    self.counter = 0
                }
                
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    // MARK: - End
    
    
    
    
    // MARK: - Glide on over some rainbows code
    
    func sendCPBRainbowFiles() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        DispatchQueue.main.async {
            self.sendingBundle = true
        }
        
        self.writeFileCommand(path: "/neopixel.mpy", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                self.sendRainbowCode()
            case .failure:
                print("Faliure")
            }
        }
    }
    
    func sendRainbowCode() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py")) else {
            return
        }
        print("Code File Contents: \(documentsURL)")
        
        DispatchQueue.main.async {
            self.sendingBundle = false
        }
        
        self.writeFileCommand(path: "/code.py", data: data) { result in
            
            switch result {
            case .success:
                print("Success 1")
                self.sendRainbowPixelbuf()
            case .failure:
                print("Faliure")
            }
        }
        
        
        
    }
    
    
    func sendRainbowPixelbuf() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_pixelbuf", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        self.writeFileCommand(path: "/adafruit_pixelbuf.mpy", data: data) { result in
            
            switch result {
            case .success:
                print("All Done - Sent over those rainbows!")
                self.completedTransfer()
                DispatchQueue.main.async {
                    self.sendingBundle = false
                    self.counter = 0
                }
            case .failure:
                print("Faliure")
            }
        }
        
    }
    // MARK: - End
    
    
    // MARK: - Blink
    
    func sendBlinkCode() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_Blinky_demo").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py")) else {
            return
        }
        
        DispatchQueue.main.async {
            self.sendingBundle = false
        }
        
        self.writeFileCommand(path: "/code.py", data: data) { result in
            
            switch result {
            case .success:
                print("Success 1")
                self.sendBlinkPixelbuf()
            case .failure:
                print("Faliure")
            }
        }
        
    }
    
    
    func sendCPBBlinkFiles() {
        print("blinkCP7xLib")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_Blinky_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "neopixel", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            print("error retrieving blink neopixel")
            return
        }
        
        DispatchQueue.main.async {
            self.sendingBundle = true
        }
        
        self.writeFileCommand(path: "/neopixel.mpy", data: data) { result in
            
            switch result {
            case .success:
                print("Success 2")
                self.sendBlinkCode()
            case .failure:
                print("Faliure")
            }
        }
    }
    
    func sendBlinkPixelbuf() {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("PyLeap_NeoPixel_Blinky_demo").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_pixelbuf", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        self.writeFileCommand(path: "/adafruit_pixelbuf.mpy", data: data) { result in
            
            switch result {
            case .success:
                print("Success 3")
                self.completedTransfer()
                DispatchQueue.main.async {
                    self.sendingBundle = false
                    self.counter = 0
                }
            case .failure:
                print("Faliure")
            }
        }
        
    }
    
    
    
    
    
    
    
    
    
    func makeRegisterDirectory() {
        
        self.makeDirectoryCommand(path: "adafruit_register") { result in
            switch result {
            case .success:
                self.ledGlassesCode()
            case .failure:
                print("Failure - adafruit_register")
            }
        }
        
    }
    // End of directory creation -- Beginning of file transfers
    
    //MARK: - LED Glasses
    
    func ledGlassesProjCheck() {
        listDirectoryCommand(path: "") { result in
            
            
            switch result {
                
            case .success(let contents):
                
                if contents!.contains(where: { name in name.name == "adafruit_is31fl3741"}) {
                    print("1 exists in the array")
                    self.ledGlassesCode()
                    
                } else {
                    print("1 does not exists in the array")
                    self.sendLEDGlassesFiles()
                }
                
            case .failure:
                print("nothing")
                
            }
            
        }
    }
    
    func sendLEDGlassesFiles(){
        self.makeDirectoryCommand(path: "adafruit_is31fl3741") { result in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.sendingBundle = true
                }
                self.makeRegisterDirectory()
                
                
                
            case .failure:
                print("Failure")
            }
        }
    }
    

    func ledGlassesCP7xCode() {
        print("LED Glasses code attempt")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("LED code not found")
            return
        }

        self.writeFileCommand(path: "/code.py", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                DispatchQueue.main.async {
                    self.sendingBundle = true
                }
                
                self.ledGinit_File()
            case .failure(let error):
                print("Failure - code.py")
            }
        }
        
        
        
    }
    
    func ledGlassesCode() {
        print("LED Glasses code attempt")
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "code", relativeTo: documentsURL).appendingPathExtension("py")) else {
            print("LED code not found")
            return
        }
        print("Code File Contents: \(documentsURL)")
        
        DispatchQueue.main.async {
            self.sendingBundle = true
        }
        
        self.writeFileCommand(path: "/code.py", data: data) { result in
            
            switch result {
            case .success:
                print("Success")
                self.ledGinit_File()
            case .failure(_):
                print("Failure - code.py")
            }
        }
        
        
        
    }
    
    //MARK: - LED Glasses - adafruit_is31fl3741 Files
    
    func ledGinit_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_is31fl3741")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        self.writeFileCommand(path: "/adafruit_is31fl3741/__init__.mpy", data: data) { result in
            switch result {
            case .success:
                self.ledGMain_File()
                print("Success")
            case .failure:
                print("Failure - ledGinit_File")
                
            }
            
        }
    }
    
    func ledGMain_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_is31fl3741")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_ledglasses", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        self.writeFileCommand(path: "/adafruit_is31fl3741/adafruit_ledglasses.mpy", data: data) { result in
            switch result {
            case .success:
                self.ledGrgbmatrixFile()
                print("Success")
            case .failure:
                print("Failure - ledGMain_File")
                
            }
            
        }
        
    }
    
    func ledGrgbmatrixFile() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_is31fl3741")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "adafruit_rgbmatrixqt", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        self.writeFileCommand(path: "/adafruit_is31fl3741/adafruit_rgbmatrixqt.mpy", data: data) { result in
            switch result {
            case .success:
                self.ledGIssi_evb_File()
                print("Success")
            case .failure:
                print("Failure - ledGrgbmatrixFile")
                
            }
            
        }
        
    }
    
    func ledGIssi_evb_File() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_is31fl3741")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "issi_evb", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        self.writeFileCommand(path: "/adafruit_is31fl3741/issi_evb.mpy", data: data) { result in
            switch result {
            case .success:
                self.ledGinit_Reg()
                print("Success")
            case .failure:
                print("Failure - ledGIssi_evb_File")
                
            }
            
        }
        
    }
    
    //MARK: - LED Glasses - adafruit_register Files
    
    func ledGinit_Reg() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_register")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "__init__", relativeTo: documentsURL).appendingPathExtension("py")) else {
            return
        }
        //  self.writeFile(filename: "/adafruit_register/__init__.py", data: data)
        self.writeFileCommand(path: "/adafruit_register/__init__.py", data: data) { result in
            switch result {
            case .success:
                self.ledGbcd_Reg()
                print("Success")
            case .failure:
                print("Failure - ledGinit_Reg")
                
            }
            
        }
    }
    
    func ledGbcd_Reg() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_register")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_bcd_alarm", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        self.writeFileCommand(path: "/adafruit_register/i2c_bcd_alarm.mpy", data: data) { result in
            switch result {
            case .success:
                self.ledGbcd_DaytimeReg()
                print("Success")
            case .failure:
                print("Failure - ledGbcd_Reg")
                
            }
            
        }
        
    }
    
    func ledGbcd_DaytimeReg() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_register")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_bcd_datetime", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        self.writeFileCommand(path: "/adafruit_register/i2c_bcd_datetime.mpy", data: data) { result in
            switch result {
            case .success:
                self.ledGi2c_bit_Reg()
                print("Success")
            case .failure:
                print("Failure - ledGbcd_DaytimeReg")
                
            }
            
        }
        
    }
    
    func ledGi2c_bit_Reg() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_register")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_bit", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        self.writeFileCommand(path: "/adafruit_register/i2c_bit.mpy", data: data) { result in
            switch result {
            case .success:
                self.ledGi2c_bits_Reg()
                print("Success")
            case .failure:
                print("Failure - ledGi2c_bit_Reg")
                
            }
            
        }
    }
    
    func ledGi2c_bits_Reg() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_register")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_bits", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        
        self.writeFileCommand(path: "/adafruit_register/i2c_bits.mpy", data: data) { result in
            switch result {
            case .success:
                self.ledGi2c_struct_array_Reg()
                print("Success")
            case .failure:
                print("Failure - ledGi2c_bits_Reg")
                
            }
            
        }
        
    }
    
    //i2c_struct_array.mpy
    func ledGi2c_struct_array_Reg() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_register")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_struct_array", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        self.writeFileCommand(path: "/adafruit_register/i2c_struct_array.mpy", data: data) { result in
            switch result {
            case .success:
                self.ledGi2c_struct_Reg()
                print("Success")
            case .failure:
                print("Failure - ledGi2c_struct_array_Reg")
                
            }
            
        }
    }
    
    func ledGi2c_struct_Reg() {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_register")
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: "i2c_struct", relativeTo: documentsURL).appendingPathExtension("mpy")) else {
            return
        }
        
        
        self.writeFileCommand(path: "/adafruit_register/i2c_struct.mpy", data: data) { result in
            switch result {
            case .success:
                
                print("ALL DONE")
                self.completedTransfer()
                DispatchQueue.main.async {
                    self.sendingBundle = false
                    self.counter = 0
                }
            case .failure:
                print("Failure - ledGi2c_struct_array_Reg")
                
            }
            
        }
        
    }
    
    func createLEDGlassesLib(){
        makeDirectory(path: "adafruit_is31fl3741")
        makeDirectory(path: "adafruit_register")
        
    }
    
    func testFunction(completion: @escaping ()-> Void){
        
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
    
    //MARK: - End
    
    
    // MARK: System
    
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
    
    
    /*
     // MARK: - Placeholders
     var fileNamePlaceholders: [String] = ["/hello.txt"/*, "/bye.txt"*/, "/test.txt"]
     
     static let defaultFileContentePlaceholder = "This is some editable text 👻😎..."
     lazy var fileContentPlaceholders: [String] = {
     
     let longText = "Far far away, behind the word mountains, far from the countries Vokalia and Consonantia, there live the blind texts. Separated they live in Bookmarksgrove right at the coast of the Semantics, a large language ocean. A small river named Duden flows by their place and supplies it with the necessary regelialia. It is a paradisematic country, in which roasted parts of sentences fly into your mouth. Even the all-powerful Pointing has no control about the blind texts it is an almost unorthographic life One day however a small line of blind text by the name of Lorem Ipsum decided to leave for the far World of Grammar. The Big Oxmox advised her not to do so, because there were thousands of bad Commas, wild Question Marks and devious Semikoli, but the Little Blind Text didn’t listen. She packed her seven versalia, put her initial into the belt and made herself on the way. When she reached the first hills of the Italic Mountains, she had a last view back on the skyline of her hometown Bookmarksgrove, the headline of Alphabet Village and the subline of her own road, the Line Lane. Pityful a rethoric question ran over her cheek"
     
     let sortedText = (1...500).map{"\($0)"}.joined(separator: ", ")
     
     return [Self.defaultFileContentePlaceholder, longText, sortedText]
     }()*/
    
    init() {
        /*
         if AppEnvironment.inXcodePreviewMode {
         transmissionProgress = TransmissionProgress(description: "test")
         transmissionProgress?.transmittedBytes = 33
         transmissionProgress?.totalBytes = 66
         }*/
    }
    
    // MARK: - Setup
    func onAppear(/*fileTransferClient: FileTransferClient?*/) {
        //registerNotifications(enabled: true)
        //setup(fileTransferClient: fileTransferClient)
    }
    
    func onDissapear() {
        //registerNotifications(enabled: false)
    }
    
    
    
    
    
    func setup(fileTransferClient: FileTransferClient?) {
        guard let fileTransferClient = fileTransferClient else {
            DLog("Error: undefined fileTransferClient")
            return
        }
        
        self.fileTransferClient = fileTransferClient
        
    }
    
    // MARK: - Actions
    
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
        guard let fileTransferClient = fileTransferClient else { DLog("Error: makeDirectory called with nil fileTransferClient"); return }
        DLog("makeDirectory: \(path)")
        isTransmiting = true
        fileTransferClient.makeDirectory(path: path) { [weak self] result in
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
        guard let fileTransferClient = fileTransferClient else { return }
        
        DLog("start readFile \(path)")
        fileTransferClient.readFile(path: path, progress: { [weak self] read, total in
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
        guard let fileTransferClient = fileTransferClient else { completion?(.failure(ProjectViewError.fileTransferUndefined)); return }
        counter += 1
        DLog("start writeFile \(path)")
        fileTransferClient.writeFile(path: path, data: data, progress: { [weak self] written, total in
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
        guard let fileTransferClient = fileTransferClient else { completion?(.failure(ProjectViewError.fileTransferUndefined)); return }
        
        DLog("start deleteFile \(path)")
        fileTransferClient.deleteFile(path: path) { result in
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
        guard let fileTransferClient = fileTransferClient else { completion?(.failure(ProjectViewError.fileTransferUndefined)); return }
        
        DLog("start listDirectory \(path)")
        fileTransferClient.listDirectory(path: path) { result in
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
        guard let fileTransferClient = fileTransferClient else { completion?(.failure(ProjectViewError.fileTransferUndefined)); return }
        
        DLog("start makeDirectory \(path)")
        fileTransferClient.makeDirectory(path: path) { result in
            switch result {
            case .success(_ /*let date*/):
                DLog("makeDirectory \(path)")
                
            case .failure(let error):
                DLog("makeDirectory \(path) error: \(error)")
            }
            
            completion?(result)
        }
    }
    
    /*
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
     }*/
    
    
    
    //    func gatherGlassesBundle() {
    //        let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_is31fl3741")
    //
    //        let documentsUrlSecond = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("RainbowBundle").appendingPathComponent("examples").appendingPathComponent("CircuitPython 7.x").appendingPathComponent("lib").appendingPathComponent("adafruit_register")
    //        
    //        do {
    //            // Get the directory contents urls (including subfolders urls)
    //            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil)
    //            let secondDireCont = try FileManager.default.contentsOfDirectory(at: documentsUrlSecond, includingPropertiesForKeys: nil)
    //            
    //            for t in secondDireCont {
    //                let addItem = ContentFile(title: t.lastPathComponent)
    //                
    //                 
    //                fileArray.append(addItem)
    //                
    //            }
    //            
    //            for i in directoryContents {
    //                let addItem = ContentFile(title: i.lastPathComponent)
    //                
    //                fileArray.append(addItem)
    //                
    //            }
    //
    //        } catch {
    //            print(error)
    //        }
    //    }
    
    
    
    
}
