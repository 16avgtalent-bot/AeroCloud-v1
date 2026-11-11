import Foundation
import SwiftUI

@main
struct AeroCloudApp: App {
    var body: some Scene {
        WindowGroup {
            #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("-designGallery") {
                    DesignSystemGalleryView()
                } else {
                    AppShell()
                }
            #else
                AppShell()
            #endif
        }
    }
}
