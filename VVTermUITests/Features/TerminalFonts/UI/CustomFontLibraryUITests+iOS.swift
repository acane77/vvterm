#if os(iOS)
import XCTest

final class CustomFontLibraryUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    @MainActor
    func testFontSettingsOrderAndIntentBasedProGate() throws {
        let app = launchApp()
        defer { app.terminate() }

        openTerminalAppearance(in: app)

        let fontSize = app.sliders["vvterm.settings.appearance.fontSize"]
        let cjkFont = app.descendants(matching: .any)[
            "vvterm.settings.appearance.cjkFont"
        ]
        let customFonts = app.buttons["vvterm.settings.appearance.customFonts"]

        XCTAssertTrue(fontSize.waitForExistence(timeout: 5))
        XCTAssertTrue(cjkFont.waitForExistence(timeout: 5))
        XCTAssertTrue(customFonts.waitForExistence(timeout: 5))
        XCTAssertLessThan(fontSize.frame.minY, cjkFont.frame.minY)
        XCTAssertLessThan(cjkFont.frame.minY, customFonts.frame.minY)
        XCTAssertFalse(customFonts.label.localizedCaseInsensitiveContains("pro"))

        customFonts.tap()

        XCTAssertTrue(
            app.descendants(matching: .any)["vvterm.settings.customFonts.page"]
                .waitForExistence(timeout: 5)
        )

        let importFont = app.buttons["vvterm.settings.customFonts.import"]
        XCTAssertTrue(importFont.waitForExistence(timeout: 5))
        importFont.tap()

        XCTAssertFalse(app.alerts["Custom Fonts"].waitForExistence(timeout: 1))
        XCTAssertFalse(app.buttons["Upgrade to Pro"].exists)
    }

    @MainActor
    func testLibraryOpensFromTerminalAppearanceAndReturns() throws {
        let app = launchApp()
        defer { app.terminate() }

        openTerminalAppearance(in: app)

        let customFonts = app.buttons["vvterm.settings.appearance.customFonts"]
        XCTAssertTrue(scrollToHittable(customFonts, in: app))
        customFonts.tap()

        XCTAssertTrue(
            app.descendants(matching: .any)["vvterm.settings.customFonts.page"]
                .waitForExistence(timeout: 5)
        )
        let back = app.navigationBars["Custom Fonts"].buttons.firstMatch
        XCTAssertTrue(back.exists)
        back.tap()

        XCTAssertTrue(
            app.descendants(matching: .any)["vvterm.settings.page.terminalAppearance"]
                .waitForExistence(timeout: 5)
        )
    }

    @MainActor
    func testFreeCJKOptionsAreSingleRowProChoicesAndStayLocked() throws {
        let app = launchApp()
        defer { app.terminate() }

        openTerminalAppearance(in: app)

        let cjkFont = app.buttons["vvterm.settings.appearance.cjkFont"]
        XCTAssertTrue(cjkFont.waitForExistence(timeout: 5))
        XCTAssertTrue(cjkFont.isHittable)
        let initialSelection = cjkFont.label
        cjkFont.tap()

        let proOption = app.buttons
            .matching(NSPredicate(format: "label CONTAINS[c] %@", "(Pro)"))
            .firstMatch
        XCTAssertFalse(proOption.waitForExistence(timeout: 1))
        XCTAssertEqual(cjkFont.label, initialSelection)
    }

    @MainActor
    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.terminate()
        app.launchArguments = [
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US",
            "-hasSeenWelcome", "YES",
            "-iCloudSyncEnabled", "NO",
            "-security.privacyModeEnabled", "NO",
            "-security.fullAppLockEnabled", "NO",
            "-security.lockOnBackground", "NO",
        ]
        app.launch()
        return app
    }

    @MainActor
    private func openTerminalAppearance(in app: XCUIApplication) {
        let settings = app.buttons["vvterm.serverList.settings"]
        XCTAssertTrue(settings.waitForExistence(timeout: 10))
        settings.tap()

        let terminalAppearance = app.buttons["vvterm.settings.route.terminalAppearance"]
        XCTAssertTrue(terminalAppearance.waitForExistence(timeout: 8))
        terminalAppearance.tap()
    }

    @MainActor
    private func scrollToHittable(
        _ element: XCUIElement,
        in app: XCUIApplication
    ) -> Bool {
        if element.waitForExistence(timeout: 2), element.isHittable {
            return true
        }
        for _ in 0..<6 {
            app.swipeUp()
            if element.exists, element.isHittable {
                return true
            }
        }
        return false
    }
}
#endif
