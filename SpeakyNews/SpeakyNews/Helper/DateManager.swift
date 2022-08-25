//
//  DateManager.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 21.08.2022.
//

import Foundation

class DateManager {
    private var dateStr : String?
    init(_ dateStr : String) {
        self.dateStr = dateStr
    }
    func setDate(_ dateStr : String){
        self.dateStr = dateStr
    }
    func convertDateFormat()->String {
        if let dateStr = dateStr {
            let previousDateFormatter = DateFormatter()
            previousDateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            let previousDate = previousDateFormatter.date(from: dateStr)
            
            let newDateFormatter = DateFormatter()
            newDateFormatter.dateFormat = "MMM dd yyyy h:mm a"
            
            return newDateFormatter.string(from: previousDate!)
        } else {
            return ""
        }
    }
}
