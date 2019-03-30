//
//  Poly.swift
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
import ObjectMapper
import PromiseKit
import Disk

internal let GooglePolyHostname = "poly.googleapis.com"
internal let GooglePolyBaseUrl = "https://" + GooglePolyHostname

// MARK: - types

/// Error domain for all Poly errors.
public let PolyErrorDomain = "PolyErrorDomain"

/// Error types.
public enum PolyError: Error, CustomStringConvertible {
    case unknown
    case server
    case invalid
    case notAuthorized
    
    public var description: String {
        get {
            switch self {
            case .unknown:
                return "Unknown"
            case .server:
                return "Server error"
            case .invalid:
                return "Invalid input"
            case .notAuthorized:
                return "Not authorized"
            }
        }
    }
}

// MARK: - Poly API param types

/// Poly 3D formats
public enum PolyFormat: String {
    case blocks = "BLOCKS"
    case fbx = "FBX"
    case gltf = "GLTF"
    case gltf2 = "GLTF2"
    case obj = "OBJ"
    case tilt = "TILT"
}

/// Poly asset complexity
public enum PolyComplexity: String {
    case unspecified = "COMPLEXITY_UNSPECIFIED"
    case complex = "COMPLEX"
    case medium = "MEDIUM"
    case simple = "SIMPLE"
}

// MARK: - Poly

/// Poly, Unofficial Google Poly SDK
public final class Poly {

    // MARK: - properties
    
    /// Poly API Key, https://developers.google.com/poly/develop/api
    public var apiKey: String?

    /// Auth token for 'me' requests, https://developers.google.com/identity/protocols/OAuth2
    public var authToken: String? {
        didSet {
            self.setupConfig()
        }
    }
    
    /// Network reachability status of poly.googleapis.com
    public var networkReachable: Bool {
        get {
            return self._reachabilityStatus != .notReachable
        }
    }
    
    /// CompletionHandler for managing background transfers
    public var backgroundCompletionHandler: (() -> Void)? {
        get {
            return self._sessionClientBackground?.backgroundCompletionHandler
        }
        set {
            self._sessionClientBackground?.backgroundCompletionHandler = newValue
        }
    }
    
    // MARK: - ivars

    internal var _reachabilityManager: NetworkReachabilityManager?
    internal var _reachabilityStatus: NetworkReachabilityManager.NetworkReachabilityStatus = .unknown
    
    internal var _configuration: URLSessionConfiguration?
    internal var _configurationBackground: URLSessionConfiguration?

    internal var _sessionClient: SessionManager?            // file downloads
    internal var _sessionClientBackground: SessionManager?  // file uploads
    
    internal var _cache: PolyCache
    
    // MARK: - singleton
    
    /// Poly singleton (if desired)
    public static let shared = Poly()
    
    // MARK: - object lifecycle
    
    /// Initializer for Poly
    public init() {
        self._reachabilityManager = NetworkReachabilityManager(host: GooglePolyHostname)
        self._cache = PolyCache()
        self.setupClient()
    }
    
}

// MARK: - setup

extension Poly {
    
    internal func setupClient() {
        self.setupConfig()

        // create alamofire session
        if let configuration = self._configuration {
            self._sessionClient = SessionManager(configuration: configuration)
        }
        
        // create alamofire background session
        if let configurationBackground = self._configurationBackground {
            self._sessionClientBackground = SessionManager(configuration: configurationBackground)
        }
    }
    
    internal func setupConfig() {
        // create configurations
        if self._configuration == nil {
            self._configuration = URLSessionConfiguration.default
            self._configuration?.isDiscretionary = false
            self._configuration?.allowsCellularAccess = true
            self._configuration?.timeoutIntervalForRequest = 200 // seconds
            self._configuration?.timeoutIntervalForResource = 200
        }

        if self._configurationBackground == nil {
            let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.google.poly.Poly"
            self._configurationBackground = URLSessionConfiguration.background(withIdentifier: bundleIdentifier)
            self._configurationBackground?.sessionSendsLaunchEvents = true
            self._configurationBackground?.isDiscretionary = false
            self._configurationBackground?.timeoutIntervalForRequest = 200 // seconds
            self._configurationBackground?.timeoutIntervalForResource = 200
        }

        // add headers
        if let token = self.authToken {
            self._configuration?.httpAdditionalHeaders?.removeValue(forKey: "Authorization")
            self._configuration?.httpAdditionalHeaders = ["Authorization": "Bearer " + token]

            self._configurationBackground?.httpAdditionalHeaders?.removeValue(forKey: "Authorization")
            self._configurationBackground?.httpAdditionalHeaders = ["Authorization": "Bearer " + token]
        }
    }
    
    /// Reset client configuration
    public func reset() {
        self._cache.removeAll()

        self.apiKey = nil
        self.authToken = nil
        
        self._configuration = nil
        self._configurationBackground = nil
        
        self._sessionClient = nil
        self._sessionClientBackground = nil
    }
    
    /// Cancel all data transfers
    public func cancelAllDataTasks() {
        self._sessionClient?.session.cancelAllDataTasks()
    }
    
}

