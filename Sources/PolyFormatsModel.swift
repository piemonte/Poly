//
//  PolyFormatsModel.swift
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

// PolyFormatsModel abstracts received file types from the Poly API
public final class PolyFormatsModel: NSObject, Mappable {
    
    // MARK: - factory
    
    public class func createPolyFormatsModel(withJson json: [String:Any]) -> PolyFormatsModel? {
        return Mapper<PolyFormatsModel>().map(JSON: json)
    }
    
    // MARK: - properties
    
    // https://developers.google.com/poly/reference/api/rest/v1/assets#Asset.Format
    
    public var root: PolyFileModel?
    public var resources: [PolyFileModel]?
    // formatComplexity
    public var formatType: String?
    
    // MARK: - object lifecycle
    
    public required init?(map: Map) {
    }
    
}


// MARK: - Mappable

extension PolyFormatsModel {
    
    public func mapping(map: Map) {
        self.root <- map["root", nested: false]
        self.resources <- map["resources", nested: false]
        self.formatType <- map["formatType", nested: false]
    }
    
}
