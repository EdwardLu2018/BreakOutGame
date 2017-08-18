//
//  Brick.swift
//  BreakOut
//
//  Created by Edward Lu on 7/28/16.
//  Copyright © 2016 Edward Lu. All rights reserved.
//

import UIKit

class Brick: UIView {
    
    var originalColor = UIColor.black
    
    init(frame: CGRect, originalColor: UIColor) {
        super.init(frame: frame)
        self.commonInit(originalColor)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit(_ originalColor: UIColor) {
        self.originalColor = originalColor
    }
    
}
