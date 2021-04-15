//
//  BlePeripheral.swift
//  PyLeap
//
//  Created by Trevor Beaton For Adafruit Industries on 3/9/21.
//

import Foundation
import CoreBluetooth


class BlePeripheral: NSObject {
 static var connectedPeripheral: CBPeripheral?
 static var connectedService: CBService?
 static var connectedTXChar: CBCharacteristic?
 static var connectedRXChar: CBCharacteristic?

    static let readCharacteristic = "ADAF0100-4669-6C65-5472-616E73666572"
    static let writeCharacteristic = "ADAF0200-4669-6C65-5472-616E73666572"
    
     var featheruuid = CBUUID(string: "6e400002-b5a3-f393-e0a9-e50e24dcca9e")
    
    private let centralManager: CBCentralManager
    public  let basePeripheral: CBPeripheral
    
    public  var localName: String?
    public  var advertData: [String : Any]?
    public  var advertisement: Advertisement
    
    
    // MARK: - Characteristic properties
    
    public var txCharacteristic: CBCharacteristic?
    public var rxCharacteristic: CBCharacteristic?
    
    
    var identifier: UUID {
        return basePeripheral.identifier
    }

    var name: String? {
        return basePeripheral.name
    }

    var state: CBPeripheralState {
        return basePeripheral.state
    }
    
    public var isConnected: Bool {
        return basePeripheral.state == .connected
    }

    
    
    //MARK:- Advertisment
    
    struct Advertisement {
       
        var advertisementData: [String: Any]

        init(advertisementData: [String: Any]?) {
            self.advertisementData = advertisementData ?? [String: Any]()
        }

        // Advertisement data formatted
        var localName: String? {
            return advertisementData[CBAdvertisementDataLocalNameKey] as? String
        }
        
        var manufacturerData: Data? {
            return advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data
        }
        
        var manufacturerHexDescription: String? {
            guard let manufacturerData = manufacturerData else { return nil }
            return HexUtil.hexDescription(data: manufacturerData)
//            return String(data: manufacturerData, encoding: .utf8)
        }
        
        var manufacturerIdentifier: Data? {
            guard let manufacturerData = manufacturerData, manufacturerData.count >= 2 else { return nil }
            let manufacturerIdentifierData = manufacturerData[0..<2]
            return manufacturerIdentifierData
        }

        var services: [CBUUID]? {
            return advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
        }

        var servicesOverflow: [CBUUID]? {
            return advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] as? [CBUUID]
        }

        var servicesSolicited: [CBUUID]? {
            return advertisementData[CBAdvertisementDataSolicitedServiceUUIDsKey] as? [CBUUID]
        }
        
        var serviceData: [CBUUID: Data]? {
            return advertisementData[CBAdvertisementDataServiceDataKey] as? [CBUUID: Data]
        }

        var txPower: Int? {
            let number = advertisementData[CBAdvertisementDataTxPowerLevelKey] as? NSNumber
            return number?.intValue
        }

        var isConnectable: Bool? {
            let connectableNumber = advertisementData[CBAdvertisementDataIsConnectable] as? NSNumber
            return connectableNumber?.boolValue
        }
    }
    
    
    init(withPeripheral peripheral: CBPeripheral, advertisementData advertisementDictionary: [String : Any],with manager: CBCentralManager) {
    
    centralManager = manager
    basePeripheral = peripheral
    advertisement = Advertisement(advertisementData: advertisementDictionary)
        
    super.init()
    localName = parseAdvertisementData(advertisementDictionary)
    advertData = advertisementDictionary
    basePeripheral.delegate = self
    }
    
    /// Connects to the device.
    public func connect() {
        centralManager.delegate = self
        print("Connecting to Adafruit device...")
        centralManager.connect(basePeripheral, options: nil)
    }
    
    /// Cancels existing or pending connection.
    public func disconnect() {
        print("Cancel connection...")
        centralManager.cancelPeripheralConnection(basePeripheral)
    }
    
    private func parseAdvertisementData(_ advertisementDictionary: [String : Any]) -> String? {
        var localName: String

        if let name = advertisementDictionary[CBAdvertisementDataLocalNameKey] as? String{
            localName = name
        } else {
            localName = "\(name ?? "Unknown Device")"
        }
        
        return localName
    }
    
