//
//  ImagePickerViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
import MobileCoreServices

protocol ImagePickerDelegate: class {
    func imagePicker(_ imagePicker: ImagePickerViewController, didFinishUpload imageNumbers: [Int])
}

private enum Constant {
    static let cameraIndex = 0
}

class ImagePickerViewController: BaseViewController {
    fileprivate var viewModel: ImagePickerViewModel!
    @IBOutlet fileprivate weak var segmentedControl: UISegmentedControl!
    fileprivate var collectionView: UICollectionView!
    weak var delegate: ImagePickerDelegate?
    var pageURLPath: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "选择图片"
        segmentedControl.selectedSegmentIndex = ImageCompressType.original.rawValue
        segmentedControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: .selected)
        skinViewModel()
        skinCollectionView()
        NotificationCenter.default.addObserver(self, selector: #selector(didBecomeActive(_:)), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func didBecomeActive(_ notification: Notification) {
        viewModel.loadAssets()
        let allAssets = viewModel.getAssets()
        for asset in viewModel.imageAsstesCollection.getAssets() {
            if !allAssets.contains(asset) {
                viewModel.imageAsstesCollection.remove(asset)
            }
        }
        collectionView.reloadData()
    }
    
    override func configureApperance(of navigationBar: UINavigationBar) {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "确定", style: .plain, target: self, action: #selector(confirm))
        navigationBar.barTintColor = #colorLiteral(red: 0.1294117647, green: 0.137254902, blue: 0.1882352941, alpha: 1)
        navigationBar.isTranslucent = false
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()
        navigationBar.barStyle = .black
        navigationBar.titleTextAttributes = [ NSForegroundColorAttributeName: UIColor.white]
    }
    
    fileprivate func skinCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1.0
        layout.minimumInteritemSpacing = 0.5
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: (C.UI.screenWidth - 3.0) / 4.0, height: (C.UI.screenWidth - 3.0) / 4.0)
        
        collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: C.UI.screenWidth, height: C.UI.screenHeight - 113.0), collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(ImagePickerCollectionViewCell.self)
        collectionView.register(ImagePickerCameraCollectionViewCell.self)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        view.sendSubview(toBack: collectionView)
    }
    
    fileprivate func skinViewModel() {
        viewModel = ImagePickerViewModel()
        viewModel.pageURLPath = pageURLPath
        viewModel.loadAssets()
    }
    
    @IBAction func segmentedControllValueChanged(_ sender: UISegmentedControl) {
        viewModel.imageCompressType = ImageCompressType(rawValue: sender.selectedSegmentIndex) ?? .original
    }
    
    @IBAction func promptButtonPressed(_ sender: UIButton) {
        showMessage(title: "提示", message: "GIF图片不会压缩，原图上传")
    }
}

// MARK: - UICollectionViewDelegate

extension ImagePickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.row != Constant.cameraIndex else {
            camereCellPressed()
            return
        }
        let asset = viewModel.asset(at: indexPath.row)
        if asset.isDownloading {
            asset.cancelDownloading()
        } else if viewModel.imageAsstesCollection.has(asset) {
            viewModel.imageAsstesCollection.remove(asset)
        } else {
            asset.downloadAsset { [weak self, weak asset] result in
                guard let `self` = self, let asset = asset else { return }
                switch result {
                case .success(_):
                    self.viewModel.imageAsstesCollection.add(asset)
                case .failure(let error):
                    self.showPromptInformation(of: .failure(error.localizedDescription))
                }
            }
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ImagePickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        switch indexPath.row {
        case Constant.cameraIndex:
            let cameraCell = collectionView.dequeueReusableCell(for: indexPath) as ImagePickerCameraCollectionViewCell
            cameraCell.image = #imageLiteral(resourceName: "image_selector_camera")
            cell = cameraCell
        default:
            let imageCell = collectionView.dequeueReusableCell(for: indexPath) as ImagePickerCollectionViewCell
            imageCell.asset = viewModel.asset(at: indexPath.row)
            imageCell.assetsCollection = viewModel.imageAsstesCollection
            imageCell.imageView.contentMode = .scaleAspectFill
            imageCell.updateState()
            cell = imageCell
        }
        
        return cell
    }
}

// MARK: - Button Actions

extension ImagePickerViewController {
    func cancel() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func confirm() {
        showPromptInformation(of: .loading("正在上传..."))
        viewModel.uploadAssets { [weak self] result in
            guard let `self` = self else { return }
            self.hidePromptInformation()
            switch result {
            case let .success(imageNumbers):
                self.delegate?.imagePicker(self, didFinishUpload: imageNumbers)
                self.presentingViewController?.dismiss(animated: true, completion: nil)
            case let .failure(error):
                self.showPromptInformation(of: .failure(error.localizedDescription))
            }
        }
    }
    
    func camereCellPressed() {
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPromptInformation(of: .failure("摄像头不可用!"))
        } else {
            AVCaptureDevice.checkCameraPermission { [weak self] granted in
                if granted {
                    self?.showCameraPicker()
                } else {
                    self?.showPromptInformation(of: .failure("已拒绝相机的访问申请，请到设置中开启相机的访问权限！"))
                }
            }
        }
    }
    
    fileprivate func showCameraPicker() {
        let cameraPicker = UIImagePickerController()
        cameraPicker.sourceType = .camera
        cameraPicker.mediaTypes = [kUTTypeImage as String]
        cameraPicker.delegate = self
        present(cameraPicker, animated: true, completion: nil)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ImagePickerViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = (info[UIImagePickerControllerOriginalImage] as? UIImage)?.fixOrientation() {
            var localId: String?
            PHPhotoLibrary.shared().performChanges({
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                localId = request.placeholderForCreatedAsset?.localIdentifier
            }, completionHandler: { (success, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        self.showPromptInformation(of: .failure(error.localizedDescription))
                    } else if let localId = localId {
                        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localId], options: nil)
                        if let _ = result.objects(at: IndexSet(integersIn: 0..<result.count)).first {
                            self.viewModel.loadAssets()
                            self.collectionView.reloadData()
                            self.collectionView(self.collectionView, didSelectItemAt: IndexPath(row: 1, section: 0))
                        } else {
                            self.showPromptInformation(of: .failure("获取保存后的图片出错!"))
                        }
                    }
                }
            })
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UINavigationControllerDelegate

extension ImagePickerViewController: UINavigationControllerDelegate {
}

// MARK: - StoryboardLoadable

extension ImagePickerViewController: StoryboardLoadable { }
