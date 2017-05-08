//
//  String+HiPDA.swift
//  HiPDA
//
//  Created by leizh007 on 2016/10/17.
//  Copyright © 2016年 HiPDA. All rights reserved.
//

import Foundation

extension String {
    /// 获取md5加密后的字符串
    var md5: String {
        let context = UnsafeMutablePointer<CC_MD5_CTX>.allocate(capacity: 1)
        var digest = Array<UInt8>(repeating:0, count:Int(CC_MD5_DIGEST_LENGTH))
        CC_MD5_Init(context)
        CC_MD5_Update(context, self, CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8)))
        CC_MD5_Final(&digest, context)
        context.deallocate(capacity: 1)
        var hexString = ""
        for byte in digest {
            hexString += String(format:"%02x", byte)
        }
        
        return hexString
    }
    
    /// 帖子列表发表时间到描述字符串
    var descriptionTimeStringForThread: String {
        let dateFormater = DateFormatter()
        dateFormater.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormater.date(from: self) else {
            return "日期解析错误"
        }
        
        let deltaSeconds = fabs((date.timeIntervalSinceNow))
        let deltaMinutes = deltaSeconds / 60.0
        
        var descriptionTimeString = ""
        
        switch(deltaMinutes) {
        case let today where today < 24 * 60 :
            descriptionTimeString = "今天"
        case let yesterday where yesterday < 24 * 2 * 60 :
            descriptionTimeString = "昨天"
        case let days where days < 24 * 7 * 60 :
            descriptionTimeString = String(format: "%d天前", Int(floor(days / (24 * 60))))
        case let lastWeak where lastWeak < 24 * 14 * 60 :
            descriptionTimeString = "1周前"
        case let weaks where weaks < 24 * 60 * 31 :
            descriptionTimeString = String(format: "%d周前", Int(floor(weaks / (24 * 60 * 7))))
        case let lastMonth where lastMonth < 24 * 60 * 61 :
            descriptionTimeString  = "1个月前"
        case let months where months < 24 * 60 * 365.25 :
            descriptionTimeString = String(format: "%d个月前", Int(floor(months / (24 * 60 * 30))))
        case let lastYear where lastYear < 24 * 60 * 731 :
            descriptionTimeString = "1年前"
        default:
            descriptionTimeString = String(format: "%d年前", Int(floor(deltaMinutes / (24 * 60 * 365))))
        }
        return descriptionTimeString
    }
}

//http://stackoverflow.com/questions/25607247/how-do-i-decode-html-entities-in-swift
// Mapping from XML/HTML character entity reference to character
// From http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
// Mapping from XML/HTML character entity reference to character
// From http://en.wikipedia.org/wiki/List_of_XML_and_HTML_character_entity_references
private let characterEntities : [ String : Character ] = [
    // XML predefined entities:
    "&quot;"    : "\"",
    "&amp;"     : "&",
    "&apos;"    : "'",
    "&lt;"      : "<",
    "&gt;"      : ">",
    
    // HTML character entity references:
    "&nbsp;"    : "\u{00a0}",
    // ...
    "&diams;"   : "♦",
]

extension String {
    
    /// Returns a new string made by replacing in the `String`
    /// all HTML character entity references with the corresponding
    /// character.
    var stringByDecodingHTMLEntities : String {
        
        // ===== Utility functions =====
        
        // Convert the number in the string to the corresponding
        // Unicode character, e.g.
        //    decodeNumeric("64", 10)   --> "@"
        //    decodeNumeric("20ac", 16) --> "€"
        func decodeNumeric(_ string : String, base : Int) -> Character? {
            guard let code = UInt32(string, radix: base),
                let uniScalar = UnicodeScalar(code) else { return nil }
            return Character(uniScalar)
        }
        
        // Decode the HTML character entity to the corresponding
        // Unicode character, return `nil` for invalid input.
        //     decode("&#64;")    --> "@"
        //     decode("&#x20ac;") --> "€"
        //     decode("&lt;")     --> "<"
        //     decode("&foo;")    --> nil
        func decode(_ entity : String) -> Character? {
            
            if entity.hasPrefix("&#x") || entity.hasPrefix("&#X"){
                return decodeNumeric(entity.substring(with: entity.index(entity.startIndex, offsetBy: 3) ..< entity.index(entity.endIndex, offsetBy: -1)), base: 16)
            } else if entity.hasPrefix("&#") {
                return decodeNumeric(entity.substring(with: entity.index(entity.startIndex, offsetBy: 2) ..< entity.index(entity.endIndex, offsetBy: -1)), base: 10)
            } else {
                return characterEntities[entity]
            }
        }
        
        // ===== Method starts here =====
        
        var result = ""
        var position = startIndex
        
        // Find the next '&' and copy the characters preceding it to `result`:
        while let ampRange = self.range(of: "&", range: position ..< endIndex) {
            result.append(self[position ..< ampRange.lowerBound])
            position = ampRange.lowerBound
            
            // Find the next ';' and copy everything from '&' to ';' into `entity`
            if let semiRange = self.range(of: ";", range: position ..< endIndex) {
                let entity = self[position ..< semiRange.upperBound]
                position = semiRange.upperBound
                
                if let decoded = decode(entity) {
                    // Replace by decoded character:
                    result.append(decoded)
                } else {
                    // Invalid entity, copy verbatim:
                    result.append(entity)
                }
            } else {
                // No matching ';'.
                break
            }
        }
        // Copy remaining characters to `result`:
        result.append(self[position ..< endIndex])
        return result
    }
}
