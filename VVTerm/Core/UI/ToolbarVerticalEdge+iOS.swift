#if os(iOS)
import SwiftUI

extension EnvironmentValues {
    /// The iOS 27.0 SDK does not declare this value. Call sites treat `nil` as the
    /// horizontal toolbar. Remove this shim when the SDK provides the property.
    var toolbarVerticalEdge: VerticalEdge? { nil }
}
#endif
