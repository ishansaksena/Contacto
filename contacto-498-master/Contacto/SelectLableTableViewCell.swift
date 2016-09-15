//
//  SelectLableTableViewCell.swift
//  Contacto
//
//  Created by Trevor Allen on 5/29/16.
//  Copyright © 2016 Trevor Allen. All rights reserved.
//

import UIKit

public class SelectLableTableViewCell: UITableViewCell {
    
    @IBOutlet var selectIcon: UIImageView!
    @IBOutlet var label: UILabel!
    public var isSelected : Bool?
    
    public override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected {
            selectIcon.image = UIImage(named: "selected.png")
        } else {
            selectIcon.image = UIImage(named: "unselected.png")
        }
    }
}
