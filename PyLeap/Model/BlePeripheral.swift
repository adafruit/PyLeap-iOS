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
    
    let filePath = "/hello.txt"
    let contents = "Hello World"
    
    var blePeripheralTransferMessage = ""
    
    // Write functions
    public func writeOutgoingValue(data: String){

       var newFilePath = filePath.data(using: .utf8)

        let offset = 0

        let lengthPath = newFilePath!.count
        let totalContentLength = contents.count
        var firstPacket = pack("<BxHII", [FileTransferCommand.Write,lengthPath,offset,totalContentLength])
        firstPacket.append(newFilePath!)
        blePeripheralTransferMessage = "\(hexlify(firstPacket))"
       
        print("Hexlify Sent: \(hexlify(firstPacket))")

        if basePeripheral.canSendWriteWithoutResponse || ((rxCharacteristic?.properties.contains(.writeWithoutResponse)) != nil) {
           basePeripheral.writeValue(firstPacket, for: rxCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
        }
        
    }
    
    var freeSpace = 11
    
    
    
    func secondWrite() {
        /*
        Command: Single byte. Always 0x21.
        Status: Single byte. 0x01 if OK. 0x02 if any parent directory is missing or a file.
        2 Bytes reserved for padding.
        
         Offset: 32-bit number encoding the starting offset to write. (Should match the offset from the previous 0x20 or 0x22 message)
        
         Free space: 32-bit number encoding the amount of data the client can send.
        */
        
        let offset = 0
        
        var secondPacket = pack("<BBxxII", [FileTransferCommand.WriteData,FileTransferCommand.OK,offset, freeSpace])
        
        
        
        if basePeripheral.canSendWriteWithoutResponse || ((rxCharacteristic?.properties.contains(.writeWithoutResponse)) != nil) {
        
        basePeripheral.writeValue(secondPacket, for: rxCharacteristic!, type: CBCharacteristicWriteType.withoutResponse)
        }
    }
    
    
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {

        var characteristicASCIIValue = NSString()

        guard characteristic == rxCharacteristic,
        
        let data = characteristic.value,
        let ASCIIstring = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return }
        
        characteristicASCIIValue = ASCIIstring
        
        //Unpack
        let a = try? unpack("<BBxxII", data)
        
        print("Unpacked: \(a)")
        
        //freeSpace = a?.last
        
        print("Free Space: \(freeSpace)")
        
        print("Value Recieved: \(data)\n")

        print("Hexlify Recieved: \(hexlify(data))\n")
        
       
        
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
    

    
    func peripheral(_ peripheral: CBPeripheral,
    didUpdateNotificationStateFor characteristic: CBCharacteristic,
    error: Error?) {

        if let error = error {
           print("Characteristic update notification error: \(error.localizedDescription)")
           return
         }

         // Ensure this characteristic is the one we configured
         guard characteristic.uuid == featherReadUUID else { return }

         // Check if it is successfully set as notifying
         if characteristic.isNotifying {
           print("Characteristic notifications have begun.")
         } else {
           print("Characteristic notifications have stopped. Disconnecting.")
           centralManager.cancelPeripheralConnection(peripheral)
         }

         // Send any info to the peripheral from the central
      
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
        print("Found \(characteristics.count) characteristics.\n")
        
        for element in characteristics {
            print("Characteristic: \(element.uuid)\n")
        }

        for characteristic in characteristics {

            if characteristic.uuid.isEqual(featherWriteUUID) {

                txCharacteristic = characteristic
                print("Write Characteristic Set: \(characteristic.uuid)")
            }
           
            if characteristic.uuid.isEqual(featherReadUUID) {
             
                    rxCharacteristic = characteristic
                    print("Read Characteristic Set: \(characteristic.uuid)")
                    print("#:\(self.basePeripheral.maximumWriteValueLength(for: .withoutResponse))")
                    basePeripheral.setNotifyValue(true, for: rxCharacteristic!)
                    basePeripheral.readValue(for: rxCharacteristic!)
               
            }
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
}
    

