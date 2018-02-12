//
//  HomeViewController.swift
//  HomeFurniture
//
//  Created by sudeep.r on 11/02/18.
//  Copyright © 2018 sudeep.r. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet private weak var messageLabel: UILabel!
    
    private let numberOfItemsInARow = 2
    private let homeCellIdentifier = "HomeCollectionViewCell"
    private let hfDetailsVCIdentifier = "HFDetailsController"
    private var alertActionSheet: UIAlertController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        flowLayout.invalidateLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let _ = CoreDataHelper.shared().modelManager.furnitureInfoSet?.count else {
            messageLabel.isHidden = false
            return
        }
        messageLabel.isHidden = true
    }
    
    deinit {
        //Destroying and single instance here as it was created here
        CoreDataHelper.destroyInstance()
    }

    private func initialize() {
        initialiseNavBar()
        initializeActionSheet()
        registerCells()
    }
    
    private func initialiseNavBar() {
        let addBarButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add,
                                           target: self,
                                           action: #selector(HomeViewController.addButtonClicked(sender:)))
        self.navigationItem.rightBarButtonItem = addBarButton
    }
    
    private func pushHFDetailsViewController(detailsVCType: HFDetailsVCType,
                                             sourceType: UIImagePickerControllerSourceType?,
                                             furnitureInfo: FurnitureInfo?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let hfDetailsVC = (storyboard.instantiateViewController(
            withIdentifier: hfDetailsVCIdentifier) as? HFDetailsController) else {return}
        hfDetailsVC.delegate = self
        hfDetailsVC.detailsVCType = detailsVCType
        
        if furnitureInfo != nil {
            hfDetailsVC.furnitureInfo = furnitureInfo
        } else {
            hfDetailsVC.sourceType = sourceType == nil ? .camera : sourceType!
        }
        self.navigationController?.pushViewController(hfDetailsVC, animated: true)
    }
    
    private func initializeActionSheet() {
        alertActionSheet = UIAlertController(title: AlertConstants.addFurniture,
                                             message: AlertConstants.chooseImageFrom,
                                             preferredStyle: UIAlertControllerStyle.actionSheet)
        alertActionSheet?.addAction(UIAlertAction(title: AlertConstants.capturePhoto,
                                                  style: .default,
                                                  handler:
            { (action) in
                self.addFurniture(imageSource: .camera)
        }))
        
        alertActionSheet?.addAction(UIAlertAction(title: AlertConstants.photoLibrary,
                                                  style: .default,
                                                  handler:
            { (action) in
                self.addFurniture(imageSource: .photoLibrary)
        }))
        alertActionSheet?.addAction(UIAlertAction(title: AlertConstants.cancel, style: .cancel, handler: nil))
    }
    
    //MARK: Private methods
    private func registerCells() {
        collectionView.register(UINib(nibName: homeCellIdentifier,
                                      bundle: Bundle.main),
                                forCellWithReuseIdentifier: homeCellIdentifier)
    }
    
    @objc private func addButtonClicked(sender: UIBarButtonItem) {
        self.present(alertActionSheet!, animated: true, completion: nil)
    }
    
    private func addFurniture(imageSource: UIImagePickerControllerSourceType) {
        self.pushHFDetailsViewController(detailsVCType: .addNew,
                                         sourceType: imageSource,
                                         furnitureInfo: nil)
    }
    
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        guard let furnitureCount = CoreDataHelper.shared().modelManager?.furnitureInfoSet?.count else {
            return 0
        }
        return furnitureCount
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeCellIdentifier,
                                                      for: indexPath) as! HomeCollectionViewCell
        cell.info = CoreDataHelper.shared().modelManager?.furnitureInfoSet?.object(at: indexPath.row) as? FurnitureInfo
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let info = CoreDataHelper.shared().modelManager?.furnitureInfoSet?.object(at: indexPath.row)
            as? FurnitureInfo else {return}
        let alert = UIAlertController(title: info.title,
                                      message: info.detail,
                                      preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: AlertConstants.editFurniture,
                                      style: .default,
                                      handler:
            { (action) in
                self.pushHFDetailsViewController(detailsVCType: .edit,
                                                 sourceType: nil,
                                                 furnitureInfo: info)
        }))
        alert.addAction(UIAlertAction(title: AlertConstants.deleteFurniture,
                                      style: .default,
                                      handler:
            { (action) in
                CoreDataHelper.shared().removeFurniture(info: info)
                self.collectionView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: AlertConstants.cancel, style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension HomeViewController : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalAvailableWidth = collectionView.frame.width -
            (CGFloat(numberOfItemsInARow - 1) * flowLayout.minimumInteritemSpacing) -
            (flowLayout.sectionInset.left + flowLayout.sectionInset.right)
        let width = totalAvailableWidth / CGFloat(numberOfItemsInARow)
        let itemSize = CGSize(width: width, height: width * 1.3)
        return itemSize
    }
}

extension HomeViewController: HFDetailsControllerDelegate {
    func hfDetailsController(sender: HFDetailsController, updated furnitureInfo: FurnitureInfo) {
        collectionView.reloadData()
    }
}

