//
//  ImagePickerViewController.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/15.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import UIKit

class ImagePickerViewController: BaseViewController {
    fileprivate var viewModel: ImagePickerViewModel!
    @IBOutlet fileprivate weak var segmentedControl: UISegmentedControl!
    fileprivate var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "选择图片"
        segmentedControl.selectedSegmentIndex = ImageCompressType.original.rawValue
        skinViewModel()
        skinCollectionView()
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
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        view.sendSubview(toBack: collectionView)
    }
    
    fileprivate func skinViewModel() {
        viewModel = ImagePickerViewModel()
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
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
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
        let cell = collectionView.dequeueReusableCell(for: indexPath) as ImagePickerCollectionViewCell
        cell.asset = viewModel.asset(at: indexPath.row)
        
        return cell
    }
}

// MARK: - Button Actions

extension ImagePickerViewController {
    func cancel() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func confirm() {
        
    }
}

// MARK: - StoryboardLoadable

extension ImagePickerViewController: StoryboardLoadable { }
