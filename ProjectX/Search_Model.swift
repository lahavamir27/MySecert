//
//  Search_Model.swift
//  ProjectX
//
//  Created by amir lahav on 14.12.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift

class RecentSearchTag : Object {
    
    dynamic var tag = ""
    dynamic var type:SearchSectionType = .recent
}

class SearchManager : Object {

    var backingSearchedTags = List<RecentSearchTag>()

}

class ObjectTag: Object {
    dynamic var tag:String = ""
    let inObjectTags = LinkingObjects(fromType: Asset.self, property: "objectTags")
    
    override static func indexedProperties() -> [String] {
        return ["tag"]
    }
}

class albumTag:Object
{
    
}

class DateTag: Object
{
    dynamic var year:YearTag? = nil
    dynamic var month:MonthTag? = nil
}

class YearTag: Object {
    dynamic var tag:String = ""
}

class MonthTag: Object {
    dynamic var tag:String = ""
}
