//
//  ViewModelSearch.swift
//  ProjectX
//
//  Created by amir lahav on 13.12.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import RealmSwift

struct ViewModelSearch {
    
    
    func getTags(forText:String, complitionHandler:((SearchResult) ->()))
    {
        
        guard let realm = try? Realm() else { complitionHandler(SearchResult.error(error: RealmError.cantGetRealm))
            return }
        var searchSections = [SearchSection]()
        
        if forText != "" {
            
            
        ////// Get objects Tags //////
        
        let tagResualt = realm.objects(ObjectTag.self).filter("tag CONTAINS[c] '\(forText)'")
        if !tagResualt.isEmpty
        {
            let uniqueTag = Set(tagResualt.flatMap({ (tag) -> String in
                return tag.tag
            }))
            let objectTags = SearchSection(name: "Objects", tags: Array(uniqueTag), type: .object)
            searchSections.append(objectTags)
        }
        
        ////// Get country Tags //////
        
        
        let countryResult = realm.objects(Location.self).filter("country CONTAINS[c] '\(forText)'")
        if !countryResult.isEmpty{
            let uniqueCountry = Set(countryResult.flatMap({ (location) -> String? in
                return location.country
            }))
            let countryTags = SearchSection(name: "Country", tags: Array(uniqueCountry), type: .country)
            searchSections.append(countryTags)
        }

        
        ////// Get city Tags //////

        
        let cityResult = realm.objects(Location.self).filter("city CONTAINS[c] '\(forText)'")
        if !cityResult.isEmpty{
            let uniqueCity = Set(cityResult.flatMap({ (location) -> String? in
                return location.city
            }))
            let cityTags = SearchSection(name: "City", tags: Array(uniqueCity), type: .city)
            searchSections.append(cityTags)
        }
        
        
        ////// Get adress Tags //////

        
        let adressResult = realm.objects(Location.self).filter("adress CONTAINS[c] '\(forText)'")
        if !adressResult.isEmpty{
            let uniqueAdress = Set(adressResult.flatMap({ (uniqueAdress) -> String? in
                guard let address = uniqueAdress.adress else {return nil}
                return address
            }))
            let adressTags = SearchSection(name: "Adress", tags: Array(uniqueAdress), type: .adress)
            searchSections.append(adressTags)
        }
        
        ////// Get year Tags //////

        
        var dateResult = realm.objects(DateTag.self).filter("year.tag CONTAINS[c] '\(forText)'")
        if !dateResult.isEmpty{
            let uniqueYear = Set(dateResult.flatMap({ (date) -> String? in
                guard let year = date.year else {return nil}
                return year.tag
            }))
            let yearTags = SearchSection(name: "Years", tags: Array(uniqueYear), type: .year)
            searchSections.append(yearTags)
        }
        
        dateResult = realm.objects(DateTag.self).filter("month.tag CONTAINS[c] '\(forText)'")
        if !dateResult.isEmpty{
            let uniqueMonth = Set(dateResult.flatMap({ (date) -> String? in
                guard let month = date.month else {return nil}
                return month.tag
            }))
            let monthTags = SearchSection(name: "Months", tags: Array(uniqueMonth), type: .month)
            searchSections.append(monthTags)
        }
        }else{
        
        let searchManager = realm.objects(SearchManager.self).first
        if let tags = searchManager?.backingSearchedTags{
            if !tags.isEmpty{
                var tagsSet = Set<String>()
                for tag in tags{
                    tagsSet.insert(tag.tag)
                }
                let recentSearch = SearchSection(name: "Recent", tags: Array(tagsSet), type: .recent)
                searchSections.append(recentSearch)
            }
          }
        }
        
        complitionHandler(SearchResult.success(tags: searchSections))
        
    }
    
    func getAssets(tagName:String, sectionType:SearchSectionType)
    {
        guard let realm = try? Realm() else {  return  }
        guard let album = realm.objects(Album.self).filter("albumName == 'Search'").first else {
            return
        }
        do{
            try realm.write {
                album.sections.first?.assets.removeAll()
            }
        }catch let error{
            print(error.localizedDescription)
        }
        

        var result:[Asset]!
        switch sectionType {
            case .adress: result = Array(realm.objects(Asset.self).filter("location.adress = %@" ,tagName))
            case .city:  result = Array(realm.objects(Asset.self).filter("location.city = %@ ",tagName))
            case .country:  result = Array(realm.objects(Asset.self).filter("location.country = %@" ,tagName))
            case .month:  result = Array(realm.objects(Asset.self).filter("dateTags.month.tag = %@" ,tagName))
            case .year:  result = Array(realm.objects(Asset.self).filter("dateTags.year.tag = %@ " ,tagName))
            case .object : result = getAssetForObjects(forTag: tagName)
         default: break
        }
        if !result.isEmpty{
            AlbumMenagerHelper.add(assets: result, to: .search, name: "Search", collectionType: .searchCollection)
        }
    }
    
    
    
    func getAssetForObjects(forTag:String) -> [Asset]
    {
        var assets = [Asset]()
        guard let realm = try? Realm() else { return assets }
        let tags = realm.objects(ObjectTag.self).filter("tag = %@", forTag)
        if !tags.isEmpty
        {
            for tag in tags{
                let asset = tag.inObjectTags
                guard let firstAsset = asset.first else { continue }
                assets.append(firstAsset)
            }
        }
        return assets
    }
    
    
    
    func saveSearched(tag:String, type:SearchSectionType)
    {
        guard let realm = try? Realm() else {print("didnt find realm") ; return  }
        guard let searchManager = realm.objects(SearchManager.self).first else {print("didnt find search manger") ;  return  }
        if searchManager.backingSearchedTags.contains(where: {$0.tag == tag}) {print("have it") ; return}
        let newSearch = RecentSearchTag()
        newSearch.tag = tag
        newSearch.type = type
        do{
            try realm.write {
                realm.add(newSearch)
                searchManager.backingSearchedTags.append(newSearch)
                print(searchManager)
            }
        }catch let error{
            print(error.localizedDescription)
        }
    }
    
    func getOriginlTypeFor(tag:String) -> SearchSectionType?
    {
        guard let realm = try? Realm() else {print("didnt find realm") ; return nil  }
        let tag = realm.objects(RecentSearchTag.self).filter("tag = %@", tag)
        return tag.first?.type
        
        
    }
    
    
}


enum RealmError: Error {
    case cantGetRealm
}

enum SearchResult
{
    case success(tags:[SearchSection])
    case error(error:Error)
}

@objc enum SearchSectionType:Int
{
    case object
    case city
    case adress
    case country
    case year
    case month
    case recent
}

struct SearchSection {
    var name:String
    var tags:[String]
    var type:SearchSectionType
    
    init(name:String, tags:[String], type:SearchSectionType) {
        self.name = name
        self.tags = tags
        self.type = type
    }
}
