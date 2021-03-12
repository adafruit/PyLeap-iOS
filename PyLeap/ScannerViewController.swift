//
//  ScannerViewController.swift
//  PyLeap
//
//  Created by Trevor Beaton on 3/7/21.
//

import UIKit
import CoreBluetooth
//Protocol

protocol ScannerViewControllerDelegate: class {
  func scannerViewController(_ viewController: ScannerViewController,
                             peripheral: CBPeripheral,
                             txChar: CBCharacteristic,
                             peripheralName: String)
}

//protocol ScannerViewControllerDelegate: class {
//  func scannerViewController(_ viewController: ScannerViewController, peripheralName: String)
//}

class ScannerViewController: UIViewController {

  // Data
   var centralManager: CBCentralManager!
   var tempBluefruitPeripheral: CBPeripheral!
   var tempTxCharacteristic: CBCharacteristic!
  private var tempRxCharacteristic: CBCharacteristic!
  private var peripheralArray: [CBPeripheral] = []
  var deviceString: String?

  

//for delegate pattern
//Weak so that there's no chance for a retain cycle
  weak var delegate: ScannerViewControllerDelegate?
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
    peripheralArray.removeAll()
    print("started scan")
    centralManager?.scanForPeripherals(withServices: [NUSCBUUID.BLEService_UUID])
      Timer.scheduledTimer(withTimeInterval: 15, repeats: false) {_ in
        print("Stopped Scan")
       // self.stopScanning()
    //    self.activitySpinner.stopAnimating()
   //     self.activitySpinner.hidesWhenStopped = true
      }
  }

  func stopScanning() -> Void {
      centralManager?.stopScan()
  }

  func connectToDevice() -> Void {

    centralManager?.connect(tempBluefruitPeripheral!, options: nil)

   // BlePeripheral.connectedPeripheral = tempBluefruitPeripheral


}

  func delayedConnection() -> Void {

    delegate?.scannerViewController(self, peripheral: tempBluefruitPeripheral, txChar: tempTxCharacteristic, peripheralName: tempBluefruitPeripheral.name ?? "Device")

  DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
    //Once connected, move to new view controller to manager incoming and outgoing data
    let storyboard = UIStoryboard(name: "Main", bundle: nil)

    let detailViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController

    self.navigationController?.pushViewController(detailViewController, animated: true)
  })
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

  override func viewDidDisappear(_ animated: Bool) {
    BlePeripheral.connectedPeripheral = tempBluefruitPeripheral
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
          print("Discovered Services: \(services)")
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

            print("TX Characteristic: \(tempTxCharacteristic.uuid)")


          }

        }
    delayedConnection()
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

      print("Peripheral Discovered: \(peripheral)")

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

extension ScannerViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

      tempBluefruitPeripheral = peripheralArray[indexPath.row]
      //delegate?.scannerViewController(self, peripheralName: text)
      BlePeripheral.connectedPeripheral = tempBluefruitPeripheral
   //   ViewController.sharedInstance.bluefruitPeripheral = tempBluefruitPeripheral
      connectToDevice()



    }
}