// MARK: - UIApplication integration

extension Poly {
    
    /// UIApplication integration support for background transfers
    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self._reachabilityManager?.listener = { status in
            self._reachabilityStatus = status
        }
        self._reachabilityManager?.startListening()
        NetworkActivityIndicatorManager.shared.isEnabled = true
        return true
    }

}

// MARK: - Requests

extension Poly {
    
    // MARK: - request completion types
    
    public typealias ProgressHandler = (_ progress: Float) -> Void
    public typealias CompletionHandler = (_ data: Data?, _ error: Error?) -> Void
    public typealias AssetsCompletionHandler = (_ assets: [PolyAssetModel]?, _ totalAssetCount: Int, _ nextPage: Int, _ error: Error?) -> Void
    
    /// Returns detailed information about an asset given its name.
    @discardableResult
    public func get(assetWithIdentifier assetIdentifier: String,
                    completionHandler: AssetsCompletionHandler? = nil) -> PolyRequest? {
        return self.get(assetWithIdentifier: assetIdentifier) { (data, error) in
            if let error = error {
                completionHandler?(nil, 0, 0, error)
            } else if let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)),
                      let jsonDict = json as? [String:Any],
                      let asset = PolyAssetModel.createPolyAssetModel(withJson: jsonDict) {
                completionHandler?([asset], 1, 0, nil)
            } else {
                completionHandler?(nil, 0, 0, error)
            }
        }
    }
    
    /// Lists all public, remixable assets.
    @discardableResult
    public func list(assetsWithKeywords keywords: [String],
                     curated: Bool = false,
                     category: String? = nil,
                     complexity: PolyComplexity = .unspecified,
                     format: PolyFormat = .obj,
                     pageToken: String? = nil,
                     completionHandler: AssetsCompletionHandler? = nil) -> PolyRequest? {
        return self.list(assetsWithKeywords: keywords,
                  curated: curated,
                  category: category,
                  complexity: complexity,
                  format: format,
                  pageToken: pageToken) { (data, error) in
            if let error = error {
                completionHandler?(nil, 0, 0, error)
            } else if let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)),
                let jsonDict = json as? [String:Any] {
                
                let assetsArray = jsonDict["assets"] as? [[String:Any]] ?? []
                let assets: [PolyAssetModel] = Mapper<PolyAssetModel>().mapArray(JSONArray: assetsArray)
                let totalAssetCount = jsonDict["totalAssetCount"] as? Int ?? 0
                let nextPage = jsonDict["nextPage"] as? Int ?? 0

                completionHandler?(assets, totalAssetCount, nextPage, nil)
            } else {
                completionHandler?(nil, 0, 0, error)
            }
        }
    }
    
    /// Returns detailed information about an asset given its name, in raw data.
    @discardableResult
    public func get(assetWithIdentifier assetIdentifier: String,
                    completionHandler: CompletionHandler? = nil) -> PolyRequest? {
        guard let apiKey = self.apiKey else {
            DispatchQueue.main.async {
                completionHandler?(nil, PolyError.notAuthorized)
            }
            return nil
        }
        
        let urlRequestString = GooglePolyBaseUrl + "/v1/assets/" + assetIdentifier
        let parameters = ["key" : apiKey]
        return self.request(withUrlString: urlRequestString, parameters: parameters, completionHandler: completionHandler)
    }
    
    /// Lists all public, remixable assets, in raw data.
    @discardableResult
    public func list(assetsWithKeywords keywords: [String],
                     curated: Bool = false,
                     category: String? = nil,
                     complexity: PolyComplexity = .unspecified,
                     format: PolyFormat = .obj,
                     pageToken: String? = nil,
                     completionHandler: CompletionHandler? = nil) -> PolyRequest? {
        guard let apiKey = self.apiKey else {
            DispatchQueue.main.async {
                completionHandler?(nil, PolyError.notAuthorized)
            }
            return nil
        }

        let urlRequestString = GooglePolyBaseUrl + "/v1/assets/"
        
        var parameters = ["key" : apiKey]
        parameters["curated"] = curated ? "true" : "false"
        parameters["category"] = category
        parameters["maxComplexity"] = complexity.rawValue
        parameters["format"] = format.rawValue
        parameters["pageToken"] = pageToken
        var keywordsString = ""
        if keywords.count > 1 {
            for keyword in keywords {
                keywordsString += keyword + " "
            }
            keywordsString = String(keywordsString.dropLast())
        } else {
            keywordsString = keywords.first ?? ""
        }
        parameters["keywords"] = keywordsString
        return self.request(withUrlString: urlRequestString, parameters: parameters, completionHandler: completionHandler)
    }
}

// MARK: - Download requests

extension Poly {

    // MARK: - completion types
    
    public typealias DownloadCompletionHandler = (_ rootFile: URL?, _ resourceFiles: [URL]?, _ error: Error?) -> Void
    
