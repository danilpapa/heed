//
//  URLSessionSwizzling.swift
//  HeedInstrument
//
//  Created by setuper on 25.03.2026.
//

import Foundation
import ObjectiveC.runtime

public final class URLSessionSwizzling: IHeedSwizzling {
    
    public static func enable() {
        let cls: AnyClass = URLSession.self
        
        let originalWithRequest = #selector(
            URLSession.dataTask(with:completionHandler:)
            as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
        )
        let swizzledWithRequest = #selector(
            URLSession.hs_instrumented_dataTask(with:completionHandler:)
            as (URLSession) -> (URLRequest, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
        )
        swap(cls, originalWithRequest, swizzledWithRequest)
        
        let originalWithURLHandler = #selector(
            URLSession.dataTask(with:completionHandler:)
            as (URLSession) -> (URL, @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
        )
        let swizzledWithURLHandler = NSSelectorFromString("hs_instrumented_dataTaskWithURL:completionHandler:")
        swap(cls, originalWithURLHandler, swizzledWithURLHandler)
        let originalWithURL = #selector(
            URLSession.dataTask(with:)
            as (URLSession) -> (URL) -> URLSessionDataTask
        )
        let swizzledWithURL = #selector(
            URLSession.hs_instrumented_dataTask(with:)
            as (URLSession) -> (URL) -> URLSessionDataTask
        )
        swap(cls, originalWithURL, swizzledWithURL)
    }
    
    private static func swap(_ cls: AnyClass, _ original: Selector, _ swizzled: Selector) {
        guard
            let originalMethod = class_getInstanceMethod(cls, original),
            let swizzledMethod = class_getInstanceMethod(cls, swizzled)
        else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}
