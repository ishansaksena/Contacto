//
//  Presets.swift
//  Contacto
//
//  Created by Annie Lace on 5/19/16.
//  Copyright © 2016 Trevor Allen. All rights reserved.
//

import Foundation

var presets : [PresetData] = [PresetData(name : "School", shareSettings : [true, false, true]), PresetData(name : "Friend", shareSettings : [true, true, true])]

class PresetData
{
    var name : String
    var shareSettings : [Bool]
    
    init(name : String, shareSettings : [Bool])
    {
        self.name = name
        self.shareSettings = shareSettings
    }
}
