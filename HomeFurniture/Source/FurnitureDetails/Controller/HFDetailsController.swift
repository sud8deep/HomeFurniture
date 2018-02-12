//
//  HFDetailsController.swift
//  HomeFurniture
//
//  Created by sudeep.r on 11/02/18.
//  Copyright © 2018 sudeep.r. All rights reserved.
//

import Foundation
import UIKit

enum HFDetailsVCType {
    case addNew
    case edit
    case invalid
}

protocol HFDetailsControllerDelegate {
    func hfDetailsController(sender: HFDetailsController,
                             updated furnitureInfo: FurnitureInfo)
}

class HFDetailsController: UIViewController {
    var detailsVCType: HFDetailsVCType = .invalid {
        didSet {
            if detailsVCType != .invalid {
                shouldUpdateView = true
            }
        }
    }
    var sourceType: UIImagePickerControllerSourceType = .camera
    var delegate: HFDetailsControllerDelegate?
    var furnitureInfo: FurnitureInfo?
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var titleTextField: UITextField!
    @IBOutlet private weak var detailsTextField: UITextField!
    
    private var image: UIImage? {
        didSet {
            guard let _ = image else {
                imageView.image = nil
                return
            }
            imageView.image = image
        }
    }
    private var imagePath: URL?
    private var shouldUpdateView = false
    
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
        if shouldUpdateView {
            shouldUpdateView = false
            
            switch detailsVCType {
            case .addNew:
                titleTextField.text = nil
                detailsTextField.text = nil
                image = nil
                imageView.image = nil
                presentPickerController(animated: true)
                break
            case .edit:
                guard let _ = furnitureInfo,
                    let _ = furnitureInfo?.title,
                    let _ = furnitureInfo?.imageData else {return}
                titleTextField.text = furnitureInfo?.title
                detailsTextField.text = furnitureInfo?.detail
                image = UIImage(data: (furnitureInfo?.imageData)!)
                break
            case .invalid:
                break
            }
        }
    }
    
    private func initialiseNavBar() {
        let backButton = UIBarButtonItem(title: "Back",
                                         style: .plain,
                                         target: self,
                                         action: #selector(HFDetailsController.backButtonClicked(sender:)))
        self.navigationItem.leftBarButtonItem = backButton
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
        backButtonClicked(sender: nil)
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
    
    @objc func backButtonClicked(sender: Any?) {
        furnitureInfo = nil
        titleTextField.text = nil
        detailsTextField.text = nil
        image = nil
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        titleTextField.resignFirstResponder()
        detailsTextField.resignFirstResponder()
        guard titleTextField.text?.isEmpty == false else {
            let alert = UIAlertController(title: AlertConstants.error,
                                          message: AlertConstants.enterTitle,
                                          preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let _ = image else {
            let alert = UIAlertController(title: AlertConstants.error,
                                          message: AlertConstants.noImage,
                                          preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            return
        }
        guard let imageData = UIImageJPEGRepresentation(image!, AppConstants.imageCompressionRatio) else {
            print("Failed to convert image")
            return
        }
        
        if detailsVCType != .edit
            && CoreDataHelper.shared().isPresent(furnitureWithTitle: titleTextField.text!) {
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
