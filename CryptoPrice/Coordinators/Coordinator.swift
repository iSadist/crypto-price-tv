import Foundation
import UIKit

public protocol JSVCoordinator {
    var navigationController: UINavigationController? { get }

    init(navigationController: UINavigationController)
}
