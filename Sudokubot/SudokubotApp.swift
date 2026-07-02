import SwiftUI
import UIKit

@objc class RootViewControllerFactory: NSObject {
    @objc static func makeRootViewController() -> UIViewController {
        UIHostingController(rootView: HomeView())
    }
}
