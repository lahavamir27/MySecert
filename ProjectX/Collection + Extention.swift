//
//  Collection + Extention.swift
//  ProjectX
//
//  Created by amir lahav on 25.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation


extension Collection{
    
    /// Returns the element at the specified index iff it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Generator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
    
    
}
