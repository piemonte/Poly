//
//  PolyRequest.swift
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
import Alamofire
import AlamofireNetworkActivityIndicator

public final class PolyRequest {
    
    // MARK: - types
    
    /// Poly cache policies
    public enum CachePolicy: Int, CustomStringConvertible {
        case returnCacheDataElseFetch
        case fetchIgnoringCacheData
        case returnCacheDataDontFetch
        
        public var description: String {
            get {
                switch self {
                case .returnCacheDataElseFetch:
                    return "Return Cache Data Else Fetch"
                case .fetchIgnoringCacheData:
                    return "Fetch Ignoring Cache Data"
                case .returnCacheDataDontFetch:
                    return "Return Cache Data Don't Fetch"
                }
            }
        }
    }
    
    // MARK: - ivars
    
    private var _request: Request?
    
}

// MARK: - fetch

extension PolyRequest {
    
    public func request(withUrl url: URL, parameters: [String: Any]? = nil, completionHandler: Poly.CompletionHandler? = nil) {
        NetworkActivityIndicatorManager.shared.incrementActivityCount()
        self._request = Poly.shared._sessionClient?.request(url, parameters: parameters)
            .responseData { response in
                if let data = response.result.value {
                    NetworkActivityIndicatorManager.shared.decrementActivityCount()
                    DispatchQueue.main.async {
                        completionHandler?(data, nil)
                    }
                } else {
                    NetworkActivityIndicatorManager.shared.decrementActivityCount()
                    DispatchQueue.main.async {
                        completionHandler?(nil, response.error)
                    }
                }
        }
    }
    
    public func fetch(dataWithUrl url: URL,
                      cachePolicy: CachePolicy = .returnCacheDataElseFetch,
                      progressHandler: Poly.ProgressHandler? = nil,
                      completionHandler: Poly.CompletionHandler? = nil) {
        Poly.shared._cache.removeExpired()

        let urlRequest = URLRequest(url: url)
        let fetchCompletionHandler: Poly.CompletionHandler = {(data, error) in
            if let data = data {
                DispatchQueue.main.async {
                    completionHandler?(data, nil)
                }
            } else {
                NetworkActivityIndicatorManager.shared.incrementActivityCount()
                
                // Note: downloading directly to disk may be desired
                // let destination: DownloadRequest.DownloadFileDestination = { _, _ in
                //     let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                //     let documentsURL = URL(fileURLWithPath: documentsPath, isDirectory: true)
                //     let fileURL = documentsURL.appendingPathComponent(url.lastPathComponent)
                //
                //     return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
                // }
                //self._request = Poly.shared._sessionClient?.download(urlRequest, to: destination)
                self._request = Poly.shared._sessionClient?.request(urlRequest)
                    .downloadProgress { progress in
                        progressHandler?(Float(progress.fractionCompleted))
                    }
                    .responseData { response in
                        if let data = response.result.value {
                            Poly.shared._cache.set(data: data, key: urlRequest.cacheKey)
                            NetworkActivityIndicatorManager.shared.decrementActivityCount()
                            DispatchQueue.main.async {
                                completionHandler?(data, nil)
                            }
                        } else {
                            NetworkActivityIndicatorManager.shared.decrementActivityCount()
                            DispatchQueue.main.async {
                                completionHandler?(nil, response.error)
                            }
                        }
                }
            }
        }
        
        switch cachePolicy {
        case .fetchIgnoringCacheData:
            fetchCompletionHandler(nil, nil)
            break
        case .returnCacheDataDontFetch:
            Poly.shared._cache.get(dataWithKey: urlRequest.cacheKey) { (data, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        completionHandler?(data, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completionHandler?(nil, PolyError.invalid)
                    }
                }
            }
            break
        case .returnCacheDataElseFetch:
            Poly.shared._cache.get(dataWithKey: urlRequest.cacheKey, completionHandler: fetchCompletionHandler)
            break
        }
    }
    
    public func cancel() {
        self._request?.cancel()
    }
    
}
