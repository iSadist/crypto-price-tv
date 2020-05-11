//
//  Storyboarded.swift
//
//  A protocol that allows usage of storyboards with view controllers
//  without relying on segues with deep coupling.
//

import UIKit

public protocol Storyboarded {
    /// Create the view controller from the storyboard "Main" where the view controller has the
    /// same name as the class
    static func instantiate() -> Self
}

public extension Storyboarded where Self: UIViewController {
    static func instantiate() -> Self {
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
