//
//
//  ScannerTableViewController.swift
//  PyLeap
//
//  Created by Trevor Beaton For Adafruit Industries on 3/7/21.
//
//Main

import UIKit
import CoreBluetooth


class ScannerTableViewController: UITableViewController {
    
    // Data
    var centralManager: CBCentralManager!
    var blePeripheral: BlePeripheral!
    var timer = Timer()
    
    var tempTxCharacteristic: CBCharacteristic!
    var tempRxCharacteristic: CBCharacteristic!
    var peripheralArray = [BlePeripheral]()
    
    // UI
    @IBOutlet weak var scannerButton: UIButton!
    
    @IBAction func scanButtonPressed(_ sender: Any) {
        //Remove peripherals from TableView
        restartScan()
    }
    
    func stopTimer() -> Void {
        // Stops Timer
        self.timer.invalidate()
    }
    
    func restartScan(){
        // If Timer is running, invalidate.
        stopTimer()
        //Remove peripherals from list
        
        // Restart scanning for peripherals
        //Remove connected peripheral
        if let connectedPeripheral = BlePeripheral.connectedPeripheral {
            centralManager.cancelPeripheralConnection(connectedPeripheral)
        } else {
            print("Peripheral was not connected.")
        }
        // Remove all peripherals found
        peripheralArray.removeAll()
        print("started scan")
        
        // Start scan for new peripherals
        
        
        centralManager?.scanForPeripherals(withServices: [], options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
        // Add Timer for this scan ~ 10 seconds
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {_ in
            self.stopScanning()
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if centralManager.state == .poweredOn {
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View Did Load")
        centralManager = CBCentralManager(delegate: self, queue: nil)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
    }
    
    func startScanning() -> Void {
        // Start Scanning
        
        //Remove connected peripheral
        if let periph = BlePeripheral.connectedPeripheral {
            centralManager.cancelPeripheralConnection(periph)
            
        } else {
            print("Peripheral was not connected.")
        }
        // Remove all peripherals found
        peripheralArray.removeAll()
        print("started scan")
        // Start scan for new peripherals
        
        
        centralManager?.scanForPeripherals(withServices: [], options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
        // Add Timer for this scan ~ 10 seconds
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {_ in
            self.stopScanning()
        }
    }
    
    func stopScanning() -> Void {
        print("stop scan")
        centralManager?.stopScan()
        scannerButton.setTitle("Scan", for: .normal)
    }
    
    
    // MARK:- Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return identifier == "ConsoleViewController"
    }
    
    // MARK:- Table view
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Nearby devices"
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        blePeripheral = peripheralArray[indexPath.row]
        blePeripheral.connect()
        self.performSegue(withIdentifier: "com.segue.console", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ConsoleViewController {
            let vc = segue.destination as? ConsoleViewController
            vc?.bluefruitPeripheral = blePeripheral
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "blueCell") as! TableCell
        let selectedPeripheral =  self.peripheralArray[indexPath.row]
        
        if selectedPeripheral != selectedPeripheral {
            cell.peripheralLabel.text = selectedPeripheral.localName
        }else {
            cell.peripheralLabel.text = selectedPeripheral.localName
        }
        
        cell.setupView(withPeripheral: selectedPeripheral)
        
        return cell
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
        
       // print("peripheralArray: \(peripheralArray.count)")
        
        let peripheralID = peripheral.description
        
        let peripheralFound = BlePeripheral(withPeripheral: peripheral, advertisementData: advertisementData, with: centralManager)
    
       // print("Peripheral Data: \(peripheralID)")
        
        print("---------------------------------------------- \n")
        print("Peripheral: \(peripheral.description)\n")
        print("Advertisement Data:  \(advertisementData.count)\n")
        
        for (key,value) in advertisementData {
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
            
        }
        
        print("Manufacturer: \(String(describing: manufacturerHexDescription))\n")
        
        var localName: String? {
            return advertisementData[CBAdvertisementDataLocalNameKey] as? String
        }
        
        var addToList: Bool = false;
        
        if let manufacturerData = advertisementData["kCBAdvDataManufacturerData"] as? Data {
            //0004 -  manufacturer ID
            //Constructing 2-byte data as little endian (as TI's manufacturer ID is 000D)
            let manufacturerID = UInt16(manufacturerData[0]) + UInt16(manufacturerData[1]) << 8
            print(String(format: "%04X", manufacturerID)) //->000D
            // This looks like TI example code. Do we want to remove it?
            if (manufacturerID == 0x000d) {
                assert(manufacturerData.count >= 8)
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
            addToList = manufacturerID == 0x0822;
        }
        
        if(addToList && !peripheralArray.contains(peripheralFound)) {
            peripheralArray.append(peripheralFound)
        }
 //filter_device_list
        
      peripheralArray.sort { $0.localName ?? "Unknown" > $1.localName ?? "Unknown" }
        peripheralArray.reverse()
        self.tableView.reloadData()
        
        print("Manufacterer String: \(manufacturerString ?? "No String Found")\n")
        
        print("Manufacterer Data: \(manufacturerHexDescription ?? "Nothing")\n")
        
        print("---------------------------------------------- \n")
        print(peripheralArray.description)
        print("---------------------------------------------- \n")


    }

    
    // Connect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected To \(String(describing: blePeripheral.name))")
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        
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

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
