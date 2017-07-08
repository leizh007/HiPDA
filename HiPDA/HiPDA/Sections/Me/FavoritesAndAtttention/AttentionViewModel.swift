//
//  AttentionViewModel.swift
//  HiPDA
//
//  Created by leizh007 on 2017/7/8.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

class AttentionViewModel: FavoritesAndAttentionBaseViewModel {
    override func transform(html: String) throws -> [FavoritesAndAttentionBaseModel] {
        return try HtmlParser.attentionModels(from: html)
    }
}
