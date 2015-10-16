//
//  Entry.swift
//  RightMeowMeow
//
//  Created by Wade on 10/6/15.
//  Copyright © 2015 Johann Kerr. All rights reserved.
//

import Foundation

enum EntryType: String {
    case Image
    case Gif
    case Video
}

class Entry {
    var Id: String
    var ImgUrl: String
    var Text: String
    var UpdatedAt: Double
    var Score: Int
    var Type: EntryType
    var Source: String

    init(id: String, imgUrl: String, text: String, updatedAt: Double, score: Int, source: String) {
        Id = id
        ImgUrl = imgUrl
        Text = text
        UpdatedAt = updatedAt
        Score = score
        Source = source
        
        let temp = imgUrl.lowercaseString
        if temp.containsString(".mp4") {
            Type = .Video
        } else if temp.containsString(".gif") {
            Type = .Gif
        } else {
            Type = .Image
        }
    }
}

typealias EntryServiceFetchSuccessHandler = (data:[Entry]) -> Void

class EntryService {

    private static var Providers: [Provider] = [
            //RedditProvider(),
            //TwitterFavoriateProvider(),
            RedditGifsFavoriteProvider()
    ];

    //private static var Entries: [Entry] = [];

    static func FetchAsnyc(callback: EntryServiceFetchSuccessHandler?) {
        IntenalFetchMoreAsnyc(false, callback: callback)
    }

    static func FetchMoreAsnyc(callback: EntryServiceFetchSuccessHandler?) {
        IntenalFetchMoreAsnyc(true, callback: callback)
    }
    
    private static func IntenalFetchMoreAsnyc(continueLoad:Bool, callback: EntryServiceFetchSuccessHandler?){
        var counter = 0;
        
        var result = [Entry]()
        
        for provider in Providers {
            provider.FetchAsnyc(continueLoad, success: {
                data in
                for entry: Entry in data {
                    result.insert(entry, atIndex: Int(arc4random_uniform(UInt32(result.count))))
                }
                
                counter++;
                if counter == Providers.count {
                    callback!(data: result)
                }
            })
        }
    }
}