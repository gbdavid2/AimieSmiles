//
//  ChemData.swift
//  AimieSmiles
//
//  Created by David Garces on 09/10/2017.
//  Copyright © 2017 David Garces. All rights reserved.
//

import Cocoa

class ChemData: NSObject {
      @objc var name: String
      @objc var cas: String
      @objc var smiles: String

    init(name: String, cas: String) {
        self.name = name
        self.cas = cas
        self.smiles = ""
        super.init()
    }
    
}

extension ChemData {
    override public var description: String {
        return "Name: \(String(describing: self.name)), cas: \(self.cas), smiles: \(self.smiles)"
    }
}


extension String {
    func removingWhitespaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
}
