//
//  Provider.swift
//  SWARMCats
//
//  Created by Wade on 10/2/15.
//  Copyright © 2015 SWARMNYC. All rights reserved.
//

import Foundation

typealias ProviderFetchSuccessHandler = (data:[Entry]) -> Void
let pageSzie = 100;

protocol Provider {
    var Name: String { get }
    func FetchAsnyc(continueLoad:Bool, success: ProviderFetchSuccessHandler?)
}

class TwitterFavoriateProvider: Provider {
    private let dateFormatter: NSDateFormatter
    let Name = "Twitter"

    init() {
        dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "E MMM dd HH:mm:ss Z yyyy" //Tue Oct 06 22:11:48 +0000 2015
    }

    func FetchAsnyc(continueLoad:Bool,success: ProviderFetchSuccessHandler?) {
        FetchTask(provider: self, continueLoad:continueLoad, success: success).Run()
    }

    private class FetchTask {
        private var successFetch: ProviderFetchSuccessHandler?;
        private var provider: TwitterFavoriateProvider;

        init(provider: TwitterFavoriateProvider, continueLoad:Bool, success: ProviderFetchSuccessHandler?) {
            self.provider = provider;
            self.successFetch = success;

        }

        func Run() {
            let client = OAuthSwiftClient(consumerKey: "tuPdqGWSqvDNRC8TrcJ1dyuSd",
                    consumerSecret: "oAjcN1hXSo0AZw9XauXU6qbwcR5FDBYnAvSHygFKbE2wg9kcxs",
                    accessToken: "493671024-t68XphyAbMaIgetsALOa5OPY9V5XMShOxvDZg8qz",
                    accessTokenSecret: "FLFS5RK0I3NXUA94s9OHHiSp9IxC7bFpFVaoXGRvnXtla")

            var parameters = Dictionary<String, AnyObject>();
            parameters["count"] = pageSzie;
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
    private var afterKey = ""
    let Name = "Reddit"
   
    func FetchAsnyc(continueLoad:Bool, success: ProviderFetchSuccessHandler?) {
        let catApiURL = "https://www.reddit.com/r/cats/hot.json?limit=\(pageSzie)" + (continueLoad.boolValue ? "&afterKey=" + afterKey : "")
        let request = NSURLRequest(URL: NSURL(string: catApiURL)!)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
                success!(data: [Entry]())
            } else {
                var json = JSON(data: data!)
                self.afterKey = json["data"]["after"].stringValue
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
                            score: item["score"].intValue,
                            source: self.Name))
                }

                success!(data: entries)
            }
        })
        task.resume()
    }
}


class RedditGifsFavoriteProvider: Provider {
    private var afterKey = ""
    let Name = "RedditGifs"

    func FetchAsnyc(continueLoad:Bool, success: ProviderFetchSuccessHandler?) {
        let catApiURL = "https://www.reddit.com/r/cats/hot.json?limit=\(pageSzie)" + (continueLoad.boolValue ? "&afterKey=" + afterKey : "")
        let request = NSURLRequest(URL: NSURL(string: catApiURL)!)
        let urlSession = NSURLSession.sharedSession()
        let task = urlSession.dataTaskWithRequest(request, completionHandler: {
            (data, response, error) -> Void in
            if error != nil {
                print(error!.localizedDescription)
                success!(data: [Entry]())
            } else {
                var json = JSON(data: data!)
                self.afterKey = json["data"]["after"].stringValue
                
                var entries = [Entry]();

                var items = json["data"]["children"];
                for var i = 0; i < items.count; ++i {
                    var item = items[i]

                    let stringCheck = item["data"]["url"].stringValue
                    let checkUrl = NSURL(string: stringCheck)!
                    if checkUrl.pathExtension!.lowercaseString == "gif" {
                                entries.append(Entry(
                                    id: item["id"].stringValue,
                                    imgUrl: item["data"]["url"].stringValue,
                                    text: item["title"].stringValue,
                                    updatedAt: item["created_utc"].doubleValue,
                                    score: item["score"].intValue,
                                    source: self.Name))
                    }
                }

                success!(data: entries)
            }
        })
        task.resume()
    }
}