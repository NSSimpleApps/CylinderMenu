//
//  CollectionViewController.swift
//  CylinderMenu
//
//  Created by NSSimpleApps on 24.04.15.
//  Copyright (c) 2015 NSSimpleApps. All rights reserved.
//

import UIKit

extension CGVector {
    
    func angle(_ v: CGVector) -> CGFloat {
        
        let dot = self.dx*v.dx + self.dy*self.dy
        let det = self.dx*v.dy - self.dy*v.dx
        
        let result = atan2(det, dot)
        
        if result.isNaN {
            
            return 0
        }
        return result
    }
}

class CollectionViewController: UICollectionViewController {

    fileprivate var array = [1, 2, 3, 4, 5, 6]
    
    fileprivate var radius: CGFloat = 0
    
    fileprivate var initialPoint = CGPoint.zero
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let itemSize = (self.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        let sizeOfCell = min(itemSize.width, itemSize.height)
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: sizeOfCell, height: sizeOfCell))
        button.center = self.collectionView!.center
        button.backgroundColor = UIColor.lightGray
        button.clipsToBounds = true
        button.layer.cornerRadius = sizeOfCell / 2.0
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1.0
        button.addTarget(self,
            action: #selector(CollectionViewController.showCells(_:)),
            for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        self.collectionView!.addSubview(button)
        
        let horizontalConstraint = button.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        let vertivalConstraint = button.centerYAnchor.constraint(equalTo: self.view.centerYAnchor)
        
        NSLayoutConstraint.activate([horizontalConstraint, vertivalConstraint])
        
        let size = self.collectionView!.frame.size
        
        self.radius = min(size.width, size.height) / 2.5
        
        if let collectionViewLayout = self.collectionView?.collectionViewLayout as? CylinderFlowLayout {
            
            collectionViewLayout.center = self.collectionView!.center
            collectionViewLayout.radius = 0
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func handleTapGesture(_ sender: UITapGestureRecognizer) {
        
        if let indexPath = self.collectionView?.indexPathForItem(at: sender.location(in: self.collectionView)) {
            
            self.collectionView!.performBatchUpdates({ () -> Void in
                
                self.array.remove(at: (indexPath as NSIndexPath).item)
                
                self.collectionView?.deleteItems(at: [indexPath])
                
                }, completion: nil)
        } else {
            
            self.collectionView!.performBatchUpdates({ () -> Void in
                
                self.array.append(self.array.last ?? 0)
                
                self.collectionView?.insertItems(at: [IndexPath(item: self.array.count - 1, section: 0)])
                
                }, completion: nil)
        }
        
    }
    
    @IBAction func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        
        if let collectionViewLayout = self.collectionView?.collectionViewLayout as? CylinderFlowLayout {
            
            if sender.state == .began {
                
                self.initialPoint = sender.location(in: sender.view)
                
            } else if sender.state == .changed {
                
                let center = sender.view?.center
                
                let initialVector = CGVector(dx: self.initialPoint.x - center!.x, dy: self.initialPoint.y - center!.y)
                
                let currentPoint = sender.location(in: sender.view)
                
                let currentVector = CGVector(dx: currentPoint.x - center!.x, dy: currentPoint.y - center!.y)
                
                let angle = initialVector.angle(currentVector)
                
                self.initialPoint = currentPoint
                    
                self.collectionView?.performBatchUpdates({ () -> Void in
                    
                    collectionViewLayout.initialAngle += angle
                    
                    }, completion: nil)
                
            } else if sender.state == .ended {
                
                let count = Int(collectionViewLayout.initialAngle/CGFloat(2*M_PI))
                
                collectionViewLayout.initialAngle -= CGFloat(count)*CGFloat(2*M_PI)
            }
        }
    }
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.array.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
    
        cell.backgroundColor = UIColor.lightGray
        cell.clipsToBounds = true
        cell.layer.cornerRadius = min(cell.bounds.width, cell.bounds.height) / 2.0
        cell.layer.borderColor = UIColor.black.cgColor
        cell.layer.borderWidth = 1.0
        
        if let label = cell.viewWithTag(101) as? UILabel {
            
            label.text = String(self.array[(indexPath as NSIndexPath).item])
        }
        return cell
    }
    
    internal func showCells(_ sender: UIButton) {
        
        if let collectionViewLayout = self.collectionView?.collectionViewLayout as? CylinderFlowLayout {
            
            self.collectionView?.performBatchUpdates({ () -> Void in
                    
                collectionViewLayout.radius = self.radius
                
                }, completion:  { (finished: Bool) -> Void in
                    
                    sender.removeTarget(self,
                        action: #function,
                        for: .touchUpInside)
                    sender.addTarget(self,
                        action: #selector(CollectionViewController.hideCells(_:)),
                        for: .touchUpInside)
            })
        }
    }
    
    internal func hideCells(_ sender: UIButton) {
        
        if let collectionViewLayout = self.collectionView?.collectionViewLayout as? CylinderFlowLayout {
            
            self.collectionView?.performBatchUpdates({ () -> Void in
                
                collectionViewLayout.radius = 0
                
                }, completion:  { (finished: Bool) -> Void in
                    
                    sender.removeTarget(self,
                        action: #function,
                        for: .touchUpInside)
                    sender.addTarget(self,
                        action: #selector(CollectionViewController.showCells(_:)),
                        for: .touchUpInside)
            })
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        self.radius = min(size.width, size.height) / 2.5
        
        if let collectionViewLayout = self.collectionView?.collectionViewLayout as? CylinderFlowLayout {
            
            collectionViewLayout.center = CGPoint(x: size.width/2, y: size.height/2)
            
            if collectionViewLayout.radius > 0 {
                
                self.collectionView?.performBatchUpdates({ () -> Void in
                    
                    collectionViewLayout.radius = self.radius
                    
                    }, completion: nil)
            }
        }
    }
}
