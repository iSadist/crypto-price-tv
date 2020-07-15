//
//  ContentProvider.swift
//  TopShelf
//
//  Created by Jan Svensson on 2020-07-15.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import TVServices

class ContentProvider: TVTopShelfContentProvider {

    override func loadTopShelfContent(completionHandler: @escaping (TVTopShelfContent?) -> Void) {
        
        var items = [TVTopShelfItem]()
        
        for index in 1...3 {
            let item = TVTopShelfItem(identifier: UUID().uuidString)
            let url = Bundle.main.url(forResource: "\(index)", withExtension: "jpg")
            item.setImageURL(url, for: .screenScale1x)
            item.setImageURL(url, for: .screenScale2x)
            
            let displayAction = TVTopShelfAction(url: URL(string: "CryptoPrice://display/\(index)")!)
            item.displayAction = displayAction
            
            items.append(item)
        }

        let content = TVTopShelfInsetContent(items: items)
        let sectionContent = TVTopShelfSectionedContent(sections: [])
        
        // Fetch content and call completionHandler
        completionHandler(content)
    }
}

