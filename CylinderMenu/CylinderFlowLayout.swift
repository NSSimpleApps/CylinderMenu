//
//  CylinderFlowLayout.swift
//  CylinderMenu
//
//  Created by NSSimpleApps on 24.04.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

import UIKit

class CylinderFlowLayout: UICollectionViewFlowLayout {
    
    var numberOfCells: Int = 0
    
    var deleteIndexPaths: [IndexPath] = []
    var insertIndexPaths: [IndexPath] = []
    
    var initialAngle: CGFloat = 0
    
    var center: CGPoint {
        
        let bounds = self.collectionView?.bounds.size ?? .zero
        
        return CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    private var radius: CGFloat = 0
    
    private var maxRadius: CGFloat {
        
        let bounds = self.collectionView?.bounds.size ?? .zero
        
        return min(bounds.width, bounds.height) / 2.5
    }
    
    func hideCells() {
        
        self.radius = 0
    }
    
    func showCells() {
        
        self.radius = self.maxRadius
    }
    
    override func prepare() {
        
        super.prepare()
        
        self.numberOfCells = self.collectionView?.numberOfItems(inSection: 0) ?? 0
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        
        super.prepare(forCollectionViewUpdates: updateItems)
        
        for updateItem in updateItems {
            
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
        
        return self.collectionView!.bounds.size
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attribute.size = CGSize(width: 50, height: 50)
        
        let angle = self.initialAngle + 2 * CGFloat.pi*CGFloat(indexPath.item) / CGFloat(self.numberOfCells)
        
        attribute.center = CGPoint(x: self.center.x + self.radius*cos(angle), y: self.center.y + self.radius*sin(angle))
        
        return attribute
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        if let layoutAttributes = super.layoutAttributesForElements(in: rect) {
            
            return layoutAttributes.map({ (layoutAttribute) -> UICollectionViewLayoutAttributes in
                
                let indexPath = layoutAttribute.indexPath
                
                return self.layoutAttributesForItem(at: indexPath)
            })
            
        } else {
            
            return nil
        }
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        if let initialLayoutAttributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath) {
            
            if self.insertIndexPaths.contains(itemIndexPath) {
                
                initialLayoutAttributes.alpha = 0.0
                initialLayoutAttributes.center = self.center
            }
            
            return initialLayoutAttributes
            
        } else {
            
            return nil
        }
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        if let finalLayoutAttributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath) {
            
            if self.deleteIndexPaths.contains(itemIndexPath) {
                
                finalLayoutAttributes.alpha = 0.0
                finalLayoutAttributes.center = self.center
                finalLayoutAttributes.transform3D = CATransform3DMakeScale(0.1, 0.1, 1.0)
            }
            
            return finalLayoutAttributes
            
        } else {
            
            return nil
        }        
    }
}
