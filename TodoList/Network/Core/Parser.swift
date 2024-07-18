//
//  Parser.swift
//  TodoList
//
//  Created by Jayant Karthic on 18/07/24.
//

import Foundation

protocol ResponseParser<Response> {
    associatedtype Response
    func parse(data: Data) throws -> Response
}

protocol ErrorParser {
    func parse(data: Data) -> Error
}

final class JSONParser<T: Decodable>: ResponseParser {
    typealias Response = T

    func parse(data: Data) throws -> T {
        do {
            let reponse = try JSONDecoder().decode(T.self, from: data)
            return reponse
        } catch {
            throw error
        }
    }
}

final class ResponseErrorParser: ErrorParser {
    func parse(data: Data) -> Error {
        var error: Error = WebServiceError.serverError
        
        do {
            _ = try JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
//            print(json)
        } catch(let parseError) {
            error = parseError
        }
        
        return error
    }
}


