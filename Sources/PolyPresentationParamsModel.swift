//
//  PolyPresentationParamsModel.swift
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

// PolyFileModel abstracts received file types from the Poly API
public final class PolyPresentationParamsModel: NSObject, Mappable {
    
    // MARK: - factory
    
    public class func createPolyFileModel(withJson json: [String:Any]) -> PolyPresentationParamsModel? {
        return Mapper<PolyPresentationParamsModel>().map(JSON: json)
    }
    
    // MARK: - properties
    
    // https://developers.google.com/poly/reference/api/rest/v1/assets#Asset.PresentationParams
    
    public var orientingRotationX: Double?
    public var orientingRotationY: Double?
    public var orientingRotationZ: Double?
    public var orientingRotationW: Double?
    public var colorSpace: String?
    
    // MARK: - object lifecycle
    
    public required init?(map: Map) {
    }
    
}

// MARK: - Mappable

extension PolyPresentationParamsModel {
    
    public func mapping(map: Map) {
        self.orientingRotationX <- map["orientingRotation.x", nested: true]
        self.orientingRotationY <- map["orientingRotation.y", nested: true]
        self.orientingRotationZ <- map["orientingRotation.z", nested: true]
        self.orientingRotationW <- map["orientingRotation.w", nested: true]
        self.colorSpace <- map["colorSpace", nested: false]
    }
    
}
