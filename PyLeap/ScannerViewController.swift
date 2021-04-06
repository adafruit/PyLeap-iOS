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


class ScannerViewController: UIViewController {



  func getBlePeripheral(_ peripheral: CBPeripheral) {
//peripheral = tempBluefruitPeripheral
  }

  func getTXCharacteristic(_ characteristic: CBCharacteristic) {
   // characteristic =
  }






  // Data
   var centralManager: CBCentralManager!
   var tempBluefruitPeripheral: CBPeripheral!
   var tempTxCharacteristic: CBCharacteristic!
  private var tempRxCharacteristic: CBCharacteristic!
  private var peripheralArray: [CBPeripheral] = []
  var deviceString: String?
    var valueData: Data?

// Weak so that there's no chance for a retain cycle

// UI
  @IBOutlet weak var bleTableView: UITableView!

  @IBOutlet weak var activitySpinner: UIActivityIndicatorView!

  @IBAction func buttonPressed(_ sender: Any) {
 //   guard let text = customTextField.text else { return }
//    guard let peripheral = bluefruitPeripheral else { return }
//    guard let txChar = txCharacteristic else { return }
//    guard let rxChar = rxCharacteristic else { return }
//    guard let text = deviceString else { return }


 //   delegate?.scannerViewController(self, peripheral: bluefruitPeripheral, txChar: txCharacteristic, rxChar: rxCharacteristic, peripheralName: bluefruitPeripheral.name!)


    //delegate?.scannerViewController(self, peripheralName: text)
 //   dismiss(animated: true, completion: nil)
  }





  func startScanning() -> Void {
      // Start Scanning

    if let periph = BlePeripheral.connectedPeripheral {
      centralManager.cancelPeripheralConnection(periph)

    } else {
      print("Nil")
    }



    peripheralArray.removeAll()
    print("started scan")
    centralManager?.scanForPeripherals(withServices: [])
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
    centralManager?.connect(tempBluefruitPeripheral!, options: nil)

}

 @objc func delayedConnection() -> Void {

   // consoleViewController.delegate = self
//    consoleViewController.bluefruitPeripheral = self.tempBluefruitPeripheral
//    consoleViewController.txCharacteristic = self.tempTxCharacteristic
//    consoleViewController.testString = "Hello"

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
    //Once connected, move to new view controller to manager incoming and outgoing data

   // self.present(consoleViewController, animated: true, completion: nil)

    let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
    let detailViewController = storyboard.instantiateViewController(withIdentifier: "ConsoleViewController") as! ConsoleViewController
//
  // self.navigationController?.popViewController(animated: true)
//    self.delegate?.getBlePeripheral(self.tempBluefruitPeripheral)
//    self.delegate?.getTXCharacteristic(self.tempTxCharacteristic)
//
//
    self.navigationController?.pushViewController(detailViewController, animated: true)




    
    
  })
}

  func getData() {
          print("data being retrieved...")
       //   let data: AnyObject? = delegate?.getThatData()
      }

  func test() {

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {

     // self.delegate?.scannerViewController(self, peripheral: self.bluefruitPeripheral, txChar: self.txCharacteristic, rxChar: self.rxCharacteristic, peripheralName: self.bluefruitPeripheral.name!)

      print(self.tempBluefruitPeripheral.name)
      print(self.tempTxCharacteristic.uuid)
      print(self.tempRxCharacteristic.uuid)

    })
  }

  override func viewDidLoad() {
    super.viewDidLoad()



    self.bleTableView.delegate = self
    self.bleTableView.dataSource = self
    self.bleTableView.reloadData()

    centralManager = CBCentralManager(delegate: self, queue: nil)

    activitySpinner.startAnimating()
  }

  override func viewDidAppear(_ animated: Bool) {
    if let blePeripheral = tempBluefruitPeripheral {
      centralManager.cancelPeripheralConnection(blePeripheral)
    } else {
      print("nil")
    }
  }

  override func viewDidDisappear(_ animated: Bool) {
  stopScanning()
  }
}

extension ScannerViewController: CBPeripheralDelegate {

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
    perform(#selector(delayedConnection), with: nil)
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



extension ScannerViewController: CBCentralManagerDelegate {

    // MARK: - Check
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

      tempBluefruitPeripheral = peripheral

      if peripheralArray.contains(peripheral) {
          print("Duplicate Found.")
      } else {
        peripheralArray.append(peripheral)

      }
      
      tempBluefruitPeripheral.delegate = self
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
      self.bleTableView.reloadData()
    }

    // MARK: - Connect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
      print("PyLeap has connected to Peripheral: \(tempBluefruitPeripheral.name)")

      

      tempBluefruitPeripheral.discoverServices([NUSCBUUID.BLEService_UUID])
    }

  

}

extension ScannerViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripheralArray.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

      let cell = tableView.dequeueReusableCell(withIdentifier: "blueCell") as! TableCell

      let peripheralFound = self.peripheralArray[indexPath.row]

        if peripheralFound == nil {
            cell.peripheralLabel.text = "Unknown"
        }else {
            cell.peripheralLabel.text = peripheralFound.name
           
        }
        return cell
    }
}

//// Data extension
extension Data {
    var dataToHexString: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

extension StringProtocol {
    var drop0xPrefix: SubSequence { hasPrefix("0x") ? dropFirst(2) : self[...] }
    var drop0bPrefix: SubSequence { hasPrefix("0b") ? dropFirst(2) : self[...] }
    var hexaToDecimal: Int { Int(drop0xPrefix, radix: 16) ?? 0 }
    var hexaToBinary: String { .init(hexaToDecimal, radix: 2) }
    var decimalToHexa: String { .init(Int(self) ?? 0, radix: 16) }
    var decimalToBinary: String { .init(Int(self) ?? 0, radix: 2) }
    var binaryToDecimal: Int { Int(drop0bPrefix, radix: 2) ?? 0 }
    var binaryToHexa: String { .init(binaryToDecimal, radix: 16) }
}

extension ScannerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

      tempBluefruitPeripheral = peripheralArray[indexPath.row]

      BlePeripheral.connectedPeripheral = tempBluefruitPeripheral

      connectToDevice()



    }
}
//MAYBE YOU'LL NEED TO CONNECT TO THE PERIPHERAL FIRST, BEFORE GETTING THE MANUFACTERER'S NAME DATA.
