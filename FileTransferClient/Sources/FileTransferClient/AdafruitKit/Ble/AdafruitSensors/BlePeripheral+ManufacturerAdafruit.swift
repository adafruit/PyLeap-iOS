//
//  BlePeripheral+ManufacturerAdafruit.swift
//  BluefruitPlayground
//
//  Created by Antonio García on 10/12/2019.
//  Copyright © 2019 Adafruit. All rights reserved.
//

import UIKit
import CoreBluetooth

extension BlePeripheral {
    // Constants
    internal static let kManufacturerAdafruitIdentifier: [UInt8] = [0x22, 0x08]

    // MARK: - Check Manufacturer
    public func isManufacturerAdafruit() -> Bool {
        guard let manufacturerIdentifier = advertisement.manufacturerIdentifier else { return false }

        let manufacturerIdentifierBytes = [UInt8](manufacturerIdentifier)
        //DLog("\(name) manufacturer: \(advertisement.manufacturerString)")
        return manufacturerIdentifierBytes == BlePeripheral.kManufacturerAdafruitIdentifier
    }
    
    
    /*
    // MARK: - Adafruit Specific Data
    struct AdafruitManufacturerData {
        // Types
        enum BoardModel: CaseIterable {
            case circuitPlaygroundBluefruit
            case clue_nRF52840
            case feather_nRF52840_express
            case feather_nRF52832
            
            var identifier: [[UInt8]] {  // Board identifiers used on the advertisement packet (USB PID)
                switch self {
                case .circuitPlaygroundBluefruit: return [[0x45, 0x80], [0x46, 0x80]]
                case .clue_nRF52840: return [[0x71, 0x80], [0x72, 0x80]]
                case .feather_nRF52840_express: return [[0x29, 0x80], [0x2A, 0x80]]
                case .feather_nRF52832: return [[0x60, 0xEA]]
                }
            }
            
            var neoPixelsCount: Int {
                switch self {
                case .circuitPlaygroundBluefruit: return 10
                case .clue_nRF52840: return 1
                case .feather_nRF52840_express: return 0
                case .feather_nRF52832: return 0
                }
            }
        }
        
        // Data
        var color: UIColor?
        var boardModel: BoardModel?
        
        // Utils
        static func board(withBoardTypeData data: Data) -> BoardModel? {
            let bytes = [UInt8](data)
            
            let board = BoardModel.allCases.first(where: {
                $0.identifier.contains(bytes)
            })

            return board
        }
       
    }
    
    func adafruitManufacturerData() -> AdafruitManufacturerData? {
        guard let manufacturerData = advertisement.manufacturerData else { return nil }
        guard manufacturerData.count > 2 else { return nil }        // It should have fields beyond the manufacturer identifier
        
        var manufacturerFieldsData = Data(manufacturerData.dropFirst(2))  // Remove manufacturer identifier
        
        var adafruitManufacturerData = AdafruitManufacturerData()
        
        // Parse fields
        let kHeaderLength =  1 + 2      // 1 byte len + 2 bytes key
        while manufacturerFieldsData.count >= kHeaderLength {
            // Parse current field
            guard let fieldKey = Int16(data: manufacturerFieldsData[1...2]) else { return nil }
            let fieldDataLenght = Int(manufacturerFieldsData[0]) - kHeaderLength    // don't count header
            let fieldData: Data
            if manufacturerFieldsData.count >= kHeaderLength + fieldDataLenght {
                fieldData = Data(manufacturerFieldsData[kHeaderLength...])
            } else {
                fieldData = Data()
            }
            
            // Decode field
            switch fieldKey {
            case 0 where fieldData.count >= 3:     // Color
                let r = fieldData[0]
                let g = fieldData[1]
                let b = fieldData[2]
                adafruitManufacturerData.color = UIColor(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
                
            case 1 where fieldData.count >= 2:     // Board type
                let boardTypeData = fieldData[0..<2]
                
                if let board = AdafruitManufacturerData.board(withBoardTypeData: boardTypeData) {
                    adafruitManufacturerData.boardModel = board
                }
                else {
                    DLog("Warning: unknown board type found: \([UInt8](boardTypeData))")
                }
                
            default:
                DLog("Error processing manufacturer data with key: \(fieldKey) len: \(fieldData.count) expectedLen: \(fieldDataLenght)")
                break
            }
            
            // Remove processed field
            manufacturerFieldsData = Data(manufacturerFieldsData.dropFirst(3 + fieldDataLenght))
        }
        
        return adafruitManufacturerData
    }
 */
}
