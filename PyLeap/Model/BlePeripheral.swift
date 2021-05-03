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

    static let readCharacteristic = CBUUID(string: "ADAF1200-4669-6C65-5461-6E7366657221")
    static let writeCharacteristic = CBUUID(string: "ADAF0200-4669-6C65-5461-6E7366657221")
    // MARK:- UUID Characteritics
    var featherWriteUUID = CBUUID(string: "ADAF0100-4669-6C65-5472-616E73666572")
    var featherReadUUID = CBUUID(string: "ADAF0200-4669-6C65-5472-616E73666572")
    
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
    
    
    
    public func connect() {
        centralManager.delegate = self
        print("Connecting to Adafruit device...")
        centralManager.connect(basePeripheral, options: nil)
    }
    
    public func disconnect() {
        print("Cancel connection...")
        centralManager.cancelPeripheralConnection(basePeripheral)
    }
    
    private func discoverServices() {
        basePeripheral.delegate = self
        basePeripheral.discoverServices([])
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

    // Location  CIRCUITPY\ 1/code.py 
    func stringToBytes(_ string: String) -> [UInt8]? {
        let length = string.count
        if length & 1 != 0 {
            return nil
        }
        var bytes = [UInt8]()
        bytes.reserveCapacity(length/2)
        var index = string.startIndex
        for _ in 0..<length/2 {
            let nextIndex = string.index(index, offsetBy: 2)
            if let b = UInt8(string[index..<nextIndex], radix: 16) {
                bytes.append(b)
            } else {
                return nil
            }
            index = nextIndex
        }
        return bytes
    }
    

    
    // Write functions
    public func writeOutgoingValue(data: String){
        let filePath = "/hello.txt"
        let contents = "Hello World"
        
        
       var newFilePath = filePath.data(using: .utf8)
       
        // Command: Single byte. Always 0x20.
       // 1 Byte reserved for padding.
       // Path length: 16-bit number encoding the encoded length of the path string.
       // Offset: 32-bit number encoding the starting offset to write.
        let offset = 0
       // Total size: 32-bit number encoding the total length of the file contents.
       // Path: UTF-8 encoded string that is not null terminated. (We send the length instead.)
        
        let lengthPath = newFilePath!.count
        let totalContentLength = contents.count
        print(lengthPath)
        
        var d = pack("<BxHII", [FileTransferCommand.Write,lengthPath,offset, totalContentLength])
        d.append(newFilePath!)
        
        print("hexlify: \(hexlify(d))")

        if basePeripheral.canSendWriteWithoutResponse || ((rxCharacteristic?.properties.contains(.writeWithoutResponse)) != nil) {
            print(basePeripheral.canSendWriteWithoutResponse)
          
           basePeripheral.writeValue(d, for: rxCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
        }
        
        
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
            print("Connected to Adafruit Device.")
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
    
    func discoverDescriptors(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        basePeripheral.discoverDescriptors(for: rxCharacteristic!)
    }

    // In CBPeripheralDelegate class/extension
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        guard let descriptors = characteristic.descriptors else { return }
     
        // Get user description descriptor
        if let userDescriptionDescriptor = descriptors.first(where: {
            return $0.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString
        }) {
            // Read user description for characteristic
            basePeripheral.readValue(for: userDescriptionDescriptor)
        }
    }
     
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        // Get and print user description for a given characteristic
        if descriptor.uuid.uuidString == CBUUIDCharacteristicUserDescriptionString,
            let userDescription = descriptor.value as? String {
            print("Characterstic \(descriptor.characteristic.uuid.uuidString) is also known as \(userDescription)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        var characteristicASCIIValue = NSString()

        guard characteristic == rxCharacteristic,
        let readValueCharacteristic = characteristic.value,
        
        let ASCIIstring = NSString(data: readValueCharacteristic, encoding: String.Encoding.utf8.rawValue) else { return }
        
        
        characteristicASCIIValue = ASCIIstring

        print("Value Recieved:\((characteristicASCIIValue as String))\n\n")

        print("Hexlify Recieved: \(hexlify(readValueCharacteristic))")
        
        print("printing characteristic value:\(hexlify(characteristic.value!))\n\n")
        
        
        
        NotificationCenter.default.post(name:NSNotification.Name(rawValue: "Notify"), object: "\((characteristicASCIIValue as String))")
        
        
        
//        if characteristic == txCharacteristic {
//            if let value = characteristic.value{
//                print("Tx Update Value: \(value)")
//
//            } else if characteristic == rxCharacteristic {
//                if let value = characteristic.value {
//                print("Rx Update Value: \(value)")
//                }
//            }
//
//        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
    error: Error?) {
        
        print("didUpdateNotificationStateForCharacteristic:\(characteristic)")
      
    }
    

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        print("*******************************************************")

        if ((error) != nil) {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }
        guard let services = basePeripheral.services else {
            return
        }
        
        var currentIndex = 0
        
        //We need to discover the all characteristic
        for service in services {
            print("Service found: @index:\(currentIndex) - Service: \(service.description)\n")
            basePeripheral.discoverCharacteristics(nil, for: service)
            currentIndex += 1
        }
        
        print("Discovered Services: \(services.count)\n")
        print("Discovered Service UUID: \(services[0].uuid)\n")
        
    }
    //MARK:- didDiscoverCharacteristicsFor
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

               guard let characteristics = service.characteristics else {
              return
          }
        print(#function, #line, "------------------------------\n")
          
        print("Found \(characteristics.count) characteristics.\n")
        
        for element in characteristics {
            print("Characteristic: \(element.uuid)\n")
        }
        //
//        print("Found \(characteristics.count) characteristics.")
//
//        for characteristic in characteristics {
//
//          if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Rx)  {
//
//            rxCharacteristic = characteristic
//
//            BlePeripheral.connectedRXChar = rxCharacteristic
//
//            peripheral.setNotifyValue(true, for: rxCharacteristic!)
//            peripheral.readValue(for: characteristic)
//
//            print("RX Characteristic: \(rxCharacteristic.uuid)")
//          }
//
//          if characteristic.uuid.isEqual(CBUUIDs.BLE_Characteristic_uuid_Tx){
//            txCharacteristic = characteristic
//            BlePeripheral.connectedTXChar = txCharacteristic
//            print("TX Characteristic: \(txCharacteristic.uuid)")
//          }
//
        
        
        for characteristic in characteristics {
print("Loop")
            if characteristic.uuid.isEqual(featherWriteUUID) {
               // print("Write without Response characteristic found: \(characteristic.uuid)")
                txCharacteristic = characteristic
                
                print("Write Characteristic Set: \(characteristic.uuid)\n\n")

            }
           
            if characteristic.uuid.isEqual(featherReadUUID) {
               // print("Write without Response characteristic found: \(characteristic.uuid)")
             
                    rxCharacteristic = characteristic
                    print("Read Characteristic Set: \(characteristic.uuid)\n\n")
                    print("#:\(self.basePeripheral.maximumWriteValueLength(for: .withoutResponse))")
                    basePeripheral.setNotifyValue(true, for: rxCharacteristic!)
                    basePeripheral.readValue(for: rxCharacteristic!)
                
               
            }
           
            
           // peripheral.discoverDescriptors(for: characteristics[0])
            basePeripheral.discoverDescriptors(for: characteristics[1])
            

          }

    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {

            if let error = error {
                print(error)
            } else {
                print("Value writen sucessfully.")
            }
        }
    
    func write(value: Data, characteristic: CBCharacteristic) {
        if basePeripheral.canSendWriteWithoutResponse {
           basePeripheral.writeValue(value, for: characteristic, type: .withoutResponse)
        }
    }
    

}
    

