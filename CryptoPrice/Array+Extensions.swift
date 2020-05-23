//
//  Array+Extensions.swift
//  CryptoPrice
//
//  Created by Jan Svensson on 2020-05-23.
//  Copyright © 2020 Jan Svensson. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func replaceFirst(element: Element, with new: Element) {
        if let index = firstIndex(of: element) {
            remove(at: index)
            insert(new, at: index)
        }
    }
}
