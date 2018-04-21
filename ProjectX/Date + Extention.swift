//
//  Extention+Date.swift
//  hackaton
//
//  Created by amir lahav on 9.6.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation

extension Date {
    
    func interval(ofComponent comp: Calendar.Component, fromDate date: Date) -> Int {
        
        let currentCalendar = Calendar.current
        
        guard let start = currentCalendar.ordinality(of: comp, in: .era, for: date) else { return 0 }
        guard let end = currentCalendar.ordinality(of: comp, in: .era, for: self) else { return 0 }
        
        return end - start
    }
    
    
    static func dayCompere(lhs: Date, rhs: Date) -> Bool
    {
        let calendar = Calendar.current
        let lhsDateComp = calendar.dateComponents([.year, .month, .day], from: lhs)
        let rhsDateComp = calendar.dateComponents([.year, .month, .day], from: rhs)
        return lhsDateComp.year == rhsDateComp.year && lhsDateComp.month == rhsDateComp.month && lhsDateComp.day == rhsDateComp.day
    }
    
    static func monthCompere(lhs: Date, rhs: Date) -> Bool
    {
        let calendar = Calendar.current
        let lhsDateComp = calendar.dateComponents([.year, .month, .day], from: lhs)
        let rhsDateComp = calendar.dateComponents([.year, .month, .day], from: rhs)
        return lhsDateComp.year == rhsDateComp.year && lhsDateComp.month == rhsDateComp.month
    }
    
    static func yearCompere(lhs: Date, rhs: Date) -> Bool
    {
        let calendar = Calendar.current
        let lhsDateComp = calendar.dateComponents([.year, .month, .day], from: lhs)
        let rhsDateComp = calendar.dateComponents([.year, .month, .day], from: rhs)
        return lhsDateComp.year == rhsDateComp.year
    }
    

}
