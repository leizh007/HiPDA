//
//  ImagePickerViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

/// 图片压缩大小
///
/// - twoHundredKB: ~200KB
/// - fourHundredKB: ~400KB
/// - eightHundredKB: ~800KB
/// - original: 原图
enum ImageCompressType: Int {
    case twoHundredKB = 0
    case fourHundredKB
    case eightHundredKB
    case original
}

class ImagePickerViewModel {
    private var disposeBag = DisposeBag()
    var imageCompressType = ImageCompressType.original
    let dataSource = ImagePickerDataSource()
    let imageAsstesCollection = ImageAssetsCollection()
    
    func loadAssets() {
        dataSource.loadAssets()
    }
        
    func uploadAssets(_ completion: @escaping (HiPDA.Result<[Int], NSError>) -> Void) {
        ImagePickerViewModel.fetchHash { result in
            switch result {
            case .success(let hash):
                self.disposeBag = DisposeBag()
                let assets = self.imageAsstesCollection.getAssets()
                                    .flatMap { $0.downloadedAsset }
                var imageNumbers = Array(repeatElement(0, count: assets.count))
                var err: NSError?
                let group = DispatchGroup()
                for i in 0..<assets.count {
                    let asset = assets[i]
                    group.enter()
                    DispatchQueue.global().async {
                        asset.upload(hash: hash, type: self.imageCompressType) { result in
                            switch result {
                            case .success(let num):
                                imageNumbers[i] = num
                            case .failure(let error):
                                err = error as NSError
                            }
                            group.leave()
                        }?.disposed(by: self.disposeBag)
                    }
                }
                group.notify(queue: DispatchQueue.main) { 
                    if let error = err {
                        completion(.failure(error))
                        return
                    }
                    completion(.success(imageNumbers.sorted(by: <)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private static func fetchHash(_ completion: @escaping (HiPDA.Result<String, NSError>) -> Void) {
        NetworkUtilities.html(from: "/forum/post.php?action=newthread&fid=57") { result in
            switch result {
            case let .success(html):
                do {
                    let hash = try HtmlParser.hash(from: html)
                    completion(.success(hash))
                } catch {
                    completion(.failure(error as NSError))
                }
            case let .failure(error):
                completion(.failure(error as NSError))
            }
        }
    }
}

// MARK: - UICollectionViewDataSource Related

extension ImagePickerViewModel {
    func getAssets() -> [ImageAsset] {
        return dataSource.assets
    }
    
    func numberOfItems() -> Int {
        return dataSource.assets.count + 1
    }
    
    func asset(at index: Int) -> ImageAsset {
        return dataSource.assets[index - 1]
    }
}
