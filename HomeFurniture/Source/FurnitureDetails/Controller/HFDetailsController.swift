//
//  HFDetailsController.swift
//  HomeFurniture
//
//  Created by sudeep.r on 11/02/18.
//  Copyright © 2018 sudeep.r. All rights reserved.
//

import Foundation
import UIKit

protocol HFDetailsControllerDelegate {
    func hfDetailsController(sender: HFDetailsController,
                             updated furnitureInfo: FurnitureInfo)
}

class HFDetailsController: UIViewController {
    var isNewEntry = false
    var sourceType: UIImagePickerControllerSourceType = .camera
    var delegate: HFDetailsControllerDelegate?
    var furnitureInfo: FurnitureInfo?
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var detailsTextField: UITextField!
    
    private var image: UIImage? {
        didSet {
            guard let _ = image else {return}
            imageView.image = image
        }
    }
    private var imagePath: URL?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(HFDetailsController.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(HFDetailsController.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        initialiseNavBar()
        initialiseView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Furniture Info"
        if isNewEntry {
            isNewEntry = false
            titleTextField.text = nil
            detailsTextField.text = nil
            image = nil
            imageView.image = nil
            presentPickerController(animated: true)
        } else if furnitureInfo != nil {
            guard let title = furnitureInfo?.title,
                let imageData = furnitureInfo?.imageData else {return}
            titleTextField.text = title
            image = UIImage(data: imageData)
            detailsTextField.text = (furnitureInfo?.detail?.isEmpty)! ? "" : furnitureInfo?.detail
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func initialiseNavBar() {
        //        let backButton = UIBarButtonItem(title: "Back", style: .done, target: nil, action: nil)
        self.navigationItem.backBarButtonItem?.title = "Back"
    }
    
    private func initialiseView() {
        titleTextField.delegate = self
        detailsTextField.delegate = self
    }
    
    private func resetViewContent() {
        titleTextField.text = nil
        detailsTextField.text = nil
        image = nil
        imageView.image = nil
    }
    
    private func addFurniture(title: String, imageData: Data, detail: String?) {
        let trimmedTitle = title.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if let _ = furnitureInfo {
            furnitureInfo?.title = trimmedTitle
            furnitureInfo?.imageData = imageData
            furnitureInfo?.detail = detail
            CoreDataHelper.saveContext()
        } else {
            self.furnitureInfo = CoreDataHelper.shared().addFurnitureInfo(title: trimmedTitle,
                                                                          details: detail,
                                                                          imageData: imageData)
        }
        delegate?.hfDetailsController(sender: self, updated: furnitureInfo!)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func presentPickerController(animated: Bool) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            let alert = UIAlertController(title: AlertConstants.error,
                                          message: AlertConstants.noCameraOnDevice,
                                          preferredStyle: .alert)
            alert.show(self, sender: nil)
            return
        }
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = self.sourceType
        self.present(picker, animated: animated, completion: nil)
    }
    
    private func handleDuplicateEntry(imageData: Data) {
        let alertActionSheet = UIAlertController(title: AlertConstants.warning,
                                                 message: AlertConstants.furnitureWithThisTitleExists,
                                                 preferredStyle: UIAlertControllerStyle.actionSheet)
        alertActionSheet.addAction(UIAlertAction(title: AlertConstants.addDuplicate,
                                                 style: .default,
                                                 handler:
            { (action) in
                self.addFurniture(title: self.titleTextField.text!,
                                  imageData: imageData,
                                  detail: self.detailsTextField.text)
        }))
        alertActionSheet.addAction(UIAlertAction(title: AlertConstants.replace,
                                                 style: .default,
                                                 handler:
            { (action) in
                CoreDataHelper.shared().removeAllFurnitureWithTitle(title: self.titleTextField.text!)
                self.addFurniture(title: self.titleTextField.text!,
                                  imageData: imageData,
                                  detail: self.detailsTextField.text)
        }))
        alertActionSheet.addAction(UIAlertAction(title: AlertConstants.cancel, style: .cancel, handler: nil))
        self.present(alertActionSheet, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        titleTextField.resignFirstResponder()
        detailsTextField.resignFirstResponder()
        guard titleTextField.text?.isEmpty == false else {
            let alert = UIAlertController(title: AlertConstants.error,
                                          message: AlertConstants.enterTitle,
                                          preferredStyle: .alert)
            alert.show(self, sender: nil)
            return
        }
        guard let _ = image else {
            let alert = UIAlertController(title: AlertConstants.error,
                                          message: AlertConstants.noImage,
                                          preferredStyle: .alert)
            alert.show(self, sender: nil)
            return
        }
        guard let imageData = UIImageJPEGRepresentation(image!, 0.5) else {
            print("Failed to convert image")
            return
        }
        
        if CoreDataHelper.shared().isPresent(furnitureWithTitle: titleTextField.text!) {
            handleDuplicateEntry(imageData: imageData)
            return
        }
        addFurniture(title: self.titleTextField.text!,
                     imageData: imageData,
                     detail: self.detailsTextField.text)
    }
    

    @IBAction func editImageButtonClicked(_ sender: Any) {
        let alertActionSheet = UIAlertController(title: AlertConstants.editFurnitureImage,
                                             message: AlertConstants.chooseImageFrom,
                                             preferredStyle: UIAlertControllerStyle.actionSheet)
        alertActionSheet.addAction(UIAlertAction(title: AlertConstants.capturePhoto,
                                                  style: .default,
                                                  handler:
            { (action) in
                self.sourceType = .camera
                self.presentPickerController(animated: true)
        }))
        
        alertActionSheet.addAction(UIAlertAction(title: AlertConstants.photoLibrary,
                                                  style: .default,
                                                  handler:
            { (action) in
                self.sourceType = .photoLibrary
                self.presentPickerController(animated: true)
        }))
        alertActionSheet.addAction(UIAlertAction(title: AlertConstants.cancel, style: .cancel, handler: nil))
        self.present(alertActionSheet, animated: true, completion: nil)
    }
}

extension HFDetailsController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage else {return}
        image = editedImage
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

extension HFDetailsController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
