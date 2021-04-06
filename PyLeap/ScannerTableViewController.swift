//
//
//  ScannerViewController.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/7/21.
//
//Mainnnn
import UIKit
import CoreBluetooth
//MARK:- Protocol
//protocol DataDelegate: AnyObject {
//  func getBlePeripheral(_ peripheral: CBPeripheral)
//  func getTXCharacteristic(_ characteristic: CBCharacteristic)
//}


class ScannerTableViewController: UITableViewController {




  // Data
   var centralManager: CBCentralManager!
   private var discoveredPeripherals = [BlePeripheral]()
    var blePeripheral: BlePeripheral!
    
  var tempTxCharacteristic: CBCharacteristic!
  private var tempRxCharacteristic: CBCharacteristic!
  private var peripheralArray: [BlePeripheral] = []
   
    
    
  var deviceString: String?
  var valueData: Data?

// Weak so that there's no chance for a retain cycle

// UI

  @IBOutlet weak var activitySpinner: UIActivityIndicatorView!




    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        discoveredPeripherals.removeAll()
        tableView.reloadData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
       
        centralManager.delegate = self
       
        DispatchQueue.main.async {
                       // self.tableView.reloadData()
                    }
       
        if centralManager.state == .poweredOn {
            print("Scanning....")
        }
        

    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
       print("View Did Load")
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
        tableView.delegate = self
        tableView.dataSource = self
       // tableView.reloadData()
    }



    override func viewDidDisappear(_ animated: Bool) {
   // stopScanning()
    }

  func startScanning() -> Void {
      // Start Scanning
   // tableView.reloadData()
    if let periph = BlePeripheral.connectedPeripheral {
      centralManager.cancelPeripheralConnection(periph)

    } else {
      print("Nil")
    }

    peripheralArray.removeAll()
    print("started scan")
    
    centralManager?.scanForPeripherals(withServices: [])
    tableView.reloadData()
//      Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {_ in
//        print("Stopped Scan")
//       // self.stopScanning()
//    //    self.activitySpinner.stopAnimating()
//   //     self.activitySpinner.hidesWhenStopped = true
//      }
  }

  func stopScanning() -> Void {
    print("stop scan")
      centralManager?.stopScan()
  }

  func connectToDevice() -> Void {
    stopScanning()
    //centralManager?.connect(tempBluefruitPeripheral!, options: nil)

}

 
// MARK:- Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return identifier == "ConsoleViewController"
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "ConsoleViewController" {
//            if let peripheral = sender as? BlePeripheral {
//                let destinationView = segue.destination as! ConsoleViewController
//                destinationView.setPeripheral(peripheral)
//            }
//        }
//    }

    
    
    
    // MARK:- Table view
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nearby devices"
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
   
       // tableView.deselectRow(at: indexPath, animated: true)
        blePeripheral = peripheralArray[indexPath.row]
        blePeripheral.connect()
        
        
        self.performSegue(withIdentifier: "com.segue.console", sender: self)
        
      //  performSegue(withIdentifier: "com.segue.console", sender: )
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is ConsoleViewController {
            let vc = segue.destination as? ConsoleViewController
            vc?.bluefruitPeripheral = blePeripheral
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralArray.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

//        let cell = UITableViewCell()
//        cell.textLabel?.text = "Test"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blueCell") as! TableCell

        let selectedPeripheral =  self.peripheralArray[indexPath.row]
        
        
        if selectedPeripheral != selectedPeripheral {
                cell.peripheralLabel.text = "Unknown"
            }else {
                cell.peripheralLabel.text = selectedPeripheral.localName
        }
        
        cell.setupView(withPeripheral: selectedPeripheral)
        
//        let cell = tableView.dequeueReusableCell(withIdentifier: "blueCell") as! TableCell
//
//        let peripheralFound = self.peripheralArray[indexPath.row]
//
//          if peripheralFound == nil {
//              cell.peripheralLabel.text = "Unknown"
//          }else {
//              cell.peripheralLabel.text = peripheralFound.name
//             
//          }
        return cell
    }
}

extension ScannerTableViewController: CBPeripheralDelegate {

  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

    var characteristicASCIIValue = NSString()

    guard characteristic == tempRxCharacteristic,

          let characteristicValue = characteristic.value,
          let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else { return }

      characteristicASCIIValue = ASCIIstring

    print("Value Recieved: \((characteristicASCIIValue as String))")

    NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: "\((characteristicASCIIValue as String))")
  }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
          print("*******************************************************")

          if ((error) != nil) {
              print("Error discovering services: \(error!.localizedDescription)")
              return
          }
          guard let services = peripheral.services else {
              return
          }
          //We need to discover the all characteristic
          for service in services {
        peripheral.discoverCharacteristics(nil, for: service)
          }
    print("Discovered Services: \(services.count)")
      }

  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

             guard let characteristics = service.characteristics else {
            return
        }

        print("Found \(characteristics.count) characteristics.")

        for characteristic in characteristics {

          if characteristic.uuid.isEqual(NUSCBUUID.BLE_Characteristic_uuid_Rx)  {

            tempRxCharacteristic = characteristic

            peripheral.setNotifyValue(true, for: tempRxCharacteristic!)
            peripheral.readValue(for: characteristic)

            print("RX Characteristic: \(tempRxCharacteristic.uuid)")
          }

          if characteristic.uuid.isEqual(NUSCBUUID.BLE_Characteristic_uuid_Tx){

            tempTxCharacteristic = characteristic

            BlePeripheral.connectedTXChar = characteristic

            print("TX Characteristic: \(tempTxCharacteristic.uuid)")


          }

        }
 //   perform(#selector(delayedConnection), with: nil)
    //delayedConnection()
  }

  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
      guard error == nil else {
          print("Error discovering services: error")
          return
      }
    print("Function: \(#function),Line: \(#line)")
      print("Message sent")
  }

  func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
      print("*******************************************************")
    print("Function: \(#function),Line: \(#line)")
      if (error != nil) {
          print("Error changing notification state:\(String(describing: error?.localizedDescription))")

      } else {
          print("Characteristic's value subscribed")
      }

      if (characteristic.isNotifying) {
          print ("Subscribed. Notification has begun for: \(characteristic.uuid)")
      }
  }

}


