//
//  URLSession+.swift
//  HeedInstrument
//
//  Created by setuper on 25.03.2026.
//

import Foundation

extension URLSession {

    @objc func hs_instrumented_dataTask(
        with request: URLRequest,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        let start = CFAbsoluteTimeGetCurrent()
        let wrapped: (Data?, URLResponse?, Error?) -> Void = { data, response, error in
            let duration = CFAbsoluteTimeGetCurrent() - start
            let log = self.hs_makeNetworkLog(
                request: request,
                data: data,
                response: response,
                error: error,
                duration: duration
            )
            EventLogger.shared.log(log)
            completionHandler(data, response, error)
        }
        return hs_instrumented_dataTask(with: request, completionHandler: wrapped)
    }

    @objc(hs_instrumented_dataTaskWithURL:completionHandler:)
    func hs_instrumented_dataTask(
        with url: URL,
        completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void
    ) -> URLSessionDataTask {
        let request = URLRequest(url: url)
        return dataTask(with: request, completionHandler: completionHandler)
    }

    @objc func hs_instrumented_dataTask(with url: URL) -> URLSessionDataTask {
        return hs_instrumented_dataTask(with: url)
    }

    private func hs_makeNetworkLog(
        request: URLRequest,
        data: Data?,
        response: URLResponse?,
        error: Error?,
        duration: TimeInterval
    ) -> EventLog {
        let method = request.httpMethod ?? "GET"
        let urlString = request.url?.absoluteString ?? ""
        let path = request.url?.path ?? ""
        let query = request.url?.query ?? ""
        let params = query.isEmpty ? "" : "params=\(query)"

        var bodyString = ""
        if let body = request.httpBody, !body.isEmpty {
            bodyString = hs_truncate(String(data: body, encoding: .utf8) ?? "<binary>")
        }

        var responseString = ""
        var jsonString = ""
        if let data, !data.isEmpty {
            responseString = hs_truncate(String(data: data, encoding: .utf8) ?? "<binary>")
            if let json = try? JSONSerialization.jsonObject(with: data, options: []),
               let jsonData = try? JSONSerialization.data(withJSONObject: json, options: [.sortedKeys]),
               let jsonText = String(data: jsonData, encoding: .utf8) {
                jsonString = hs_truncate(jsonText)
            }
        }

        let statusCode: String
        if let http = response as? HTTPURLResponse {
            statusCode = String(http.statusCode)
        } else {
            statusCode = ""
        }

        let errorText = error.map { String(describing: $0) } ?? ""

        let detailParts = [
            "path=\(path)",
            "url=\(urlString)",
            "method=\(method)",
            params,
            bodyString.isEmpty ? "" : "body=\(bodyString)",
            statusCode.isEmpty ? "" : "status=\(statusCode)",
            responseString.isEmpty ? "" : "response=\(responseString)",
            jsonString.isEmpty ? "" : "json=\(jsonString)",
            errorText.isEmpty ? "" : "error=\(errorText)"
        ].filter { !$0.isEmpty }

        return EventLog(
            category: "Network",
            eventType: "request",
            duration: duration,
            detail: detailParts.joined(separator: " ")
        )
    }

    private func hs_truncate(_ text: String, limit: Int = 2000) -> String {
        guard text.count > limit else { return text }
        let idx = text.index(text.startIndex, offsetBy: limit)
        return String(text[..<idx]) + "…"
    }
}
