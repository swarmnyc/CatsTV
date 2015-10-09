//
//  Provider.swift
//  SWARMCats
//
//  Created by Wade on 10/2/15.
//  Copyright © 2015 SWARMNYC. All rights reserved.
//

import Foundation

typealias ProviderFetchSuccessHandler = (data:[Entry]) -> Void

protocol Provider {
    var Name: String { get }
    var IsLoaded: Bool { get }
    func FetchAsnyc(success: ProviderFetchSuccessHandler?)
}

class TwitterFavoriateProvider: Provider {
    private var dateFormatter : NSDateFormatter
    
    var Name = "Twitter"
    var IsLoaded = false
    
    init(){
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy" //Tue Oct 06 22:11:48 +0000 2015
    }
    func FetchAsnyc(success: ProviderFetchSuccessHandler?) {
        FetchTask(provider:self, success: success).Run()
    }
    
    private class FetchTask {
        private var successFetch: ProviderFetchSuccessHandler?;
        private var provider: TwitterFavoriateProvider;
        
        init(provider: TwitterFavoriateProvider, success: ProviderFetchSuccessHandler?){
            self.provider = provider;
            self.successFetch = success;
            
        }
        
        func Run() {
            let client = OAuthSwiftClient(consumerKey: "tuPdqGWSqvDNRC8TrcJ1dyuSd",
                consumerSecret: "oAjcN1hXSo0AZw9XauXU6qbwcR5FDBYnAvSHygFKbE2wg9kcxs",
                accessToken: "493671024-t68XphyAbMaIgetsALOa5OPY9V5XMShOxvDZg8qz",
                accessTokenSecret: "FLFS5RK0I3NXUA94s9OHHiSp9IxC7bFpFVaoXGRvnXtla")
            
            var parameters = Dictionary<String, AnyObject>();
            parameters["count"] = 100;
            client.get("https://api.twitter.com/1.1/favorites/list.json", parameters: parameters, success: successCallback, failure: errorCallback)
        }
        
        func successCallback(data: NSData, response: NSHTTPURLResponse) -> Void {
            provider.IsLoaded=true;
            
            let jsonDict = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as! [AnyObject]
            
            var entries = [Entry]();
            for tweet in jsonDict! {
                let medias = tweet["entities"]!!["media"]!;
                if medias != nil {
                    let media = medias![0];
                    
                    // todo add fill whole data
                    entries.append(Entry(
                        id: String(media["id"] as! Int),
                        imgUrl: media["media_url"] as! String,
                        text: tweet["text"] as! String,
                        updatedAt: provider.dateFormatter.dateFromString(tweet["created_at"] as! String)!.timeIntervalSince1970,
                        score: 0,
                        source: provider.Name))
                }
            }
            
            successFetch!(data: entries)
        }
        
        func errorCallback(error: NSError) -> Void {
            print(error)
        }
    }
}

class RedditProvider: Provider {
    var Name = "Reddit"
    var IsLoaded = false
    
    func FetchAsnyc(callback: ProviderFetchSuccessHandler?) {
        let catApiURL = "https://www.reddit.com/r/cats/hot.json?limit=100"
        let request = NSURLRequest(URL: NSURL(string: catApiURL)!)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
                callback!(data: [Entry]())
            } else {
                self.IsLoaded = true;
                
                var json = JSON(data: data!)
                
                var entries = [Entry]();
                
                var items = json["data"]["children"];
                for var i = 0; i < items.count; ++i {
                    var item = items[i]["data"]
                    
                    // todo add fill whole data
                    entries.append(Entry(
                        id: item["id"].stringValue,
                        imgUrl: item["preview"]["images"][0]["source"]["url"].stringValue,
                        text: item["title"].stringValue,
                        updatedAt: item["created_utc"].doubleValue,
                        score: i,
                        source: self.Name))
                }
                
                callback!(data: entries)
            }
        })
        task.resume()
    }
}