//
//  InterfaceController.swift
//  TestBLEWatch Extension
//
//  Created by Gene Backlin on 9/3/18.
//  Copyright © 2018 Gene Backlin. All rights reserved.
//

import WatchKit
import Foundation
import BLEControllerWatch
import CoreBluetooth


class InterfaceController: WKInterfaceController {
    @IBOutlet var tableView: WKInterfaceTable!

    var bleController: BLEController?
    var blePeripherals: [String : CBPeripheral] = [String : CBPeripheral]()
    var selectedPeripheral: CBPeripheral?

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        setTitle("Peripherals")
        bleController = BLEController(delegate: self)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func setupTable() {
        if blePeripherals.count > 0 {
            tableView.setNumberOfRows(blePeripherals.count, withRowType: "WatchCell")
            let keys = Array(blePeripherals.keys).sorted()
            
            for i in 0...keys.count-1 {
                if let row = tableView.rowController(at: i) as? TableViewRow {
                    let key = keys[i]
                    let peripheral: CBPeripheral = blePeripherals[key]!
                    
                    row.cellTextLabel.setText("\(String(describing: peripheral.name!))")
                }
            }
        } else {
            tableView.setNumberOfRows(1, withRowType: "WatchCell")
            if let row = tableView.rowController(at: 0) as? TableViewRow {
                row.cellTextLabel.setText("No BLE devices found")
            }
        }
    }

    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        if blePeripherals.count > 0 {
            let keys = Array(blePeripherals.keys).sorted()
            let key = keys[rowIndex]
            let peripheral: CBPeripheral = blePeripherals[key]!
            
            self.pushController(withName: "showDetails", context: peripheral)
        }
    }

}

// MARK: - BLEControllerDelegate

extension InterfaceController: BLEControllerDelegate {
    func didFindPeripherals(peripherals: [String : CBPeripheral]) {
        print("didFindPeripherals: \(peripherals)")
        blePeripherals.removeAll()
        blePeripherals = peripherals
        setupTable()
    }
    
    func didDisconnectPeripheral(peripheral: CBPeripheral, error: Error?) {
        print("didDisconnectPeripheral: \(peripheral)")
    }
    
    func didConnectPeripheral(peripheral: CBPeripheral) {
        print("didConnectPeripheral: \(peripheral)")
        peripheral.discoverServices(nil)
    }
    
    func didDiscoverCharacteristics(peripheral: CBPeripheral, service: CBService) {
        print("didDiscoverCharacteristics: \(service.characteristics!)")
    }
    
    func peripheralDidUpdateCharacteristicValue(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        print("peripheralDidUpdateCharacteristicValue: \(peripheral) characteristic: \(characteristic)")
    }
    
    func didFailWithError(error: Error?) {
        print("didFailWithError: \(String(describing: error))")
    }
    
}
