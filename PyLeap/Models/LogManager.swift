//
//  LogManager.swift
//  Glider
//
//  Created by Antonio García on 8/9/21.
//

import Foundation

class LogManager: ObservableObject {
    private static let applicationGroupSharedDirectoryURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.adafruit.PyLeap")!       // Shared between the app and extensions
    private static let logFilename = "log.json"
    private static let fileProviderFilename = "fileprovider_log.json"

    // Singleton
  //  static let shared = LogManager()

    // Data
    private var isFileProvider: Bool
    
    init() {
        #if FILEPROVIDER
        self.isFileProvider = true
        #else
        self.isFileProvider = false
        #endif
        
        load()
    }
    
    init(isFileProvider: Bool) {
        self.isFileProvider = isFileProvider
        load()
    }
    
    deinit {
        save()
    }

    // Data
    struct Entry: Identifiable, Hashable, Codable {
        static var idCounter = 0
        
        enum Category: Int, Codable {
            case unknown = -1
            case app = 0
            case bluetooth = 1
            case fileTransferProtocol = 2
            case fileProvider = 3
        }
        
        enum Level: Int, Codable {
            case debug = 0
            case error = 1
        }
        
        let id: Int
        var category: Category
        var level: Level
        var text: String
        var timestamp: CFAbsoluteTime
        var date: Date {
            return Date(timeIntervalSinceReferenceDate: timestamp)
        }

        init(level: Level, text: String, category: Category = .app, timestamp: CFAbsoluteTime? = nil) {
            self.category = category
            self.level = level
            self.text = text
            self.timestamp = timestamp ?? CFAbsoluteTimeGetCurrent()
            self.id = Self.idCounter
            Self.idCounter += 1
        }
        
        static func debug(text: String, category: Category, timestamp: CFAbsoluteTime? = nil) -> Self {
            return self.init(level: .debug, text: text, category: category, timestamp: timestamp)
        }

        static func error(text: String, category: Category, timestamp: CFAbsoluteTime? = nil) -> Self {
            return self.init(level: .error, text: text, category: category, timestamp: timestamp)
        }

    }
    
    // Published
    @Published  var entries: [Entry] = []
    
    // MARK: - Actions
    private var defaultFileUrl: URL? {
        let filename = isFileProvider ? Self.fileProviderFilename :  Self.logFilename
        return Self.applicationGroupSharedDirectoryURL.appendingPathComponent(filename)
    }
    
    func load() {
        guard let fileUrl = defaultFileUrl else { return }
        guard FileManager.default.fileExists(atPath: fileUrl.path) else { return }
        
        do {
            let data = try Data(contentsOf: fileUrl, options: [])
            entries = try JSONDecoder().decode([Entry].self, from: data)
            Entry.idCounter = entries.count
        } catch {
            print("Log load error: \(error.localizedDescription)")      // don't use DLog to avoid recurve calls durint initilization
        }
    }
    
    func save() {
        guard let fileUrl = defaultFileUrl else { return }
        
        do {
            let json = try JSONEncoder().encode(entries)
            try json.write(to: fileUrl, options: [])
        } catch {
            DLog("Log save error: \(error.localizedDescription)")
        }
    }
    
    func log(_ entry: Entry) {
        let appendHandler = {
            self.entries.append(entry)
        }
        
        // Make sure that we are publishing changes from the main thread
        if Thread.isMainThread {
            appendHandler()
        }
        else {
            DispatchQueue.main.async {
                appendHandler()
            }
        }
        //DLog(message)
    }

    func clear() {
        entries.removeAll()
        save()
        Entry.idCounter = 0
    }
}
