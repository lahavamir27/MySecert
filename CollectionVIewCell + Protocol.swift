//
//  CollectionVIewCell + Protocol.swift
//  ProjectX
//
//  Created by amir lahav on 26.9.2017.
//  Copyright © 2017 LA Computers. All rights reserved.
//

import Foundation
import  UIKit

protocol ReusableView: class {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return NSStringFromClass(self)
    }
}

protocol NibLoadableView: class {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
}

extension UITableViewCell:ReusableView
{
    
}
extension UITableView
{
    func register<T: UITableViewCell>(_: T.Type)  {
            register(T.self, forCellReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UITableViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            return UITableViewCell.init(style: .subtitle, reuseIdentifier: T.defaultReuseIdentifier) as! T
        }
        return cell
    }
}


extension UICollectionView {
    
    func register<T: UICollectionViewCell>(_: T.Type)  {
        register(T.self, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func register<T: UICollectionViewCell>(_: T.Type) where  T: NibLoadableView {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        register(nib, forCellWithReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func register<T: UICollectionReusableView>(_: T.Type, forSupplementaryViewOfKind: String) where  T: NibLoadableView
    {
        let bundle = Bundle(for: T.self)
        let nib = UINib(nibName: T.nibName, bundle: bundle)
        
        register(nib, forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: T.defaultReuseIdentifier)
    }
    
    func dequeueReusableCell<T: UICollectionViewCell>(forIndexPath indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        return cell
    }
    
    func dequeueReusableSupplementaryView<T: UICollectionReusableView>(kind: String, indexPath: IndexPath) -> T where  T: NibLoadableView {
        
        guard let cell = dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: T.defaultReuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.defaultReuseIdentifier)")
        }
        
        return cell
    }
    
    func selectAll(animated: Bool) {
        (0..<numberOfSections).flatMap { (section) -> [IndexPath]? in
            return (0..<numberOfItems(inSection: section)).flatMap({ (item) -> IndexPath? in
                return IndexPath(item: item, section: section)
            })
            }.flatMap { $0 }.forEach { (indexPath) in
                selectItem(at: indexPath, animated: animated, scrollPosition: [])
        }
    }
    
    func selectAllItems(inSection:Int, animated:Bool)
    {
        ([inSection]).flatMap { (section) -> [IndexPath]? in
            return (0..<numberOfItems(inSection: section)).flatMap({ (item) -> IndexPath? in
                return IndexPath(item: item, section: section)
            })
            }.flatMap { $0 }.forEach { (indexPath) in
                selectItem(at: indexPath, animated: animated, scrollPosition: [])
        }
    }
    
    func deselectAllItems(inSection:Int, animated:Bool)
    {
        ([inSection]).flatMap { (section) -> [IndexPath]? in
            return (0..<numberOfItems(inSection: section)).flatMap({ (item) -> IndexPath? in
                return IndexPath(item: item, section: section)
            })
            }.flatMap { $0 }.forEach { (indexPath) in
                if (cellForItem(at: indexPath)?.isSelected)!{
                    deselectItem(at: indexPath, animated: animated)
                }
        }
    }
    /// Deselects all selected cells.
    func deselectAll(animated: Bool) {
        indexPathsForSelectedItems?.forEach({ (indexPath) in
            deselectItem(at: indexPath, animated: animated)
        })
    }
    
    enum CollectionViewType {
        case filteredImages
        case colorPicker
    }
}

extension UICollectionViewCell {}
extension UICollectionReusableView:ReusableView{}