//    public func writeOutgoingValue(data: String){
//
//        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)
//
//        basePeripheral.writeValue(valueString!, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
//
//          }
      
    private func writeTxCharcateristic(withValue value: Data) {
        if let txCharacteristic = txCharacteristic {
            if txCharacteristic.properties.contains(.write) {
                print("Writing value (with response)...")
                basePeripheral.writeValue(value, for: txCharacteristic, type: .withResponse)
           
            } else if txCharacteristic.properties.contains(.writeWithoutResponse) {
                print("Writing value... (without response)")
                basePeripheral.writeValue(value, for: txCharacteristic, type: .withoutResponse)
                // peripheral(_:didWriteValueFor,error) will not be called after write without response
                // we are caling the delegate here
                
            } else {
                print("Characteristic is not writable")
            }
        }
    }
    
    // MARK: - Implementation
    
    
    private func discoverServices() {
        basePeripheral.delegate = self
        basePeripheral.discoverServices([])
    }
    
    /// A callback called when the Bluetooth characteristic value has changed.
    private func didReceiveButtonNotification(withValue value: Data) {
        print("Value changed: \(value[0])")
       // delegate?.buttonStateChanged(isPressed: value[0] == 0x1)
    }

    // Write functions
    public func writeOutgoingValue(data: String){
       print("Attempted to write")
        let valueString = (data as NSString).data(using: String.Encoding.utf8.rawValue)

        basePeripheral.writeValue(valueString!, for: txCharacteristic!, type: CBCharacteristicWriteType.withResponse)
            }
        
    
    
}

extension BlePeripheral: CBCentralManagerDelegate {
    // MARK: - Check
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

      switch central.state {
        case .poweredOff:
            print("Is Powered Off.")
        case .poweredOn:
            print("Is Powered On.")
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
   
    }

    // MARK: - Connect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if peripheral == basePeripheral {
            print("Connected to device")
            discoverServices()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
                                                               
    func centralManager(_ central: CBCentralManager, connectionEventDidOccur event: CBConnectionEvent, for peripheral: CBPeripheral) {
        
    }
    
}

extension BlePeripheral: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        if characteristic == txCharacteristic {
            if let value = characteristic.value{
                print("Tx Update Value: \(value)")
           
            } else if characteristic == rxCharacteristic {
                if let value = characteristic.value {
                print("Rx Update Value: \(value)")
                }
            }
            
        }
        
    
    
        
//      var characteristicASCIIValue = NSString()
//
//      guard characteristic == tempRxCharacteristic,
//
//            let characteristicValue = characteristic.value,
//            let ASCIIstring = NSString(data: characteristicValue, encoding: String.Encoding.utf8.rawValue) else { return }
//
//        characteristicASCIIValue = ASCIIstring
//
//      print("Value Recieved: \((characteristicASCIIValue as String))")
//
//      NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: "\((characteristicASCIIValue as String))")
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
        
        var currentIndex = 0
        
        //We need to discover the all characteristic
        for service in services {
            print("Service found: @index:\(currentIndex) - Service: \(service.description)")
            peripheral.discoverCharacteristics(nil, for: service)
            currentIndex += 1
        }
        
        print("Discovered Services: \(services.count)")
        print("Discovered Service UUID: \(services[0].uuid)")
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

               guard let characteristics = service.characteristics else {
              return
          }
        print(#function, #line)
          
        print("Found \(characteristics.count) characteristics.")
        print("Characteristic Count: \(characteristics.count) ")
        
        for element in characteristics {
            print("Characteristic: \(element.uuid)\n")
        }
        
        
        
        for characteristic in characteristics {

            
            if characteristic.properties.contains(.read){
                print("Read characteristic found: \(characteristic.uuid)")
            }
            if characteristic.properties.contains(.broadcast) {
                print("Broadcast characteristic found: \(characteristic.uuid)")
            }
            if characteristic.properties.contains(.write) {
                print("Write characteristic found: \(characteristic.uuid)")
            }
            if characteristic.uuid.isEqual(featheruuid)  {
               // print("Write without Response characteristic found: \(characteristic.uuid)")
                txCharacteristic = characteristic
                print("Write Characteristic Set: \(txCharacteristic?.description)")
            }
            
            peripheral.discoverDescriptors(for: characteristics[0])
//            if characteristic.uuid.isEqual(NUSCBUUID.BLE_Characteristic_uuid_Rx)  {
//
//                rxCharacteristic = characteristic
//
//              peripheral.setNotifyValue(true, for: rxCharacteristic!)
//              peripheral.readValue(for: characteristic)
//                print("RX Characteristic: \(rxCharacteristic)")
//                print("RX Characteristic UUID: \(rxCharacteristic?.uuid)")
//            }
//
//            if characteristic.uuid.isEqual(NUSCBUUID.BLE_Characteristic_uuid_Tx){
//
//              txCharacteristic = characteristic
//                print("RX Characteristic: \(rxCharacteristic)")
//                print("TX Characteristic UUID: \(txCharacteristic?.uuid)")
//
//
//            }

          }

    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?){
      
        guard let descriptors = characteristic.descriptors else {
       return
        }
//            guard let characteristics = service.characteristics else {
//           return
//       }
        print("Descriptors: \(descriptors.description)")
//            for descriptor in descriptors {
//                print("Descriptor: \(descriptor.description)\n")
//   }
        
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        // LED value has been written, let's read it to confirm.
       // readValue()
    }
    
    }
    

    



//    public func readValue() {
//        if let txCharacteristic = txCharacteristic {
//            if txCharacteristic.properties.contains(.read) {
//                print("Reading characteristic...")
//                basePeripheral.readValue(for: txCharacteristic)
//            } else {
//                print("Can't read state")
//
//            }
//        }
//    }
    
    

