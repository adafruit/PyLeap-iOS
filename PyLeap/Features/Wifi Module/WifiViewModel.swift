//
//  WifiViewModel.swift
//  PyLeap
//
//  Created by Trevor Beaton on 8/9/22.
//


import SwiftUI
import CoreLocation
import Network

enum ConnectionStatus {
    case noConnection
    case connecting
    case connected
}

class WifiViewModel: ObservableObject {
    
    let userDefaults = UserDefaults.standard
    private let kPrefix = Bundle.main.bundleIdentifier!
        
    @Published var connectionStatus: ConnectionStatus = .noConnection
    
    @Published  var isInvalidIP = false
    @Published  var ipInputValidation = false
    //Dependencies
    var networkMonitor = NetworkMonitor()
    
    var networkAuth = LocalNetworkAuthorization()
    
    public var wifiNetworkService = WifiNetworkService()
    
    @Published var wifiTransferService =  WifiTransferService()
    
    @Published var wifiServiceManager = WifiServiceManager()
    @ObservedObject var networkModel = NetworkService()
    var circuitPythonVersion = Int()
    
    @Published var webDirectoryInfo = [WebDirectoryModel]()
    
    @Published var hostName = ""
    
    @Published var downloadState: DownloadState = .idle

    let dataStore = DataStore()
    
    @Published var pdemos : [PyProject] = []
    

    func loadProjectsFromStorage() {
        self.pdemos = self.dataStore.loadDefaultList()
    }
    
    func fetchAndLoadProjectsFromStorage() {
        self.networkModel.fetch {
            self.pdemos = self.dataStore.loadDefaultList()
        }
    }
    
    
    // File Manager Data
    let directoryPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    @Published var fileArray: [ContentFile] = []
    @Published var contentList: [URLData] = []
    
    var projectDirectories: [URL] = []
    
    var ipAddressStored = false
    
    init() {
        loadProjectsFromStorage()
        checkIP()
        registerNotifications(enabled: true)
        wifiServiceManager.findService()
    }
    
    /// Makes a network call to populate our project list
    func fetch() {
      //  networkModel.fetch()
    }
    
    @Published var pyleapProjects = [PyProject]()
  
    var boardDataProvider = BoardDataProvider()
    
    
    // This function reads the boards the boot_out.txt file to then set the current board's name and version number for file transfer.
    
    func setBoardToDefault() {
        Board.shared.name = "Unrecognized Board"
        Board.shared.versionNumber = "8"
    }
    
    func read() {
        setBoardToDefault()
        // This method can't be used until the device has permission to communicate.
        print("READING CP Vers.")
        wifiTransferService.getRequest(read: "boot_out.txt") { result in

            let boardID = self.boardDataProvider.getBoardID(from: result) ?? "Unrecognized Board"
            // Board default version is set to 8
            let boardVersion = self.boardDataProvider.getCircuitPythonMajorVersion(from: result) ?? "8"
            
            Board.shared.name = boardID
            Board.shared.versionNumber = boardVersion
            dump(Board.shared)
            
        }
    }
    
    
    

    
    private weak var invalidIPObserver: NSObjectProtocol?
    
    private weak var testObserver: NSObjectProtocol?
    private func registerNotifications(enabled: Bool) {
        let notificationCenter = NotificationCenter.default
        
        if enabled {
            testObserver = notificationCenter.addObserver(forName: .didUpdateState, object: nil, queue: .main, using: {[weak self] _ in self?.checkIP()})
            
            invalidIPObserver = notificationCenter.addObserver(forName: .invalidIPNotif, object: nil, queue: .main, using: {[weak self] _ in self?.checkIP()})
            
        } else {
            if let testObserver = testObserver {notificationCenter.removeObserver(testObserver)}
            
            
        }
    }
    
    
    

    
    func checkIP() {
        
        print("Tiggered checkIP")
        
        if ipAddressStored {
            ipAddressStored = true
            hostName = userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName") as! String
        } else {
                ipAddressStored = false
        }
        
    }
    
    func setIP(ipAddress: String) {
        userDefaults.set(ipAddress, forKey: kPrefix+".storedIP")
        
    }
    
    func noConnectionView() {
        connectionStatus = .noConnection
    }
    
    func connectingView() {
        connectionStatus = .connecting
    }
    
    func connectedView() {
        connectionStatus = .connected
    }
    

    func printStoredInfo() {
        print("======Stored UserDefaults======")
        
        print(userDefaults.object(forKey: kPrefix+".storeResolvedAddress.ipAddress"))
        print(userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName"))
        print(userDefaults.object(forKey: kPrefix+".storeResolvedAddress.device"))
    }
    
    
    func storeResolvedAddress(service: ResolvedService) {
        userDefaults.set(service.ipAddress, forKey: kPrefix+".storeResolvedAddress.ipAddress" )
        userDefaults.set(service.hostName, forKey: kPrefix+".storeResolvedAddress.hostName" )
        userDefaults.set(service.device, forKey: kPrefix+".storeResolvedAddress.device" )

        print("Stored UserDefaults")
        
        print(userDefaults.object(forKey: kPrefix+".storeResolvedAddress.ipAddress"))
        print(userDefaults.object(forKey: kPrefix+".storeResolvedAddress.hostName"))
        print(userDefaults.object(forKey: kPrefix+".storeResolvedAddress.device"))
    }

     func clearKnownIPAddress() {
        userDefaults.set(nil, forKey:  kPrefix+".storedIP")
         
     }
    
    // Attempt to insert non-property list object when trying to save a custom object in Swift
// https://stackoverflow.com/questions/41355427/attempt-to-insert-non-property-list-object-when-trying-to-save-a-custom-object-i
    
    func checkServices(ip: String) {
        
        if wifiServiceManager.resolvedServices.contains(where: { name in name.ipAddress == ip }) {
            print("Exists.")
            
            let resolvedService = wifiServiceManager.resolvedServices.filter { $0.ipAddress == ip }

            // To store in UserDefaults

            storeResolvedAddress(service: resolvedService[0])
            connectionStatus = .connected
            ipInputValidation = true
        } else {
            isInvalidIP = true
            print("1 does not exists in the array")
        }
        
    }
    

    
    
    func checkStoredIP() {
        if userDefaults.object(forKey: kPrefix+".storeResolvedAddress.ipAddress") == nil {
            print("Nothing stored.")
        } else {
            NotificationCenter.default.post(name: .invalidIPNotif, object: nil, userInfo: nil)
        }
    }

        
    
    public func internetMonitoring() {
        
        networkMonitor.monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                print("Connected to internet.")
                
                print(self.networkMonitor.monitor.currentPath.debugDescription)
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    self.networkMonitor.getConnectionType(path)
                    
                }
            } else {
                print("No connection.")
                DispatchQueue.main.async {
                }
            }
            print("isExpensive: \(path.isExpensive)")
        }
    }

}

extension URLRequest {
    public func cURL(pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(self.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(self.url?.absoluteString ?? "")\' \(newLine)"
        
        var cURL = "curl "
        var header = ""
        var data: String = ""
        
        if let httpHeaders = self.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        
        if let bodyData = self.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        
        cURL += method + url + header + data
        
        return cURL
    }
}
