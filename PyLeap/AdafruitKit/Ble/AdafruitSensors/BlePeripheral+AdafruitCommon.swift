//
//  BlePeripehral+AdafruitCommon.swift
//  BluefruitPlayground
//
//  Created by Antonio García on 13/11/2019.
//  Copyright © 2019 Adafruit. All rights reserved.
//

import Foundation
import CoreBluetooth

extension BlePeripheral {
    // Costants
    private static let kAdafruitMeasurementPeriodCharacteristicUUID = CBUUID(string: "ADAF0001-C332-42A8-93BD-25E905756CB8")
    private static let kAdafruitServiceVersionCharacteristicUUID = CBUUID(string: "ADAF0002-C332-42A8-93BD-25E905756CB8")

    private static let kAdafruitDefaultVersionValue = 1         // Used as default version value if version characteristic cannot be read

    static let kAdafruitSensorDefaultPeriod: TimeInterval = 0.2

    
    // MARK: - Errors
    enum PeripheralAdafruitError: Error {
        case invalidCharacteristic
        case enableNotifyFailed
        case disableNotifyFailed
        case unknownVersion
        case invalidResponseData
    }

    // MARK: - Service Actions
    func adafruitServiceEnable(serviceUuid: CBUUID, versionCharacteristicUUID: CBUUID = BlePeripheral.kAdafruitServiceVersionCharacteristicUUID, mainCharacteristicUuid: CBUUID, completion: ((Result<(Int, CBCharacteristic), Error>) -> Void)?) {

        self.characteristic(uuid: mainCharacteristicUuid, serviceUuid: serviceUuid) { [unowned self] (characteristic, error) in
            guard let characteristic = characteristic, error == nil else {
                completion?(.failure(error ?? PeripheralAdafruitError.invalidCharacteristic))
                return
            }

            // Check version
            self.adafruitVersion(serviceUuid: serviceUuid, versionCharacteristicUUID: versionCharacteristicUUID) { version in
                completion?(.success((version, characteristic)))
            }
        }
    }

    func adafruitServiceEnableIfVersion(version expectedVersion: Int, serviceUuid: CBUUID, versionCharacteristicUUID: CBUUID = BlePeripheral.kAdafruitServiceVersionCharacteristicUUID, mainCharacteristicUuid: CBUUID, completion: ((Result<CBCharacteristic, Error>) -> Void)?) {
        
        self.adafruitServiceEnable(serviceUuid: serviceUuid, versionCharacteristicUUID: versionCharacteristicUUID, mainCharacteristicUuid: mainCharacteristicUuid) { [weak self] result in
            self?.checkVersionResult(expectedVersion: expectedVersion, result: result, completion: completion)
        }
    }
    

    /**
            - parameters:
                - timePeriod: seconds between measurements. -1 to disable measurements

     */
    func adafruitServiceEnableIfVersion(version expectedVersion: Int, serviceUuid: CBUUID, mainCharacteristicUuid: CBUUID, timePeriod: TimeInterval?, responseHandler: @escaping(Result<(Data, UUID), Error>) -> Void, completion: ((Result<CBCharacteristic, Error>) -> Void)?) {
        
        adafruitServiceEnableIfVersion(version: expectedVersion, serviceUuid: serviceUuid, mainCharacteristicUuid: mainCharacteristicUuid) { [weak self] result in
            
            switch result {
            case let .success(characteristic):      // Version supported
                self?.adafruitServiceSetRepeatingResponse(characteristic: characteristic, timePeriod: timePeriod, responseHandler: responseHandler, completion: { result in
                    
                    completion?(.success(characteristic))
                })
                
            case let .failure(error):           // Unsupported version (or error)
                completion?(.failure(error))
            }
            
        }
    }
    
    private func adafruitServiceSetRepeatingResponse(characteristic: CBCharacteristic, timePeriod: TimeInterval?, responseHandler: @escaping(Result<(Data, UUID), Error>) -> Void, completion: ((Result<Void, Error>) -> Void)?) {
        
        // Time period
        if let timePeriod = timePeriod {    // Set timePeriod if not nil
            let serviceUuid = characteristic.service.uuid
            self.adafruitSetPeriod(timePeriod, serviceUuid: serviceUuid) { [weak self] _ in
                guard let self = self else { return }
                
                if AppEnvironment.isDebug {
                    // Check period
                    self.adafruitPeriod(serviceUuid: serviceUuid) { period in
                        guard period != nil else { DLog("Error setting service period"); return }
                        //DLog("service period: \(period!)")
                    }
                }
                
                self.adafruitServiceSetNotifyResponse(characteristic: characteristic, responseHandler: responseHandler, completion: completion)
            }
        } else {        // Use default timePeriod
            self.adafruitServiceSetNotifyResponse(characteristic: characteristic, responseHandler: responseHandler, completion: completion)
        }
    }
    
    func adafruitServiceSetNotifyResponse(characteristic: CBCharacteristic, responseHandler: @escaping(Result<(Data, UUID), Error>) -> Void, completion: ((Result<Void, Error>) -> Void)?) {

        // Prepare notification handler
        let notifyHandler: ((Error?) -> Void)? = { [unowned self] error in
            guard error == nil else {
                responseHandler(.failure(error!))
                return
            }
            
            if let data = characteristic.value {
                responseHandler(.success((data, self.identifier)))
            }
        }
        
        // Enable notifications
        if !characteristic.isNotifying {
            self.enableNotify(for: characteristic, handler: notifyHandler, completion: { error in
                guard error == nil else {
                    completion?(.failure(error!))
                    return
                }
                guard characteristic.isNotifying else {
                    completion?(.failure(PeripheralAdafruitError.enableNotifyFailed))
                    return
                }
                
                completion?(.success(()))
                
            })
        } else {
            self.updateNotifyHandler(for: characteristic, handler: notifyHandler)
            completion?(.success(()))
        }        
    }
    
