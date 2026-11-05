#if os(iOS)
import SwiftUI

struct StatsFoldAwareGrid<Content: View>: View {
    let content: (ClosedRange<CGFloat>?) -> Content

    var body: some View {
        // GeometryProxy.reservedRegions is not in the iOS 27.0 SDK, so the grid
        // uses the same undivided layout as older systems.
        content(nil)
    }
}
#endif
