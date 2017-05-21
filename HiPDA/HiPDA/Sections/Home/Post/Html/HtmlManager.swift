//
//  HtmlManager.swift
//  HiPDA
//
//  Created by leizh007 on 2017/5/18.
//  Copyright © 2017年 HiPDA. All rights reserved.
//

import Foundation

struct HtmlManager {
    fileprivate enum Attribute {
        static let content = "####content here####"
        static let style = "####style here####"
        static let script = "####script here####"
        static let maxWidth = "####max width####"
        static let blockQuoteWidth = "####blockquote width####"
    }
    fileprivate static let baseHtml: String = {
        enum HtmlResource {
            static let name = "post"
            enum ResourceType {
                static let html = "html"
                static let css = "css"
                static let js = "js"
            }
        }
        guard let htmlPath = Bundle.main.path(forResource: HtmlResource.name, ofType: HtmlResource.ResourceType.html),
            let cssPath = Bundle.main.path(forResource: HtmlResource.name, ofType: HtmlResource.ResourceType.css),
            let jsPath = Bundle.main.path(forResource: HtmlResource.name, ofType: HtmlResource.ResourceType.js),
            let html = try? String(contentsOfFile: htmlPath, encoding: .utf8),
            var css = try? String(contentsOfFile: cssPath, encoding: .utf8),
            let js = try? String(contentsOfFile: jsPath, encoding: .utf8) else {
                fatalError("Load Html Error!")
        }
        
        let contentMargin = CGFloat(8.0)
        let blockquoteMargin = CGFloat(16.0)
        css = css.replacingOccurrences(of: Attribute.maxWidth, with: "\(Int(C.UI.screenWidth - 2 * contentMargin))px")
            .replacingOccurrences(of: Attribute.blockQuoteWidth, with: "\(Int(C.UI.screenWidth - 2 * contentMargin - 2 * blockquoteMargin))px")

        
        return html.replacingOccurrences(of: Attribute.style, with: css)
                   .replacingOccurrences(of: Attribute.script, with: js)
    }()
    
    static func html(with content: String) -> String {
        return HtmlManager.baseHtml.replacingOccurrences(of: Attribute.content, with: content)
    }
}
