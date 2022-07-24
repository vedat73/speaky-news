//
//  NewsData.swift
//  SpeakyNews
//
//  Created by Vedat Ozlu on 23.07.2022.
//

struct HeadLine : Codable {
    var print_headline : String?
}

struct MultiMedia : Codable {
    var subtype : String?
    var url: String?
}

struct Docs : Codable {
    var abstract : String?
    var snippet : String?
    var lead_paragraph : String?
    var pub_date : String?
    var source : String?
    var multimedia : [MultiMedia]
    var headline : HeadLine
}

struct Response : Codable {
    var docs : [Docs]
}
struct NewsData : Codable {
    var response : Response
}


