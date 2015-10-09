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
        var isectionItems = [TVContentItem]()
        
        for i in 1...5 {
            let id = "category_" + String(i);

            let sectionIdentifier = TVContentIdentifier(identifier:  id + "_container", container: nil)
            let sectionItem = TVContentItem(contentIdentifier: sectionIdentifier!)
            sectionItem?.title = id;
            sectionItem?.topShelfItems = [TVContentItem]()
            
            let itemIdentifier = TVContentIdentifier(identifier: id, container: nil)
            let item = TVContentItem(contentIdentifier: itemIdentifier!)
            item?.imageURL = NSBundle.mainBundle().URLForResource("/\(id).jpg", withExtension: nil)
            item?.imageShape = .Square
            item?.displayURL = NSURL(string: "RightMeowMeow://TopShelf/" + id);
            sectionItem?.topShelfItems?.append(item!);
            
            isectionItems.append(sectionItem!)
        }
        
        return isectionItems
    }
    
    var topShelfItems2: [TVContentItem] {
        var isectionItems = [TVContentItem]()
        let sectionIdentifier = TVContentIdentifier(identifier: "CategoryContainer", container: nil)
        let sectionItem = TVContentItem(contentIdentifier: sectionIdentifier!)
        
        var contentItems = [TVContentItem]()
        for i in 1...5 {
            let id = "category_" + String(i);
            let itemIdentifier = TVContentIdentifier(identifier: id, container: nil)
            let item = TVContentItem(contentIdentifier: itemIdentifier!)
            
            item?.imageURL = NSBundle.mainBundle().URLForResource("/\(id).jpg", withExtension: nil)
            item?.imageShape = .Square
            item?.title = id;
            
            item?.displayURL = NSURL(string: "RightMeowMeow://TopShelf/" + id);
            contentItems.append(item!)
        }
        
        sectionItem?.topShelfItems=contentItems;
        
        isectionItems.append(sectionItem!)
        return isectionItems
    }
}

