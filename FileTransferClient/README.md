# FileTransferClient

## Introduction

Swift API for [Adafruit CircuitPython BLE File Transfer protocol](https://github.com/adafruit/Adafruit_CircuitPython_BLE_File_Transfer)

This BLE service is geared towards file transfer to and from a device running the service. A core part of the protocol is free space responses so that the server can be a memory limited device. The free space responses allow for small buffer sizes that won't be overwhelmed by the client.


## Installing

TODO: Add Swift Package Manager Support


## Usage

1. Create an FileTransferClient object from a connected CBPeripheral

        FileTransferClient(connectedCBPeripheral: CBPeripheral, services: [BoardService]? = nil, completion: @escaping (Result<Void, Error>) -> Void)

    Parameters: 
        
        - connectedCBPeripheral: standard CoreBluetooth peripheral. It should be connected.
        - services: a list of services to detect and setup. Currenlty only .fileTransfer is available but more services and sensors could be added. 
        - completion: a completion handler. It returns .success if the board is ready to accept commands, or an .failure with an error if the board setup failed

    It will automatically check the the peripheral supports a valid version of the FileTransfer protocol and setup the board to accept commands


2. Use any of the available commands:

- **readFile**: Given a full path, returns the full contents of the file

        func readFile(path: String, progress: ProgressHandler? = nil, completion: ((Result<Data, Error>) -> Void)?)
        
    completion is called with  *.success* and the binary *Data* of the file or *.failure* with an *Error*
        progress is called with the transmission status *typealias ProgressHandler = ((_ transmittedBytes: Int, _ totalBytes: Int) -> Void)*

- **writeFile**: Writes the content to the given full path. If the file exists, it will be overwritten.

        func writeFile(path: String, data: Data, progress: ProgressHandler? = nil, completion: ((Result<Date?, Error>) -> Void)?)
        
    completion is called with *.success* wjith the modification Date or *.failure* with an *Error*
        progress is called with the transmission status *typealias ProgressHandler = ((_ transmittedBytes: Int, _ totalBytes: Int) -> Void)*

- **deleteFile**: Deletes the file or directory at the given full path. Directories must be empty to be deleted.

        func deleteFile(path: String, completion: ((Result<Void, Error>) -> Void)?)

    completion is called with *.success* or *.failure* with an *Error*


- **makeDirectory**: Creates a new directory at the given full path. If a parent directory does not exist, then it will also be created. If any name conflicts with an existing file, an error will be returned

        func makeDirectory(path: String, completion: ((Result<Date?, Error>) -> Void)?)

    completion is called with *.success* with the modification Date or *.failure* with an *Error*


- **listDirectory**: Lists all of the contents in a directory given a full path. Returned paths are relative to the given path to reduce duplication

        func listDirectory(path: String, completion: ((Result<[BlePeripheral.DirectoryEntry]?, Error>) -> Void)?)
        
    
    completion is called with *.success* with a list of directory entries or *.failure* with an *Error*


    A DirectoryEntry is a struct with the name of the file and the type: .file with a size in bytes or .directory
    
        struct DirectoryEntry {
            enum EntryType {
                case file(size: Int)
                case directory
            }
        
            let type: EntryType
            let name: String
        }



## Examples

TODO: Create example

