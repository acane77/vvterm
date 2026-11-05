#if os(iOS)
import StoreKit
import SwiftUI
import UIKit

extension ProUpgradeSheet {
    func platformBody<Content: View>(
        sheetContent: Content,
        source: PaywallSource,
        onClose: @escaping () -> Void
    ) -> some View {
        NavigationStack {
            sheetContent
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack(spacing: 1) {
                            Text(source.paywallTitle)
                                .font(.headline)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                            Text(source.paywallSubtitle)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                    }

                    ToolbarItem(placement: .cancellationAction) {
                        SheetDismissButton(fallbackLabel: .icon, action: onClose)
                    }
                }
        }
        .adaptiveSoftScrollEdges()
    }

    func platformSheetLayout<Content: View, Footer: View>(
        content: Content,
        footer: Footer,
        source: PaywallSource
    ) -> some View {
        VStack(spacing: 0) {
            ScrollView {
                content
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 18)
            }
            .scrollIndicators(.visible)

            footer
        }
        .background(sheetBackground.ignoresSafeArea())
    }

    func openSubscriptionManagement() {
        showManageSubscription = true
    }

    var sheetBackground: Color {
        Color(uiColor: .systemGroupedBackground)
    }
}

var paywallTableGridColor: Color {
    Color.primary.opacity(0.10)
}

var paywallCardFillColor: Color {
    Color(uiColor: .secondarySystemGroupedBackground)
}

var paywallCardBorderColor: Color {
    Color.primary.opacity(0.10)
}

extension View {
    @ViewBuilder
    func manageSubscriptionsSheetCompat(
        isPresented: Binding<Bool>,
        subscriptionGroupID: String
    ) -> some View {
        if #available(iOS 17.0, *) {
            manageSubscriptionsSheet(
                isPresented: isPresented,
                subscriptionGroupID: subscriptionGroupID
            )
        } else {
            self
        }
    }
}
#endif
