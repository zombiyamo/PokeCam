//
//  extension.swift
//  PokeCam
//
//  Created by miyamo on 2016/07/22.
//  Copyright © 2016年 Zombiyamo. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    func toImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()
        CGContextTranslateCTM(context, 0.0, 0.0)
        self.layer.renderInContext(context!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
}
