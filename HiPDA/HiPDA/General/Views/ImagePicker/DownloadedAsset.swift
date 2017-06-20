//
//  DownloadedAsset.swift
//  HiPDA
//
//  Created by leizh007 on 2017/6/20.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation
import RxSwift

enum ImageCompressionError: Error {
    case toDataError
}

extension ImageCompressionError: CustomStringConvertible {
    var description: String {
        switch self {
        case .toDataError:
            return "获取图片数据出错"
        }
    }
}

extension ImageCompressionError: LocalizedError {
    var errorDescription: String? {
        return description
    }
}

enum DownloadedAsset {
    case image(UIImage)
    case gif(Data)
    var mimeType: String {
        switch self {
        case .image(_):
            return "image/jpeg"
        case .gif(_):
            return "image/gif"
        }
    }
}

extension DownloadedAsset {
    func upload(hash: String, type: ImageCompressType, completion: @escaping (HiPDA.Result<Int, NSError>) -> Void) -> Disposable? {
        do {
            let data = try compressed(with: type)
            return HiPDAProvider.request(.uploadImage(hash: hash, data: data, mimeType: mimeType))
                .observeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                .mapGBKString()
                .subscribe { event in
                    switch event {
                    case .next(let html):
                        do {
                            let num = try HtmlParser.attachImageNumber(from: html)
                            completion(.success(num))
                        } catch {
                            completion(.failure(error as NSError))
                        }
                    case .error(let error):
                        completion(.failure(error as NSError))
                    case .completed:
                        break
                    }
                }
        } catch {
            completion(.failure(error as NSError))
            return nil
        }
    }
}

extension DownloadedAsset {
    func compressed(with type: ImageCompressType) throws -> Data {
        switch self {
        case let .image(image):
            return try compress(image: image, type: type)
        case let .gif(data):
            return data
        }
    }
}

// FIXME: - 性能待优化
fileprivate func compress(image: UIImage, type: ImageCompressType) throws -> Data {
    var compression = CGFloat(1.0)
    let compressionStep = CGFloat(0.1)
    let maxCompression = CGFloat(0.1)
    let threshold: Int
    switch type {
    case .twoHundredKB:
        threshold = 200 * 1000
    case .fourHundredKB:
        threshold = 400 * 1000
    case .eightHundredKB:
        threshold = 800 * 1000
    case .original:
        threshold = .max
    }
    
    guard let data = UIImageJPEGRepresentation(image, compression) else {
        throw ImageCompressionError.toDataError
    }
    var imageData = data
    while imageData.count > threshold && compression > maxCompression {
        compression -= compressionStep
        guard let d = UIImageJPEGRepresentation(image, compression) else {
            throw ImageCompressionError.toDataError
        }
        imageData = d
    }
    return imageData
}
