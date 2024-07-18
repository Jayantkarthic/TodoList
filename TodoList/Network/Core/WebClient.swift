//
//  WebClient.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//

import Foundation
import Combine

protocol Sendable {
    associatedtype R: Request
    func send(request: R) -> AnyPublisher<R.Response, Error>
}

final class WebClient<R: Requestable>: Sendable {
    private var configuration: URLSessionConfiguration
    private var session: URLSession
    
    var activityIndicatorPublisher = CurrentValueSubject<Bool, Never>(false)
    
    init(sessionConfiguration: URLSessionConfiguration = URLSession.shared.configuration) {
        configuration = sessionConfiguration
        session = URLSession(configuration: configuration)
    }
    
    func send(request: R) -> AnyPublisher<R.Response, Error> {
        guard let webRequest = try? request.asURLRequest() else {
            return  Fail(error: WebServiceError.badRequest).eraseToAnyPublisher()
        }
        
        print("**********************************************************")
        print("Request URL : \(webRequest.url?.absoluteString ?? "INVALID URL")")
        print("Request method : \(webRequest.httpMethod ?? "INVALID HTTP METHOD")")
        print("Request Headers : \(webRequest.allHTTPHeaderFields ?? [:])")
        print("Request body : \(String(describing: String(data: webRequest.httpBody ?? Data(), encoding: .utf8)))")
        print("**********************************************************")
        
        return session.dataTaskPublisher(for: webRequest)

            .tryMap({ data, response in
               print(String(data: data, encoding: .utf8) ?? "Errror")
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {

                        return data
                    } else if (201...300).contains(httpResponse.statusCode) {
                        let errorParser = ResponseErrorParser()
                        do {
                            throw errorParser.parse(data: data)
                        } catch {
                            throw WebServiceError.errorFor(statusCode: httpResponse.statusCode)
                        }
                    } else {
                        throw WebServiceError.errorFor(statusCode: httpResponse.statusCode)
                    }
                } else {
                    throw WebServiceError.invalidResponse
                }
            })
            .tryMap({ data in
                let parser = JSONParser<R.Response>()
                do {
                    return try parser.parse(data: data)
                } catch {
                    throw ParseError.parseError(reason: error.localizedDescription)
                }
            })
            .eraseToAnyPublisher()
    }
}
