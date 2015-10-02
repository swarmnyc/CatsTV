//
//  Provider.swift
//  SWARMCats
//
//  Created by SWARMMAC01 on 10/2/15.
//  Copyright © 2015 SWARMNYC. All rights reserved.
//

import Foundation
import CoreData

class ProviderCollection {
    typealias SuccessHandler = (data:[Entry]) -> Void
    
    static let Instance = ProviderCollection();
    
    private let providers: [Provider];
    
    var Providers: [Provider] {
        get {
            return providers
        }
    }
    
    private init() {
        providers = [TwitterFavoriateProvider()]

    }
    
}

protocol Provider {
    func Fetch(success: ProviderCollection.SuccessHandler)
}

class Entry {
    var Id: String
    var Url: String
    init(id: String, url: String) {
        Id = id
        Url = url
    }
}

class TwitterFavoriateProvider: Provider {
    var successFetch: ProviderCollection.SuccessHandler?;
    
    func Fetch(success: ProviderCollection.SuccessHandler) {
        successFetch = success;
        
        let client = OAuthSwiftClient(consumerKey: "tuPdqGWSqvDNRC8TrcJ1dyuSd",
            consumerSecret: "oAjcN1hXSo0AZw9XauXU6qbwcR5FDBYnAvSHygFKbE2wg9kcxs",
            accessToken: "493671024-t68XphyAbMaIgetsALOa5OPY9V5XMShOxvDZg8qz",
            accessTokenSecret: "FLFS5RK0I3NXUA94s9OHHiSp9IxC7bFpFVaoXGRvnXtla")
        
        var parameters = Dictionary<String, AnyObject>();
        parameters["count"]=100;
        client.get("https://api.twitter.com/1.1/favorites/list.json", parameters: parameters, success: successCallback, failure: errorCallback)
       
        
    }
    
    func successCallback(data: NSData, response: NSHTTPURLResponse) -> Void {
        
        let jsonDict = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as! [AnyObject]
        
        
        var entries = [Entry]();
        for tweet in jsonDict! {
            let medias = tweet["entities"]!!["media"]!;
            if medias != nil {
                let media = medias![0];
                entries.append(Entry(id: String(media["id"] as! Int), url: media["media_url"] as! String))
            }
        }
        
        successFetch!(data: entries)
    }
    
    func errorCallback(error: NSError) -> Void {
        print(error)
    }
}