//
//  DetailInterfaceController.swift
//  SimpleTableViewWatch Extension
//
//  Created by Backlin,Gene on 8/29/18.
//  Copyright © 2018 Chamberlain. All rights reserved.
//

import WatchKit
import Foundation
import CoreBluetooth


class DetailInterfaceController: WKInterfaceController {
    @IBOutlet var textLabel1: WKInterfaceLabel!
    @IBOutlet var textLabel2: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
        setTitle("Details")
        let peripheral: CBPeripheral = context as! CBPeripheral
        textLabel1.setText(peripheral.name)
        textLabel2.setText("\(peripheral.identifier)")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
