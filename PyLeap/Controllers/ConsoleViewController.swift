//
//  ViewController.swift
//  PyLeap
//
//  Created by Trevor Beaton For Adafruit Industries on 3/4/21.
//

import UIKit
import CoreBluetooth


class ConsoleViewController: UIViewController {

  // Data
   var peripheralManager: CBPeripheralManager?
   var centralManager: CBCentralManager!
   var bluefruitPeripheral: BlePeripheral!
   var txCharacteristic: CBCharacteristic!
   var testString: String?
    
  // Params
  var onConnect: (() -> Void)?
  var onDisconnect: (() -> Void)?

  //UI

  @IBOutlet weak var deviceName: UILabel!
  @IBOutlet weak var pyTextView: UITextView!
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var consoleTextView: UITextView!

    let testValue: Data? = "Wine".data(using: .utf8)
    
  @IBAction func buttonPress(_ sender: Any) {

    print("Button Pressed")
    
    let string: String = "abcd"
    let byteArray: [UInt8] = string.utf8.map{UInt8($0)}
    
    consoleTextView.text.append("\n[Sent]: Test \n")
    bluefruitPeripheral.writeOutgoingValue(data: pyTextView.text)
    //bluefruitPeripheral.writeTxCharcateristic(withValue: testValue!)

  }


    
    @IBAction func displayManufacturerInfo(_ sender: Any) {
        self.performSegue(withIdentifier: "com.segue.manufacturer", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ManufacturerViewController {
            let vc = segue.destination as? ManufacturerViewController
            vc?.manufacturerDataString = bluefruitPeripheral.advertisement.manufacturerHexDescription!
            vc?.manufacturerDataDict = bluefruitPeripheral.advertData!
        }
    }

    public func setPeripheral(_ peripheral: BlePeripheral) {
        print(#function)
        bluefruitPeripheral = peripheral
        title = bluefruitPeripheral.localName
      //  peripheral.delegate = self
    }

  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(self, selector: #selector(self.appendRxDataToTextView(notification:)), name: NSNotification.Name(rawValue: "Notify"), object: nil)
    
    deviceName.text = "Connected: \(String(bluefruitPeripheral.localName!))"
   
    print("Manufacturer: \(bluefruitPeripheral.advertisement.manufacturerHexDescription ?? "No Manufacturer Data Found.")")

    createReadAndWriteFile()
  
  }

  @objc func appendRxDataToTextView(notification: Notification) -> Void{
    consoleTextView.text.append("\n[Recv]: \(notification.object!) \n")
    }
    
  func startScanning() -> Void {
      // Start Scanning
    print("started scan")
      Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {_ in

      }
  }

  // function to create file and write into the same.
  public func createReadAndWriteFile() {

   let fileName = "main"

   let documentDirectoryUrl = try! FileManager.default.url(
        for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true
        )

   let fileUrl = documentDirectoryUrl.appendingPathComponent(fileName).appendingPathExtension("py")
     // prints the file path
     print("File path \(fileUrl.path)")
     //data to write in file.
    let stringData = """
Testing
"""

   do {
        try stringData.write(to: fileUrl, atomically: true, encoding: String.Encoding.utf8)
     } catch let error as NSError {
        print (error)
     }

   var readFile = ""

   do {
        readFile = try String(contentsOf: fileUrl)
     } catch let error as NSError {
        print(error)
     }
   //  print (readFile)

    pyTextView.text.append("\(stringData)\n")

  }

  func writeToFile(fileName: String, writeText: String) -> Bool {
      let desktopURL = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      print("desktopURL: " + String(describing: desktopURL))
      let fileURL = desktopURL.appendingPathComponent(fileName).appendingPathExtension("txt")

      print("File Path: \(fileURL.path)")

      do {
          try writeText.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
      } catch let error as NSError {
          print("Error: fileURL failed to write: \n\(error)" )
          return false
      }
      return true
  }

  func fileExist(path: String) -> Bool {
      var isDirectory: ObjCBool = false
      let fm = FileManager.default
      return (fm.fileExists(atPath: path, isDirectory: &isDirectory))
  }

  func readFromFile(fileName: String, readText: inout String) -> Bool {

      let desktopURL = try! FileManager.default.url(for: .desktopDirectory, in: .userDomainMask, appropriateFor: nil, create: true)


      print("desktopURL: " + String(describing: desktopURL))

      let fileURL = desktopURL.appendingPathComponent(fileName).appendingPathExtension("txt")

      if !(fileExist(path: fileURL.path)) {
          print("File Does Not Exist...")
          return false
      }

      print("File Path: \(fileURL.path)")

      do {
          readText = try String(contentsOf: fileURL)
      } catch let error as NSError {
          print("Error: fileURL failed to read: \n\(error)" )
          return false
      }
      return true
  }

  func test(){
    var fName = "HelloFile"

    var fileReadString = ""
  //  print ("2: " + String(readFromFile(fileName: fName, readText: &fileReadString)) + "\n" + fileReadString)

    var fileWriteString = "Test 2"
    print ("1: " + String(writeToFile(fileName: fName, writeText: fileWriteString))  + "\n" + fileWriteString)

    //fileReadString = ""
   //print ("2: " + String(readFromFile(fileName: fName, readText: &fileReadString)) + "\n" + fileReadString)
  }

    func keyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(notification:)), name: UIResponder.keyboardDidHideNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
      }

      deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
      }

      // MARK:- Keyboard
      @objc func keyboardWillChange(notification: Notification) {

        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

          let keyboardHeight = keyboardSize.height
          print(keyboardHeight)
          view.frame.origin.y = (-keyboardHeight + 50)
        }
      }

      @objc func keyboardDidHide(notification: Notification) {
        view.frame.origin.y = 0
      }

    

}






extension ConsoleViewController: CBPeripheralManagerDelegate {

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
    switch peripheral.state {
    case .poweredOn:
        print("Peripheral Is Powered On.")
    case .unsupported:
        print("Peripheral Is Unsupported.")
    case .unauthorized:
    print("Peripheral Is Unauthorized.")
    case .unknown:
        print("Peripheral Unknown")
    case .resetting:
        print("Peripheral Resetting")
    case .poweredOff:
      print("Peripheral Is Powered Off.")
    @unknown default:
      print("Error")
    }
  }


  //Check when someone subscribe to our characteristic, start sending the data
  func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
      print("Device subscribe to characteristic")
  }

}
extension String {
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }

        return results.map { String($0) }
    }
}

// Source: http://stackoverflow.com/a/35201226/2115352

extension Data {

    /// Returns the Data as hexadecimal string.
    var hexString: String {
        var array: [UInt8] = []
        
        #if swift(>=5.0)
        withUnsafeBytes { array.append(contentsOf: $0) }
        #else
        withUnsafeBytes { array.append(contentsOf: getByteArray($0)) }
        #endif
        
        return array.reduce("") { (result, byte) -> String in
            result + String(format: "%02x", byte)
        }
    }

    private func getByteArray(_ pointer: UnsafePointer<UInt8>) -> [UInt8] {
        let buffer = UnsafeBufferPointer<UInt8>(start: pointer, count: count)
        return [UInt8](buffer)
    }
    
}

// Source: http://stackoverflow.com/a/42241894/2115352

public protocol DataConvertible {
    static func + (lhs: Data, rhs: Self) -> Data
    static func += (lhs: inout Data, rhs: Self)
}

extension DataConvertible {
    
    public static func + (lhs: Data, rhs: Self) -> Data {
        var value = rhs
        let data = Data(buffer: UnsafeBufferPointer(start: &value, count: 1))
        return lhs + data
    }
    
    public static func += (lhs: inout Data, rhs: Self) {
        lhs = lhs + rhs
    }
    
}

extension UInt8  : DataConvertible { }
extension UInt16 : DataConvertible { }
extension UInt32 : DataConvertible { }

extension Int    : DataConvertible { }
extension Float  : DataConvertible { }
extension Double : DataConvertible { }

extension String : DataConvertible {
    
    public static func + (lhs: Data, rhs: String) -> Data {
        guard let data = rhs.data(using: .utf8) else { return lhs}
        return lhs + data
    }
    
}

extension Data : DataConvertible {
    
    public static func + (lhs: Data, rhs: Data) -> Data {
        var data = Data()
        data.append(lhs)
        data.append(rhs)
        
        return data
    }
    
}