// MARK: - CBCentralManagerDelegate
extension ScannerTableViewController: CBCentralManagerDelegate {

    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

      switch central.state {
        case .poweredOff:
            print("Is Powered Off.")

            let alertVC = UIAlertController(title: "Bluetooth Required", message: "Check your Bluetooth Settings", preferredStyle: UIAlertController.Style.alert)

            let action = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (action: UIAlertAction) -> Void in
                self.dismiss(animated: true, completion: nil)
            })

            alertVC.addAction(action)

            self.present(alertVC, animated: true, completion: nil)

        case .poweredOn:
            print("Is Powered On.")
            startScanning()
        case .unsupported:
            print("Is Unsupported.")
        case .unauthorized:
        print("Is Unauthorized.")
        case .unknown:
            print("Unknown")
        case .resetting:
            print("Resetting")
        @unknown default:
          print("Error")
        }
    }

    // MARK: - Discover
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
    //  print("Function: \(#function),Line: \(#line)")

        print("peripheralArray: \(peripheralArray.count)")
        
        let peripheralFound = BlePeripheral(withPeripheral: peripheral, advertisementData: advertisementData, with: centralManager)
        
        print("Peripheral Data: \(peripheralFound.localName)")
        
//        if !discoveredPeripherals.contains(peripheralFound) {
//            discoveredPeripherals.append(peripheralFound)
//            tableView.beginUpdates()
//
//            if discoveredPeripherals.count == 1 {
//                tableView.insertSections(IndexSet(integer: 0), with: .fade)
//            }
//
//        }else {
//            print("this")
//        }
        
        
        //peripheral.delegate = self
//
//
//
//        //***********************************
//      tempBluefruitPeripheral = peripheral
//
        if peripheralArray.contains(peripheralFound) {
          print("Duplicate Found.")
      } else {
        peripheralArray.append(peripheralFound)
        tableView.reloadData()

      }
//
//      tempBluefruitPeripheral.delegate = self
      print("---------------------------------------------- \n")
      print("Peripheral: \(peripheral)\n")

      print("Advertisement Data:  \(advertisementData.count)\n")
        
        for (key,value) in advertisementData{

        print("\(key) : \(value)\n")

        }
        

        
         var manufacturerData: Data? {
                return advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
            }
        
        var manufacturerString: String? {
            return advertisementData[CBAdvertisementDataManufacturerDataKey] as? String
           }
        
        var manufacturerHexDescription: String? {
            guard let manufacturerData = manufacturerData else { return nil }
            return HexUtil.hexDescription(data: manufacturerData)
//            return String(data: manufacturerData, encoding: .utf8)
        }
        
        print("Manufacturer: \(String(describing: manufacturerHexDescription))\n")
        
        var localName: String? {
            return advertisementData[CBAdvertisementDataLocalNameKey] as? String
        }
        
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            assert(manufacturerData.count >= 8)
            //0d00 - TI manufacturer ID
            //Constructing 2-byte data as little endian (as TI's manufacturer ID is 000D)
            let manufactureID = UInt16(manufacturerData[0]) + UInt16(manufacturerData[1]) << 8
            print(String(format: "%04X", manufactureID)) //->000D
            //fe - the node ID that I have given
            let nodeID = manufacturerData[2]
            print(String(format: "%02X", nodeID)) //->FE
            //05 - state of the node (something that remains constant
            let state = manufacturerData[3]
            print(String(format: "%02X", state)) //->05
            //c6f - is the sensor tag battery voltage
            //Constructing 2-byte data as big endian (as shown in the Java code)
            let batteryVoltage = UInt16(manufacturerData[4]) << 8 + UInt16(manufacturerData[5])
            print(String(format: "%04X", batteryVoltage)) //->0C6F
            //32- is the BLE packet counter.
            let packetCounter = manufacturerData[6]
            print(String(format: "%02X", packetCounter)) //->32
        }
        
//        let publicData = Data(bytes: manufacturerData!.bytes, count: Int(manufacturerData!.count))
      //  let str = String(decoding: manufacturerData!, as: UTF8.self)
        let publicDataAsHexString = manufacturerData?.dataToHexString
        // DLog("uart tx \(uartTxCharacteristicWriteType == .withResponse ? "withResponse":"withoutResponse") offset: \(writeStartingOffset): \(HexUtils.hexDescription(data: packet))")
        print("Manufacterer String: \(manufacturerString ?? "No String Found")\n")
        
        print("Manufacterer Data: \(manufacturerHexDescription ?? "Nothing")\n")
       
        print("publicDataAsHexString: \(publicDataAsHexString ?? "<Unknown>")")
        
        print("---------------------------------------------- \n")
        
        DispatchQueue.main.async {
           //             self.tableView.reloadData()
                    }
        
       // tableView.reloadData()
    }



  

}

