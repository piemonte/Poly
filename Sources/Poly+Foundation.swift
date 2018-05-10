//
//  Poly+Foundation.swift
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

extension Formatter {
    
    static let rfc3339: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        return formatter
    }()
    
}

extension String {
    
    public var dateFromRFC3339: Date? {
        return Formatter.rfc3339.date(from: self)
    }
    
}

extension URLRequest {
    
    public var cacheKey: String {
        if let methodHash = self.httpMethod,
            let urlHash = self.url {
            return "\(methodHash)-\(urlHash)"
        } else {
            return "\(self.hashValue)"
        }
    }
    
}

extension URLSession {
    
    public func cancelAllDataTasks() {
        self.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
            guard dataTasks.count > 0 else {
                return
            }
            
            for task in dataTasks {
                task.cancel()
            }
        }
    }
    
}
