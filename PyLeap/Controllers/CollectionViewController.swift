//
//  CollectionViewController.swift
//  PyLeap
//
//  Created by Trevor Beaton on 5/3/21.
//

import UIKit
import CoreBluetooth


class CollectionViewController : UIViewController {
    
    // Data
    var centralManager: CBCentralManager!
    var blePeripheral: BlePeripheral!
    var timer = Timer()
    
    var tempTxCharacteristic: CBCharacteristic!
    var tempRxCharacteristic: CBCharacteristic!
    var peripheralArray = [BlePeripheral]()
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var deviceLabel: UILabel!
    

    @IBAction func scanAction(_ sender: Any) {
    startScanning()
    }
    
    var estimateWidth = 160.0
    var cellMarginSize = 15.0
    
    let boldConfig = UIImage.SymbolConfiguration(weight: .bold)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        // Register Reusable Cell
        self.collectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
        
        self.setupGridView()
        
        deviceLabel.text = "No Devices"
        
    }
    
    func setupGridView() {
        let flow = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        
        flow.minimumInteritemSpacing = CGFloat(self.cellMarginSize)
        flow.minimumLineSpacing = CGFloat(self.cellMarginSize)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if centralManager.state == .poweredOn {
        }
    }
    
    func startScanning() -> Void {
        // Start Scanning
        let boldStop = UIImage(systemName: "stop.fill", withConfiguration: boldConfig)
        scanButton.setImage(boldStop, for: .normal)
        
        timer.invalidate()
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
        
        
        centralManager?.scanForPeripherals(withServices: [NUSCBUUID.BLEService_UUID], options: [CBCentralManagerScanOptionAllowDuplicatesKey : false])
        // Add Timer for this scan ~ 10 seconds
        Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {_ in
            self.stopScanning()
        }
    }
    
    func stopScanning() -> Void {
        print("stop scan")
        let boldPlay = UIImage(systemName: "play.fill", withConfiguration: boldConfig)
        scanButton.setImage(boldPlay, for: .normal)
        centralManager?.stopScan()
        
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        blePeripheral = peripheralArray[indexPath.row]
//        blePeripheral.connect()
//        self.performSegue(withIdentifier: "com.segue.console", sender: self)
//    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
}

extension CollectionViewController: UICollectionViewDataSource {
    
 
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return peripheralArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
       // cell.setData(text: self.dataArray[indexPath.row])
        
        let selectedPeripheral =  self.peripheralArray[indexPath.row]
        
        if selectedPeripheral != selectedPeripheral {
            cell.deviceName.text = selectedPeripheral.localName
        }else {
            cell.deviceName.text = selectedPeripheral.localName
        }
        
        cell.setupView(withPeripheral: selectedPeripheral)

        return cell
    }
    
}

extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = self.calculateWith()
        
        return CGSize(width: width, height: width + 20)
    
    }
    
    func calculateWith() -> CGFloat {
        let estimatedWidth = CGFloat(estimateWidth)
        let cellCount = floor(CGFloat(self.view.frame.size.width / estimatedWidth))
        
        let margin = CGFloat(cellMarginSize * 2)
        let width = (self.view.frame.size.width - CGFloat(cellMarginSize) * (cellCount - 1) - margin) / cellCount
        
        return width
    }
}

// MARK: - CBCentralManagerDelegate
extension CollectionViewController: CBCentralManagerDelegate {
    
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
        collectionView.reloadData()
        
        if peripheralArray.count == 1 {
            deviceLabel.text = "1 Device"
        } else {
            deviceLabel.text = "\(peripheralArray.count) Devices"
        }
        
        print(peripheralArray.count)
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