    private func checkVersionResult(expectedVersion: Int, result: Result<(Int, CBCharacteristic), Error>, completion: ((Result<CBCharacteristic, Error>) -> Void)?) {
        switch result {
        case let .success((version, characteristic)):
            guard version == expectedVersion else {
                DLog("Warning: adafruitServiceEnableIfVersion unknown version: \(version). Expected: \(expectedVersion)")
                completion?(.failure(PeripheralAdafruitError.unknownVersion))
                return
            }
            
            completion?(.success(characteristic))
        case let .failure(error):
            completion?(.failure(error))
        }
    }
    
    func adafruitServiceDisable(serviceUuid: CBUUID, mainCharacteristicUuid: CBUUID, completion: ((Result<Void, Error>) -> Void)?) {
        self.characteristic(uuid: mainCharacteristicUuid, serviceUuid: serviceUuid) { [weak self] (characteristic, error) in
            guard let characteristic = characteristic, error == nil else {
                completion?(.failure(error ?? PeripheralAdafruitError.invalidCharacteristic))
                return
            }
            
            let kDisablePeriod: TimeInterval = -1       // -1 means taht the updates will be disabled
            self?.adafruitSetPeriod(kDisablePeriod, serviceUuid: serviceUuid) { [weak self] result in
                // Disable notifications
                if characteristic.isNotifying {
                    self?.disableNotify(for: characteristic) { error in
                        guard error == nil else {
                            completion?(.failure(error!))
                            return
                        }
                        guard !characteristic.isNotifying else {
                            completion?(.failure(PeripheralAdafruitError.disableNotifyFailed))
                            return
                        }
                        
                        completion?(.success(()))
                    }
                }
                else {
                    completion?(result)
                }
            }
        }
    }

    func adafruitVersion(serviceUuid: CBUUID, versionCharacteristicUUID: CBUUID,  completion: @escaping(Int) -> Void) {
        self.characteristic(uuid: versionCharacteristicUUID, serviceUuid: serviceUuid) { [weak self] (characteristic, error) in

            // Check if version characteristic exists or return default value
            guard error == nil, let characteristic = characteristic  else {
                completion(BlePeripheral.kAdafruitDefaultVersionValue)
                return
            }
            
            // Read the version
            self?.readCharacteristic(characteristic) { (result, error) in
                guard error == nil, let data = result as? Data, data.count >= 4 else {
                    completion(BlePeripheral.kAdafruitDefaultVersionValue)
                    return
                }
                
                let version = data.toIntFrom32Bits()
                completion(version)
            }
        }
    }

    func adafruitPeriod(serviceUuid: CBUUID, completion: @escaping(TimeInterval?) -> Void) {
        self.characteristic(uuid: BlePeripheral.kAdafruitMeasurementPeriodCharacteristicUUID, serviceUuid: serviceUuid) { (characteristic, error) in

            guard error == nil, let characteristic = characteristic else {
                completion(nil)
                return
            }

            self.readCharacteristic(characteristic) { (data, error) in
                guard error == nil, let data = data as? Data else {
                    completion(nil)
                    return
                }

                let period = TimeInterval(data.toIntFrom32Bits()) / 1000.0
                completion(period)
            }
        }
    }

    /**
        Set measurement period
             
        - parameters:
            - period: seconds between measurements. -1 to disable measurements

      */
    func adafruitSetPeriod(_ period: TimeInterval, serviceUuid: CBUUID, completion: ((Result<Void, Error>) -> Void)?) {

        self.characteristic(uuid: BlePeripheral.kAdafruitMeasurementPeriodCharacteristicUUID, serviceUuid: serviceUuid) { (characteristic, error) in

            guard error == nil, let characteristic = characteristic else {
                DLog("Error: adafruitSetPeriod: \(String(describing: error))")
                return
            }

            let periodMillis = period == -1 ? -1 : Int32(period * 1000)     // -1 means disable measurements. It is a special value
            let data = periodMillis.littleEndian.data
            self.write(data: data, for: characteristic, type: .withResponse) { error in
                guard error == nil else {
                    DLog("Error: adafruitSetPeriod \(error!)")
                    completion?(.failure(error!))
                    return
                }

                completion?(.success(()))
            }
        }
    }
    
    // MARK: - Utils
    func adafruitDataToFloatArray(_ data: Data) -> [Float]? {
        let unitSize = MemoryLayout<Float32>.stride
        var bytes = [Float32](repeating: 0, count: data.count / unitSize)
        (data as NSData).getBytes(&bytes, length: data.count * unitSize)
        
        return bytes
    }
    
    func adafruitDataToUInt16Array(_ data: Data) -> [UInt16]? {
        let unitSize = MemoryLayout<UInt16>.stride
        var words = [UInt16](repeating: 0, count: data.count / unitSize)
        (data as NSData).getBytes(&words, length: data.count * unitSize)
        return words
    }
    
    func adafruitDataToInt16Array(_ data: Data) -> [Int16]? {
        let unitSize = MemoryLayout<Int16>.stride
        var words = [Int16](repeating: 0, count: data.count / unitSize)
        (data as NSData).getBytes(&words, length: data.count * unitSize)
        return words
    }
}