    /// Downloads the specified asset by identifier.
    ///
    /// - Parameters:
    ///   - assetIdentifier: Asset identifier
    ///   - cachePolicy: Cache policy
    ///   - progressHandler: Handler for progress updates
    ///   - completionHandler: Handler for task completion
    public func download(assetWithIdentifier assetIdentifier: String,
                         cachePolicy: PolyRequest.CachePolicy = .returnCacheDataElseFetch,
                         progressHandler: ProgressHandler? = nil,
                         completionHandler: DownloadCompletionHandler? = nil) {
        self.get(assetWithIdentifier: assetIdentifier) { (assetModels, totalCount, nextPage, error) in
            if let assetModels = assetModels,
                let model = assetModels.first {
                self.download(asset: model,
                              cachePolicy: cachePolicy,
                              progressHandler: progressHandler,
                              completionHandler: completionHandler)
            } else {
                DispatchQueue.main.async {
                    completionHandler?(nil, nil, PolyError.invalid)
                }
            }
        }
    }
    
    /// Downloads the specified asset by model.
    ///
    /// - Parameters:
    ///   - asset: Poly asset to download
    ///   - cachePolicy: Cache policy
    ///   - progressHandler: Handler for progress updates
    ///   - completionHandler: Handler for task completion
    public func download(asset: PolyAssetModel,
                         cachePolicy: PolyRequest.CachePolicy = .returnCacheDataElseFetch,
                         progressHandler: ProgressHandler? = nil,
                         completionHandler: DownloadCompletionHandler? = nil) {
        var rootFile: String? = nil
        var resourceFiles: [String]? = nil
        
        if let formats = asset.formats?.first {
            if let rootUrl = formats.root?.url {
                rootFile = rootUrl
            }
            if let resources = formats.resources {
                for resource in resources {
                    if let resourceUrl = resource.url {
                        if resourceFiles == nil {
                            resourceFiles = []
                        }
                        resourceFiles?.append(resourceUrl)
                    }
                }
            }
        }

        if let rootFile = rootFile {
            
            var rootPath: URL? = nil
            var resourcePaths: [URL]? = nil
            // var totalFileCount = 1 + (resourceFiles?.count ?? 0)
        
            Poly.download(fileWithUrl: rootFile, cachePolicy: cachePolicy, progressHandler: { (progress) in
                // TODO: setup total progress using totalFileCount
            }).then({ (url) -> Promise<[URL]> in
                rootPath = url

                var promises: [Promise<URL>] = []
                if let resourceFiles = resourceFiles {
                    for resourceFile in resourceFiles {
                        let promise = Poly.download(fileWithUrl: resourceFile, cachePolicy: cachePolicy, progressHandler: { (progress) in
                            // TODO: setup total progress using totalFileCount
                        })
                        promises.append(promise)
                    }
                }
                // Note: when will fulfill even if resourceFiles is an empty set
                return when(fulfilled: promises)

            }).done({ (urls) in
                if let _ = resourceFiles {
                    resourcePaths = urls
                }
                DispatchQueue.main.async {
                    completionHandler?(rootPath, resourcePaths, nil)
                }
            }).catch({ (error) in
                DispatchQueue.main.async {
                    completionHandler?(nil, nil, error)
                }
            })
            
        } else {
            DispatchQueue.main.async {
                completionHandler?(nil, nil, PolyError.invalid)
            }
        }
    }
}

// MARK: - internal request support

extension Poly {
    
    static internal func download(fileWithUrl urlString: String,
                                  cachePolicy: PolyRequest.CachePolicy = .returnCacheDataElseFetch,
                                  progressHandler: ProgressHandler? = nil) -> Promise<URL> {
        return Promise { seal in
            guard let urlRequest = URL(string: urlString) else {
                seal.reject(PolyError.unknown)
                return
            }
            
            let request = PolyRequest()
            request.fetch(dataWithUrl: urlRequest, cachePolicy: cachePolicy, progressHandler: progressHandler) { (data, error) in
                if let error = error {
                    seal.reject(error)
                } else if let data = data {
                    do {
                        let filename = urlRequest.lastPathComponent
                        try Disk.save(data, to: .caches, as: filename)
                        let fileUrl = try Disk.url(for: filename, in: .caches)
                        seal.fulfill(fileUrl)
                    } catch let error {
                        seal.reject(error)
                    }
                } else {
                    seal.reject(PolyError.unknown)
                }
            }
        }
    }
    
    @discardableResult
    internal func request(withUrlString urlString: String, parameters: [String: Any]? = nil, completionHandler: CompletionHandler? = nil) -> PolyRequest? {
        guard let urlRequest = URL(string: urlString) else {
            DispatchQueue.main.async {
                completionHandler?(nil, PolyError.invalid)
            }
            return nil
        }
        
        let request = PolyRequest()
        request.request(withUrl: urlRequest, parameters: parameters) { (data, error) in
            if let error = error {
                DispatchQueue.main.async {
                    completionHandler?(nil, error)
                }
            } else {
                DispatchQueue.main.async {
                    completionHandler?(data, nil)
                }
            }
        }
        return request
    }
    
}
