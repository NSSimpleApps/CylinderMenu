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

class CollectionViewCell: UICollectionViewCell {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.clipsToBounds = false
        self.layer.masksToBounds = true
        self.contentView.backgroundColor = UIColor.lightGray
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        
        self.label.textAlignment = .center
        self.label.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(self.label)
        self.label.leftAnchor.constraint(equalTo: self.contentView.leftAnchor).isActive = true
        self.label.rightAnchor.constraint(equalTo: self.contentView.rightAnchor).isActive = true
        self.label.topAnchor.constraint(equalTo: self.contentView.topAnchor).isActive = true
        self.label.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CollectionViewHeader: UICollectionReusableView {
    let button = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.lightGray
        self.clipsToBounds = false
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 1.0
        
        self.button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.button)
        self.button.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.button.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        self.button.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        self.button.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CollectionViewController: UICollectionViewController {
    init(array: [Int]) {
        self.array = array
        
        let layout = CylinderFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.headerReferenceSize = layout.itemSize
        
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var array: [Int]
    private var initialPoint = CGPoint.zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        self.title = "CylinderMenu"
        
        guard let collectionView = self.collectionView else { return }
        
        collectionView.isScrollEnabled = false
        collectionView.backgroundColor = nil
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.register(CollectionViewHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: "CollectionViewHeader")
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self,
                                                                 action: #selector(self.handleAddAction(_:)))
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        collectionView.addGestureRecognizer(panGestureRecognizer)
    }

    @objc func handleAddAction(_ sender: UIBarButtonItem) {
        guard let collectionView = self.collectionView else { return }
        
        collectionView.performBatchUpdates({ () -> Void in
            self.array.append(self.array.count)
            collectionView.insertItems(at: [IndexPath(item: self.array.count - 1, section: 0)])
            
            }, completion: nil)
    }
    
    @objc func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if let collectionViewLayout = self.collectionViewLayout as? CylinderFlowLayout {
            if sender.state == .began {
                self.initialPoint = sender.location(in: sender.view)
                
            } else if sender.state == .changed {
                let center = collectionViewLayout.center
                let initialVector = CGVector(dx: self.initialPoint.x - center.x, dy: self.initialPoint.y - center.y)
                let currentPoint = sender.location(in: sender.view)
                let currentVector = CGVector(dx: currentPoint.x - center.x, dy: currentPoint.y - center.y)
                let angle = initialVector.angle(currentVector)
                self.initialPoint = currentPoint
                    
                self.collectionView?.performBatchUpdates({ () -> Void in
                    collectionViewLayout.initialAngle += angle
                    
                    }, completion: nil)
                
            } else if sender.state == .ended {
                let count = Int(collectionViewLayout.initialAngle/(2*CGFloat.pi))
                
                collectionViewLayout.initialAngle -= CGFloat(count) * (2*CGFloat.pi)
            }
        }
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.array.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        let size = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        cell.layer.cornerRadius = min(size.width, size.height) / 2.0
        cell.label.text = String(self.array[indexPath.item])
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.performBatchUpdates({ () -> Void in
            self.array.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
            
            }, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let cylinderFlowLayout = collectionView.collectionViewLayout as! CylinderFlowLayout
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CollectionViewHeader", for: indexPath) as! CollectionViewHeader
        let size = cylinderFlowLayout.headerReferenceSize
        header.layer.cornerRadius = min(size.width, size.height) / 2.0
        let button = header.button
        button.removeTarget(nil, action: nil, for: .allEvents)
        
        if cylinderFlowLayout.radius > 0 {
            button.addTarget(self, action: #selector(self.hideCells(_:)), for: .touchUpInside)
        } else {
            button.addTarget(self, action: #selector(self.showCells(_:)), for: .touchUpInside)
        }
        
        return header
    }
    
    @objc func showCells(_ sender: UIButton) {
        guard let collectionView = self.collectionView else { return }
        
        sender.removeTarget(nil, action: nil, for: .allEvents)
        sender.addTarget(self, action: #selector(self.hideCells(_:)), for: .touchUpInside)
        sender.isEnabled = false
        
        if let collectionViewLayout = collectionView.collectionViewLayout as? CylinderFlowLayout {
            collectionView.performBatchUpdates({ () -> Void in
                collectionViewLayout.showCells()
                
                }, completion:  { (finished: Bool) -> Void in
                    sender.isEnabled = true
            })
        }
    }
    
    @objc func hideCells(_ sender: UIButton) {
        guard let collectionView = self.collectionView else { return }
        
        sender.removeTarget(nil, action: nil, for: .allEvents)
        sender.addTarget(self, action: #selector(self.showCells(_:)), for: .touchUpInside)
        sender.isEnabled = false
        
        if let collectionViewLayout = collectionView.collectionViewLayout as? CylinderFlowLayout {
            collectionView.performBatchUpdates({ () -> Void in
                collectionViewLayout.hideCells()
                
                }, completion:  { (finished: Bool) -> Void in
                    sender.isEnabled = true
            })
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.collectionViewLayout.invalidateLayout()
        }, completion: nil)
    }
}
