//
//  CollectionViewController.swift
//  PyLeap
//
//  Created by Trevor Beaton on 5/3/21.
//

import UIKit


class CollectionViewController : UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let dataArray = ["AA","BB","CC","DD","EE"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
      //  self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UINib(nibName: "ItemCell", bundle: nil), forCellWithReuseIdentifier: "ItemCell")
    }
    
}

extension CollectionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        cell.setData(text: self.dataArray[indexPath.row])
        
        return cell
    }
    
}
