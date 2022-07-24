//
//  JsonParser.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 23.07.2022.
//
import UIKit

class JSONParser {
    func DecodeJSON<T:Codable>(data : Data,codableClass : T.Type)->T? {
        do {
            let decoder = JSONDecoder()
            let items = try decoder.decode(T.self, from: data)
            return items
        } catch {
            print("error on parsing, ", Error.self)
            return nil
        }
    }
}
