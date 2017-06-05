//
//  PostResult.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/17.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

enum PostError: Error {
    case parseError(String)
    case unKnown(String)
}

// MARK: - CustomStringConvertible

extension PostError: CustomStringConvertible {
    var description: String {
        switch self {
        case let .parseError(errorString):
            return errorString
        case let .unKnown(errorString):
            return errorString
        }
    }
}

typealias PostResult = HiPDAResult<String, PostError>
typealias PostListResult = HiPDAResult<(title: String?, posts: [Post]), PostError>
