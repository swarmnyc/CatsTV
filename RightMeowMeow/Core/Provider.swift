//
//  Provider.swift
//  SWARMCats
//
//  Created by SWARMMAC01 on 10/2/15.
//  Copyright © 2015 SWARMNYC. All rights reserved.
//

import Foundation
import CoreData

typealias ProviderFetchSuccessHandler = (data:[Entry]) -> Void


protocol Provider {
    var Name: String { get }
    func Fetch(success: ProviderFetchSuccessHandler)
}

class TwitterFavoriateProvider: Provider {
    var Name = "Twitter"
    private var successFetch: ProviderFetchSuccessHandler?;

    func Fetch(success: ProviderFetchSuccessHandler) {
        successFetch = success; // todo: << it might become a bug
        
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
                
                // todo add fill whole data
                entries.append(Entry(id: String(media["id"] as! Int), imgUrl: media["media_url"] as! String, text:"", updatedAt:0, source: Name))
            }
        }
        
        successFetch!(data: entries)
    }
    
    func errorCallback(error: NSError) -> Void {
        print(error)
    }
}

class RedditFavoriateProvider: Provider {
    var Name = "Reddit"
    private var successFetch: ProviderFetchSuccessHandler?;
    
    func Fetch(success: ProviderFetchSuccessHandler) {
        successFetch = success; // todo: << it might become a bug
        
        let catApiURL = "https://www.reddit.com/r/cats/hot.json?limit=100"
        let request = NSURLRequest(URL: NSURL(string:catApiURL)!)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(request,completionHandler: { (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
            }

            self.parseJsonData(data!)
            
        })
        task.resume()
    }
    
    func parseJsonData(data: NSData){
        var json = JSON(data: data)
   
        var entries = [Entry]();
        
        var items = json["data"]["children"];
        for var i = 0; i<items.count ; ++i{
            var item = items[i]
            
            // todo add fill whole data
            entries.append(Entry(id: "", imgUrl: item["data"]["preview"]["images"][0]["source"]["url"].stringValue, text: "", updatedAt: 0,source: Name))
        }
        
        successFetch!(data: entries)
    }
}