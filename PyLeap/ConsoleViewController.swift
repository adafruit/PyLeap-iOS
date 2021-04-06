//
//  ViewController.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/4/21.
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
    private var hapticGenerator: NSObject?
    
    
  //What are these??
  // Params
  var onConnect: (() -> Void)?
  var onDisconnect: (() -> Void)?


  //UI

  @IBOutlet weak var deviceName: UILabel!
  @IBOutlet weak var pyTextView: UITextView!
  @IBOutlet weak var sendButton: UIButton!
  @IBOutlet weak var consoleTextView: UITextView!

  @IBAction func buttonPress(_ sender: Any) {

    print("Button Pressed")
    consoleTextView.text.append("\n[Sent]: Test \n")
   // writeOutgoingValue(data: pyTextView.text.split(by: 5))

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
    
    
    
  @IBAction func bleButton(_ sender: Any) {

    print("Button Press")

  //  let storyboard = UIStoryboard(name: "Main", bundle: nil)

    guard let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScannerViewController") as? ScannerViewController else {
      fatalError("View Controller not found")
  }

    self.navigationController?.pushViewController(detailViewController, animated: true)
  }

    private func prepareHaptics() {
        if #available(iOS 10.0, *) {
            hapticGenerator = UIImpactFeedbackGenerator(style: .heavy)
            (hapticGenerator as? UIImpactFeedbackGenerator)?.prepare()
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
    // Do any additional setup after loading the view.
   // prepareHaptics()

   // bluefruitPeripheral = BlePeripheral.connectedPeripheral
    txCharacteristic = BlePeripheral.connectedTXChar

    deviceName.text = "Connected: \(String(bluefruitPeripheral.localName!))"
    print("Manufacturer: \(bluefruitPeripheral.advertisement.manufacturerHexDescription!)")


//    guard let detailViewController = self.storyboard?.instantiateViewController(withIdentifier: "ScannerViewController") as? ScannerViewController else {
//      fatalError("View Controller not found")
//  }
  //  detailViewController.delegate = self



  //  consoleTextView.text = "Message Sent - Thurs 9:38PM :22 "
    createReadAndWriteFile()
   // centralManager = CBCentralManager(delegate: self, queue: nil) // Save data to file
//    let fileName = "Test"
//    let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//
//    let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("txt")
//    print("FilePath: \(fileURL.path)")
//
//
//    // /Volumes/Max Void/PyLeap/PyLeap/pytest.py
//
//    let writeString = "Testing"
//    do {
//        // Write to the file
//        try writeString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
//    } catch let error as NSError {
//        print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
//    }
//
//    var readString = "" // Used to store the file contents
//    do {
//        // Read the file contents
//        readString = try String(contentsOf: fileURL)
//    } catch let error as NSError {
//        print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
//    }
//    print("File Text: \(readString)")
//
//    /*** Read from project txt file ***/
//
//    // File location
//    let fileURLProject = Bundle.main.path(forResource: "pytest", ofType: "py")
//    // Read from the file
//    var readStringProject = ""
//    do {
//        readStringProject = try String(contentsOfFile: fileURLProject!, encoding: String.Encoding.utf8)
//    } catch let error as NSError {
//         print("Failed reading from URL: \(fileURL), Error: " + error.localizedDescription)
//    }
//
//    print(readStringProject)



  }

  func startScanning() -> Void {
      // Start Scanning
    print("started scan")
    //centralManager?.scanForPeripherals(withServices: [NUSCBUUID.BLEService_UUID])
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
import board
from digitalio import DigitalInOut, Direction, Pull

led = DigitalInOut(board.D13)
led.direction = Direction.OUTPUT

switch = DigitalInOut(board.D5)
switch.direction = Direction.INPUT
switch.pull = Pull.UP   # Pull.Down is available on some MCUs

while True:
    led.value = not switch.value
    time.sleep(0.01)
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

  public func writeOutgoingValue(data: String){

      let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)

      if let bluefruitPeripheral = bluefruitPeripheral {

        if let txCharacteristic = txCharacteristic {

          //bluefruitPeripheral.writeValue(valueString!, for: txCharacteristic, type: CBCharacteristicWriteType.withResponse)

        }
    
      }
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

    var fileWriteString = "We are having fun eating Apples!"
    print ("1: " + String(writeToFile(fileName: fName, writeText: fileWriteString))  + "\n" + fileWriteString)

    //fileReadString = ""
   //print ("2: " + String(readFromFile(fileName: fName, readText: &fileReadString)) + "\n" + fileReadString)
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




