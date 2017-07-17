//
//  CustomSegue.swift
//  PasswordManager
//
//  Created by Maor Shams on 07/07/2017.
//  Copyright © 2017 Maor Shams. All rights reserved.
//

import Cocoa

class CustomSegue: NSStoryboardSegue {
    override func perform() {
        if let fromViewController = sourceController as? NSViewController {
            if let toViewController = destinationController as? NSViewController {
                // no animation.
                fromViewController.view.window?.contentViewController = toViewController
            }
        }
    }
}
