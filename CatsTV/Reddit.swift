//
//  Reddit.swift
//  CatsTV
//
//  Created by William Robinson on 2/14/17.
//
//

import Foundation
import AVKit

class Reddit {
  static var after = ""
  
  // Retrieve cats data from Reddit
  static func getCatURLs(completion: @escaping ([Cat]) -> Void) {
    let url = URL(string: "https://www.reddit.com/r/catgifs/hot.json?limit=50" + (!after.isEmpty ? "&after=" + after : ""))!
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
      if let error = error {
        print("error retrieving cats from reddit: \(error.localizedDescription)")
        return
      }
      guard let data = data else {
        print("error unwrapping cats data from reddit")
        return
      }
      parse(data) { catURLs in
        var cats: [Cat] = []
        for catURL in catURLs {
          cats.append(Cat(url: catURL))
        }
        
        print(after)
        
        completion(cats)
      }
    }
    task.resume()
  }
  
  // Parse cats data
  private static func parse(_ data: Data, completion: @escaping ([URL]) -> Void) {
    do {
      let json = try JSONSerialization.jsonObject(with: data, options: [])
      guard let jsonDict = json as? [String : Any] else {
        print("error unwrapping reddit cats json dict")
        completion([])
        return
      }
      guard let jsonData = jsonDict["data"] as? [String : Any] else {
        print("error unwrapping reddit cats json data")
        completion([])
        return
      }
      guard let jsonChildren = jsonData["children"] as? [[String : Any]] else {
        print("error unwrapping reddit cats json children")
        completion([])
        return
      }
      if let after = jsonData["after"] as? String {
        Reddit.after = after
      }
      
      var catURLs: [URL] = []
      for jsonChild in jsonChildren {
        guard let childData = jsonChild["data"] as? [String : Any] else {
          print("error unwrapping reddit cats json child data\njson child: \(jsonChild)")
          continue
        }
        guard childData["domain"] is String, (childData["domain"] as! String).hasSuffix("imgur.com") else {
          continue
        }
        guard let childURL = childData["url"] as? String else {
          print("error unwrapping reddit cats json child url\njson child data: \(childData)")
          continue
        }
        
        var url = URL(string: childURL)!
        let urlExtension = url.pathExtension.lowercased()
        switch urlExtension {
        case "gif", "gifv":
          url = URL(string: childURL.replacingOccurrences(of: ".\(urlExtension)", with: ".mp4"))!
          catURLs.append(url)
        default:
          continue
        }
      }
      completion(catURLs)
    } catch {
      print("error serializing reddit cats data: \(error)")
    }
  }
  
  func dumb() {
    
  }
}


