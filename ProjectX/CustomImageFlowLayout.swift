//
//  CustomImageFlowLayout.swift
//  Photo Gallery
//
//  Created by amir lahav on 1.10.2016.
//  Copyright © 2016 LA Computers. All rights reserved.
//

import UIKit


protocol CustomImageFlowLayoutProtocol {
    func pinnedSection(at:IndexPath)
    func notPinnedSection(at:IndexPath)
}

class CustomImageFlowLayout: UICollectionViewFlowLayout {
    
    
    var delegate:CustomImageFlowLayoutProtocol?
    var barHeight: CGFloat!
    var isPortrait: Bool {
        let orientation = UIDevice.current.orientation
        switch orientation {
        case .portrait:
            return true
            
        case .faceUp, .faceDown, .portraitUpsideDown:
            // Check the interface orientation
            let interfaceOrientation = UIApplication.shared.statusBarOrientation
            switch interfaceOrientation{
            case .portrait:
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
    
    override init() {
        super.init()
    }
    
    convenience init(withHeader header: Bool = true)
    {
        self.init()
        setupLayout(withHeader: header)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout(withHeader: true)
    }
    
    override var itemSize: CGSize
        {
        set {}
        get{
            let pedding:CGFloat = 1.0
            var row:CGFloat!
            var numOfColumns: CGFloat {
                

                if isPortrait { return 4.0 } else {return 7.0}


            }
            let itemWidth = ((self.collectionView!.frame.width - (numOfColumns - 1) * pedding) / numOfColumns)
            return CGSize(width: itemWidth, height: itemWidth)
        }
    }
    
    func setupLayout(withHeader header:Bool) {
        minimumInteritemSpacing = 1.0
        minimumLineSpacing = 1.0
        scrollDirection = .vertical
        sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let layoutAttributes = super.layoutAttributesForElements(in: rect) else { return nil }
        
        // Helpers
        let sectionsToAdd = NSMutableIndexSet()
        var newLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        for layoutAttributesSet in layoutAttributes {
            if layoutAttributesSet.representedElementCategory == .cell {
                // Add Layout Attributes
                newLayoutAttributes.append(layoutAttributesSet)
                
                // Update Sections to Add
                sectionsToAdd.add(layoutAttributesSet.indexPath.section)
                
            } else if layoutAttributesSet.representedElementCategory == .supplementaryView {
                // Update Sections to Add
                sectionsToAdd.add(layoutAttributesSet.indexPath.section)
            }
        }
        
        for section in sectionsToAdd {
            let indexPath = IndexPath(item: 0, section: section)
            
            if let sectionAttributes = self.layoutAttributesForSupplementaryView(ofKind: UICollectionElementKindSectionHeader, at: indexPath) {
                newLayoutAttributes.append(sectionAttributes)
            }
        }
        
        return newLayoutAttributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let layoutAttributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) else { return nil }

        guard let boundaries = boundaries(forSection: indexPath.section) else { return layoutAttributes }
        guard let collectionView = collectionView else { return layoutAttributes }
        
        // Helpers
        let contentOffsetY = collectionView.contentOffset.y
        var frameForSupplementaryView = layoutAttributes.frame
        
        let minimum = boundaries.minimum - frameForSupplementaryView.height
        let maximum = boundaries.maximum - frameForSupplementaryView.height
        
        switch UIDevice.current.orientation {
        case .landscapeLeft, .landscapeRight, .portraitUpsideDown:
            barHeight = 32
        case .portrait,.faceDown,.faceUp, .unknown:
            barHeight = 64
        }
        
        if isPortrait { barHeight = 64 } else {barHeight =  32}

        
        
        if contentOffsetY < minimum - barHeight {
            frameForSupplementaryView.origin.y = minimum
            delegate?.notPinnedSection(at: indexPath)

        } else if contentOffsetY > maximum - barHeight {
            frameForSupplementaryView.origin.y = maximum
            delegate?.pinnedSection(at: indexPath)

//            print("contentOffsetY: \(contentOffsetY) > maximum \(maximum - barHeight), \(frameForSupplementaryView.origin.y), \(indexPath)")

        } else {
            frameForSupplementaryView.origin.y = contentOffsetY + barHeight
            delegate?.pinnedSection(at: indexPath)
//            print("\(maximum), \(minimum), \(frameForSupplementaryView.origin.y), \(indexPath)")
        }
        
        layoutAttributes.frame = frameForSupplementaryView
        
        return layoutAttributes
    }
    
    // MARK: - Helper Methods
    
    func boundaries(forSection section: Int) -> (minimum: CGFloat, maximum: CGFloat)? {
        // Helpers
        var result = (minimum: CGFloat(0.0), maximum: CGFloat(0.0))
        
        // Exit Early
        guard let collectionView = collectionView else { return result }
        
        // Fetch Number of Items for Section
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        // Exit Early
        guard numberOfItems > 0 else { return result }
        
        if let firstItem = layoutAttributesForItem(at: IndexPath(item: 0, section: section)),
            let lastItem = layoutAttributesForItem(at: IndexPath(item: (numberOfItems - 1), section: section)) {
            result.minimum = firstItem.frame.minY
            result.maximum = lastItem.frame.maxY
            
            // Take Header Size Into Account
            result.minimum -= headerReferenceSize.height
            result.maximum -= headerReferenceSize.height
            
            // Take Section Inset Into Account
            result.minimum -= sectionInset.top
            result.maximum += (sectionInset.top + sectionInset.bottom)
        }
        
        return result
    }



}
