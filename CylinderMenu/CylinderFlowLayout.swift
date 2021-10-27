//
//  CylinderFlowLayout.swift
//  CylinderMenu
//
//  Created by NSSimpleApps on 24.04.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

import UIKit

class CylinderFlowLayout: UICollectionViewFlowLayout {
    var deleteIndexPaths: [IndexPath] = []
    var insertIndexPaths: [IndexPath] = []
    
    var initialAngle: CGFloat = 0
    
    var center: CGPoint {
        let bounds = self.collectionView?.bounds ?? .zero
        return CGPoint(x: bounds.midX, y: bounds.midY)
    }
    
    var radius: CGFloat = 0
    
    private var maxRadius: CGFloat {
        let bounds = self.collectionView?.bounds ?? .zero
        return min(bounds.midX, bounds.midY) * 0.8
    }
    
    func hideCells() {
        self.radius = 0
    }
    
    func showCells() {
        self.radius = self.maxRadius
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
        return self.collectionView?.bounds.size ?? .zero
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes {
        let numberOfCells = self.collectionView?.numberOfItems(inSection: 0) ?? 0
        let center = self.center
        let angle = self.initialAngle + 2 * CGFloat.pi*CGFloat(indexPath.item) / CGFloat(numberOfCells)
        
        let attribute = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attribute.size = self.itemSize
        attribute.center = CGPoint(x: center.x + self.radius*cos(angle), y: center.y + self.radius * sin(angle))
        
        return attribute
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: indexPath)
        attribute.size = self.headerReferenceSize
        attribute.center = self.center
        
        return attribute
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let layoutAttributes = super.layoutAttributesForElements(in: rect) {
            return layoutAttributes.compactMap({ (layoutAttribute) -> UICollectionViewLayoutAttributes? in
                let representedElementCategory = layoutAttribute.representedElementCategory
                let indexPath = layoutAttribute.indexPath
                
                if representedElementCategory == .cell {
                    return self.layoutAttributesForItem(at: indexPath)
                } else if representedElementCategory == .supplementaryView {
                    return self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath)
                } else {
                    return nil
                }
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
