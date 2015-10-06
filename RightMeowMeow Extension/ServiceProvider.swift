//
//  ServiceProvider.swift
//  RightMeowMeow.TopShelf
//
//  Created by Wade on 10/6/15.
//  Copyright © 2015 Johann Kerr. All rights reserved.
//

import Foundation
import TVServices

class ServiceProvider: NSObject, TVTopShelfProvider {
    
    override init() {
        super.init()
    }
    
    // MARK: - TVTopShelfProvider protocol
    
    var topShelfStyle: TVTopShelfContentStyle {
        // Return desired Top Shelf style.
        return .Sectioned
        //return .Inset
    }
    
    var topShelfItems: [TVContentItem] {
        // Create an array of TVContentItems.
        return test1()
    }
    
    func test1()->[TVContentItem]{
        var isectionItems = [TVContentItem]()
        for i in 1...5 {
            let sectionIdentifier = TVContentIdentifier(identifier: String(i), container: nil)
            let sectionItem = TVContentItem(contentIdentifier: sectionIdentifier!)
            
            var contentItems = [TVContentItem]()
            for j in 1...2 {
                let itemIdentifier = TVContentIdentifier(identifier: String(i) + String(j), container: nil)
                let item = TVContentItem(contentIdentifier: itemIdentifier!)
                
                item?.imageURL = NSURL(string: "https://b.thumbs.redditmedia.com/dsxRXp6f6UIZjTInWy-TG8Yb2z323gt5yo_Pe9vAAAk.jpg")
                contentItems.append(item!)
                
            }
            
            sectionItem?.title="Type " + String(i)
            sectionItem?.topShelfItems=contentItems;
            
            isectionItems.append(sectionItem!)
        }
        
        return isectionItems
    }
    
    func test2()->[TVContentItem]{
        var isectionItems = [TVContentItem]()
        let sectionIdentifier = TVContentIdentifier(identifier: "Test", container: nil)
        let sectionItem = TVContentItem(contentIdentifier: sectionIdentifier!)
        
        var contentItems = [TVContentItem]()
        for i in 1...5 {
            let itemIdentifier = TVContentIdentifier(identifier: "Test - " + String(i), container: nil)
            let item = TVContentItem(contentIdentifier: itemIdentifier!)
            
            item?.imageURL = NSURL(string: "https://b.thumbs.redditmedia.com/dsxRXp6f6UIZjTInWy-TG8Yb2z323gt5yo_Pe9vAAAk.jpg")
            item?.imageShape = .Square
            
            let url = NSURLComponents()
            url.scheme = "RightMeowMeow"
            url.path = "TopShelf"
            url.queryItems = [NSURLQueryItem(name: "identifier", value: "test")]
            
            item?.displayURL = url.URL;
            
            print(url.URL)
            contentItems.append(item!)
        }
        
        sectionItem?.topShelfItems=contentItems;
        
        isectionItems.append(sectionItem!)
        return isectionItems
    }
    
    func test3()->[TVContentItem]{
        var isectionItems = [TVContentItem]()
        for i in 1...5 {
            let sectionIdentifier = TVContentIdentifier(identifier: String(i), container: nil)
            let sectionItem = TVContentItem(contentIdentifier: sectionIdentifier!)
            
            var contentItems = [TVContentItem]()
            for j in 1...2 {
                let itemIdentifier = TVContentIdentifier(identifier: String(i) + String(j), container: nil)
                let item = TVContentItem(contentIdentifier: itemIdentifier!)
                                
                contentItems.append(item!)
            }
            
            sectionItem?.title="Type " + String(i)
            sectionItem?.imageURL = NSURL(string: "https://b.thumbs.redditmedia.com/dsxRXp6f6UIZjTInWy-TG8Yb2z323gt5yo_Pe9vAAAk.jpg")
            let url = NSURLComponents()
            url.scheme = "RightMeowMeow"
            url.path = "TopShelf"
            url.queryItems = [NSURLQueryItem(name: "identifier", value: "test")]
            sectionItem?.displayURL = url.URL;
            
            isectionItems.append(sectionItem!)
        }
        
        return isectionItems    }
    
}

