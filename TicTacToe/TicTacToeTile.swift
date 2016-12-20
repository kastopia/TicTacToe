//
//  TicTacToeTile.swift
//  TicTacToe
//
//  Created by Kihoon Kwon on 2016-12-19.
//  Copyright © 2016 Terry Kwon. All rights reserved.
//

import UIKit

class TicTacToeTile: UIButton {

    var row: Int = 0
    var column: Int = 0
    
    init(row: Int, column: Int) {
        super.init(frame: .zero)
        self.row = row
        self.column = column
        layer.cornerRadius = 3
        layer.borderWidth = 1.0 / UIScreen.main.scale
        
        setTitleColor(UIColor.black, for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
