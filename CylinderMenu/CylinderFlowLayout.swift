//
//  CylinderFlowLayout.swift
//  CylinderMenu
//
//  Created by NSSimpleApps on 24.04.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

import UIKit

class CylinderFlowLayout: UICollectionViewFlowLayout {
    
    var center: CGPoint = CGPoint.zero
    
    var radius: CGFloat = 0.0
    
    var numberOfCells: Int = 0
    
    var deleteIndexPaths: [IndexPath] = []
    var insertIndexPaths: [IndexPath] = []
    
    var initialAngle = CGFloat(0)
    
    override func prepare() {
        
        super.prepare()
        
        self.numberOfCells = self.collectionView!.numberOfItems(inSection: 0)
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        
        super.prepare(forCollectionViewUpdates: updateItems)
        
        for updateItem: UICollectionViewUpdateItem in updateItems {
            
            if updateItem.updateAction == .delete {
                
                self.deleteIndexPaths.append(updateItem.indexPathBeforeUpdate!)
                
            } else if updateItem.updateAction == .insert {
                
                self.insertIndexPaths.append(updateItem.indexPathAfterUpdate!)
            }
        }
    }
    
    override func finalizeCollectionViewUpdates() {
        
        super.finalizeCollectionViewUpdates()
        
        self.deleteIndexPaths = []
        self.insertIndexPaths = []
    }
    
    override var collectionViewContentSize : CGSize {
        
        return self.collectionView!.frame.size
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attribute.size = CGSize(width: 50, height: 50)
        
        let angle = self.initialAngle + CGFloat(2 * M_PI)*CGFloat((indexPath as NSIndexPath).item) / CGFloat(self.numberOfCells)

        attribute.center = CGPoint(x: self.center.x + self.radius*cos(angle), y: self.center.y + self.radius*sin(angle))
        return attribute
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var attributes: [UICollectionViewLayoutAttributes] = []
        
        for i in 0 ..< self.numberOfCells {
            
            let indexPath = IndexPath(item: i, section: 0)
            
            attributes.append(self.layoutAttributesForItem(at: indexPath))
        }
        return attributes
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attribute = self.layoutAttributesForItem(at: itemIndexPath)
        
        if self.insertIndexPaths.contains(itemIndexPath) {
            
            attribute.alpha = 0.0
            attribute.center = self.center
        }
        
        return attribute
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        let attribute = self.layoutAttributesForItem(at: itemIndexPath)
        
        if self.deleteIndexPaths.contains(itemIndexPath) {
            
            attribute.alpha = 0.0
            attribute.center = self.center
            attribute.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0)
        }
        return attribute
    }
}
