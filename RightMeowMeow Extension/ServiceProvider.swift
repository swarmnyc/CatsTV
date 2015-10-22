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
    }
    
    var topShelfItems: [TVContentItem] {
        var out = 0
        var entries : [Entry]?;
        //let provider = TwitterFavoriateProvider(5)
        let provider = RedditProvider()
        provider.FetchAsnyc(false, success: { data in
            entries = data
        })
        
        while(entries == nil) {
            if out > 10
            {
                return [TVContentItem]();
            }
            
            out++;
            //waiting
            sleep(10)
        }
        
        var isectionItems = [TVContentItem]()
        
        for i in 1...entries!.count {
            let id = "entry_" + String(i);
            
            let sectionIdentifier = TVContentIdentifier(identifier:  id + "_container", container: nil)
            let sectionItem = TVContentItem(contentIdentifier: sectionIdentifier!)
            
            sectionItem?.topShelfItems = [TVContentItem]()
            
            let itemIdentifier = TVContentIdentifier(identifier: id, container: nil)
            let item = TVContentItem(contentIdentifier: itemIdentifier!)
            item?.imageURL = NSURL(string: entries![i-1].ImgUrl)
            item?.imageShape = .Square
            item?.displayURL = NSURL(string: "RightMeowMeow://TopShelf/" + id);
            sectionItem?.topShelfItems?.append(item!);
            
            isectionItems.append(sectionItem!)
        }
        
        return isectionItems
    }
}

