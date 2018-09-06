//
//  ViewController.swift
//  TestBLEController
//
//  Created by Gene Backlin on 9/3/18.
//  Copyright © 2018 Gene Backlin. All rights reserved.
//

import UIKit
import BLEController
import CoreBluetooth

class ViewController: UIViewController {
    @IBOutlet weak var identifierLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    var bleController: BLEController?
    var blePeripherals: [String : CBPeripheral] = [String : CBPeripheral]()
    var selectedPeripheral: CBPeripheral?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        identifierLabel.text = "Scanning for devices..."
        nameLabel.text = ""
        stateLabel.text = ""
        connectButton.isHidden = true

        bleController = BLEController(delegate: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - @IBAction methods
    
    @IBAction func connect(_ sender: UIButton) {
        let alertController = UIAlertController(title: nameLabel.text, message: nil, preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let OKAction = UIAlertAction(title: "Connect", style: .default) {[weak self] action in
            DispatchQueue.main.async {
                print("connecting...")
                self!.textView.text = ""
                self!.stateLabel.text = "connecting..."
            }
            self!.bleController?.connect(selectedPeripheral: self!.selectedPeripheral!)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        
        present(alertController, animated: true, completion: nil)

    }
}

extension ViewController: BLEControllerDelegate {
    
    func didFindPeripherals(peripherals: [String : CBPeripheral]) {
        //print("didFindPeripherals: \(peripherals)")
        if blePeripherals.count < 1 {
            identifierLabel.text = ""
            
        }

        blePeripherals = peripherals
        tableView.reloadData()
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
        
        for characteristic in service.characteristics! {            
            if characteristic.properties.contains(.read) {
                textView.textStorage.append(NSAttributedString(string: "\(characteristic.uuid): prop contains .read\n"))
                peripheral.readValue(for: characteristic)
            }
            if characteristic.properties.contains(.notify) {
                textView.textStorage.append(NSAttributedString(string: "\(characteristic.uuid): prop contains .notify\n"))
            }
            if characteristic.properties.contains(.broadcast) {
                textView.textStorage.append(NSAttributedString(string: "\(characteristic.uuid): prop contains .broadcast\n"))
            }
            if characteristic.properties.contains(.write) {
                textView.textStorage.append(NSAttributedString(string: "\(characteristic.uuid): prop contains .write\n"))
            }
            if characteristic.properties.contains(.writeWithoutResponse) {
                textView.textStorage.append(NSAttributedString(string: "\(characteristic.uuid): prop contains .writeWithoutResponse\n"))
            }
            if characteristic.properties.contains(.indicate) {
                textView.textStorage.append(NSAttributedString(string: "\(characteristic.uuid): prop contains .indicate\n"))
            }
            if characteristic.properties.contains(.authenticatedSignedWrites) {
                textView.textStorage.append(NSAttributedString(string: "\(characteristic.uuid): prop contains .authenticatedSignedWrites\n"))
            }
            if characteristic.properties.contains(.extendedProperties) {
                textView.textStorage.append(NSAttributedString(string: "\(characteristic.uuid): prop contains .extendedProperties\n"))
            }
            if characteristic.properties.contains(.notifyEncryptionRequired) {
                textView.textStorage.append(NSAttributedString(string: "\(characteristic.uuid): prop contains .notifyEncryptionRequired\n"))
            }
            if characteristic.properties.contains(.indicateEncryptionRequired) {
                textView.textStorage.append(NSAttributedString(string: "\(characteristic.uuid): prop contains .indicateEncryptionRequired\n"))
            }
        }
        
    }
    
    func peripheralDidUpdateCharacteristicValue(peripheral: CBPeripheral, characteristic: CBCharacteristic) {
        print("peripheralDidUpdateCharacteristicValue: \(peripheral) characteristic: \(characteristic)")
        let uuid = "\(characteristic.uuid)"
        if let value: Data = characteristic.value {
            if let stringValue = String(data: value, encoding: String.Encoding.utf8) {
                textView.textStorage.append(NSAttributedString(string: "char: \(String(describing: uuid)) - value: [\(stringValue)] "))
            } else {
                textView.textStorage.append(NSAttributedString(string: "char: \(uuid) - value: no value "))
            }
        } else {
            textView.textStorage.append(NSAttributedString(string: "char: \(uuid) - value: no value "))
        }
        
        textView.textStorage.append(NSAttributedString(string: "\n"))
        
        let lastLine = NSMakeRange(textView.text.count - 1, 1)
        textView.scrollRangeToVisible(lastLine)

    }
    
    func didFailWithError(error: Error?) {
        print("didFailWithError: \(String(describing: error))")
    }
    
    
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blePeripherals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let keys = Array(blePeripherals.keys).sorted()
        let key = keys[indexPath.row]
        let peripheral: CBPeripheral = blePeripherals[key]!
        
        // Configure the cell...
        cell.textLabel?.text = "\(String(describing: peripheral.name!))"
        cell.detailTextLabel?.text = "\(peripheral.identifier)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Discovered Peripherals"
    }
    
}

// MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let keys = Array(blePeripherals.keys).sorted()
        let key = keys[indexPath.row]
        selectedPeripheral = blePeripherals[key]!
        
        identifierLabel.text = "\(selectedPeripheral!.identifier)"
        nameLabel.text = "\(String(describing: selectedPeripheral!.name!))"
        stateLabel.text = bleController!.currentState
        connectButton.isHidden = false
    }
}
