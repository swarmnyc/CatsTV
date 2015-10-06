//
//  Entry.swift
//  RightMeowMeow
//
//  Created by Wade on 10/6/15.
//  Copyright © 2015 Johann Kerr. All rights reserved.
//

import Foundation

class Entry {
    var Id: String
    var ImgUrl: String
    var Text: String
    var UpdatedAt: Int
    var Source: String
    
    init(id:String, imgUrl : String , text:String, updatedAt:Int, source:String){
        Id=id
        ImgUrl=imgUrl
        Text=text
        UpdatedAt=updatedAt
        Source = source
    }
}

typealias EntryServiceFetchSuccessHandler = () -> Void

class EntryService {
    private static var Providers: [Provider] = [RedditFavoriateProvider(), TwitterFavoriateProvider()];
    private static var Entries: [Entry] = [];
    
    static func FetchAsnyc(force: Bool, callback:EntryServiceFetchSuccessHandler?){
        var counter = 0;
        for provider in Providers {
            if !provider.IsLoaded || force {
                provider.FetchAsnyc { data in
                    for entry: Entry in data {
                        EntryService.Entries.append(entry)
                    }
                    
                   CheckFinish(++counter, callback: callback)
                }
            }else{
                CheckFinish(++counter, callback: callback)
            }
        }
    }

    
    static func FetchAsnyc(callback:EntryServiceFetchSuccessHandler?){
        FetchAsnyc(false, callback: callback)
    }
    
    
    static func StartFetchMore(){
        //todo
    }
    
    static func GetEntries() -> [Entry]{
        // todo: mix
        return Entries;
    }
    
    private static func CheckFinish(counter:Int, callback:EntryServiceFetchSuccessHandler?){
        if counter == Providers.count{
            callback!()
        }
    }
}