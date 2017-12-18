//
//  UIColorExtension.swift
//  Mokapp2017
//
//  Created by Daniele on 11/11/17.
//  Copyright © 2017 nexor. All rights reserved.
//

import UIKit

let UIColorList : [UIColor] = [
    UIColor.black,
    UIColor.white,
    UIColor.red,
    UIColor.blue,
    UIColor.yellow,
    UIColor.cyan,
    UIColor.green,
    UIColor.magenta,
    UIColor.orange,
    UIColor.purple,
]

extension UIColor {
    
    public static func random() -> UIColor {
        let maxValue = UIColorList.count
        let rand = Int(arc4random_uniform(UInt32(maxValue)))
        return UIColorList[rand]
    }
}
