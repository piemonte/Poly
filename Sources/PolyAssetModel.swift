//
//  PolyAssetModel.swift
//  Poly
//
//  Copyright (c) 2018-present patrick piemonte (http://patrickpiemonte.com)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Foundation
import ObjectMapper

// PolyAssetModel abstracts received assets from the Poly API
public final class PolyAssetModel: NSObject, Mappable {
    
    // MARK: - factory
    
    public class func createPolyAssetModel(withJson json: [String:Any]) -> PolyAssetModel? {
        return Mapper<PolyAssetModel>().map(JSON: json)
    }
    
    // MARK: - properties
    
    // https://developers.google.com/poly/reference/api/rest/v1/assets#Asset
    
    public var identifier: String
    public var displayName: String?
    public var authorName: String?
    public var assetDescription: String?
    public var createdAt: Date?
    public var updatedAt: Date?
    
    public var formats: [PolyFormatsModel]?
    public var thumbnail: PolyFileModel?
    
    public var license: String?
    public var visibility: String?
    public var isCurated: Bool?
    public var presentationParams: PolyPresentationParamsModel?
    
    // MARK: - ivars
    
    internal var _createdAt: String? {
        didSet {
            self.createdAt = self._createdAt?.dateFromRFC3339
        }
    }
    internal var _updatedAt: String? {
        didSet {
            self.updatedAt = self._updatedAt?.dateFromRFC3339
        }
    }
    
    // MARK: - object lifecycle
    
    public required init?(map: Map) {
        self.identifier = UUID().uuidString
    }
    
}

// MARK: - Mappable

extension PolyAssetModel {
    
    public func mapping(map: Map) {
        self.identifier <- map["name", nested: false]
        self.displayName <- map["displayName", nested: false]
        self.authorName <- map["authorName", nested: false]
        self.assetDescription <- map["description", nested: false]
        
        self._createdAt <- map["createTime", nested: false]
        self._updatedAt <- map["updateTime", nested: false]
        
        self.formats <- map["formats", nested: false]
        self.thumbnail <- map["thumbnail", nested: false]
        
        self.license <- map["license", nested: false]
        self.visibility <- map["visibility", nested: false]
        self.isCurated <- map["isCurated", nested: false]
        
        self.presentationParams <- map["presentationParams", nested: false]
    }
    
}

