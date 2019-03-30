//
//  PolyCache.swift
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
import Cache

// MARK: - PolyCache

public final class PolyCache {
    
    // MARK: - ivars
    
    private var _storage: Storage<Data>?
    private var _diskExpiry: Expiry = .date(Date().addingTimeInterval(3600 * 24 * 90))
    
    // MARK: - object lifecycle
    
    public init() {
        let PolyaCacheName = "PolyCacheV1"
        let PolyCacheCacheMaxSizeBytes: UInt = 1024 * 1024 * 100
        
        let diskConfig = DiskConfig(name: PolyaCacheName, expiry: self._diskExpiry, maxSize: PolyCacheCacheMaxSizeBytes, directory: nil, protectionType: .completeUnlessOpen)
        let memoryConfig = MemoryConfig(expiry: .date(Date().addingTimeInterval(2*60)), countLimit: 2, totalCostLimit: 2)
        self._storage = try? Storage(diskConfig: diskConfig, memoryConfig: memoryConfig, transformer: TransformerFactory.forCodable(ofType: Data.self))
    }
    
}

extension PolyCache {
    
    public func get(dataWithKey key: String, completionHandler: Poly.CompletionHandler? = nil) {
        self._storage?.async.object(forKey: key, completion: { (result) in
            switch result {
            case .value(let data):
                completionHandler?(data, nil)
                break
            case .error(let error):
                completionHandler?(nil, error)
                break
            }
        })
    }
    
    public func set(dataWithUrl fileUrl: URL, key: String, completionHandler: Poly.CompletionHandler? = nil) {
        if let data = FileManager.default.contents(atPath: fileUrl.path) {
            self.set(data: data, key: key, completionHandler: completionHandler)
        } else {
            DispatchQueue.main.async {
                completionHandler?(nil, PolyError.unknown)
            }
        }
    }
    
    public func set(data: Data, key: String, completionHandler: Poly.CompletionHandler? = nil) {
        self._storage?.async.setObject(data, forKey: key, expiry: self._diskExpiry, completion: { (result) in
            switch result {
            case .value(_):
                completionHandler?(nil, nil)
                break
            case .error(let error):
                completionHandler?(nil, error)
                break
            }
        })
    }
    
    public func remove(withKey key: String) {
        try? self._storage?.removeObject(forKey: key)
    }
    
    public func removeExpired() {
        try? self._storage?.removeExpiredObjects()
    }
    
    public func removeAll() {
        try? self._storage?.removeAll()
    }
    
}

