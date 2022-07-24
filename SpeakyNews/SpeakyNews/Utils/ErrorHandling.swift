//
//  ErrorHandling.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 23.07.2022.
//

import Foundation

enum NetworkManagerErrors : Error {
    case badResponse(URLResponse)
    case badData
    case badLocalUrl
}
