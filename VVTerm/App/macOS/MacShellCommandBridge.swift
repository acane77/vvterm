//
//  MacShellCommandBridge.swift
//  VVTerm
//
//  Republishes commands from AppKit-hosted panes to scene Commands.
//

#if os(macOS)
import Combine
import Foundation

enum MacShellCommandID: Equatable {
    case openNewTab
    case closeSelectedTab
    case selectPreviousTab
    case selectNextTab
    case selectTab(Int)
    case performSplit(TerminalSplitCommand)
}

struct MacShellCommandSnapshot: Equatable {
    var ownerId: String?
    var activeServerId: UUID?
    var activePaneId: UUID?
    var hasTabActions = false
    var hasSplitActions = false

    static let inactive = MacShellCommandSnapshot()
}

@MainActor
final class MacShellCommandDispatcher {
    private var ownerId: String?
    private var tabActions: ServerViewTabActions?
    private var splitActions: TerminalSplitActions?

    func install(
        ownerId: String,
        tabActions: ServerViewTabActions?,
        splitActions: TerminalSplitActions?
    ) {
        self.ownerId = ownerId
        self.tabActions = tabActions
        self.splitActions = splitActions
    }

    func clear(ownerId: String) {
        guard self.ownerId == ownerId else { return }
        self.ownerId = nil
        tabActions = nil
        splitActions = nil
    }

    func dispatch(_ command: MacShellCommandID) {
        switch command {
        case .openNewTab:
            tabActions?.openNew()
        case .closeSelectedTab:
            tabActions?.closeSelected()
        case .selectPreviousTab:
            tabActions?.selectPrevious()
        case .selectNextTab:
            tabActions?.selectNext()
        case .selectTab(let index):
            tabActions?.selectIndex(index)
        case .performSplit(let command):
            splitActions?.perform(command)
        }
    }

    func isSplitEnabled(_ command: TerminalSplitCommand) -> Bool {
        splitActions?.isEnabled(command) == true
    }

    var isSplitZoomed: Bool {
        splitActions?.isZoomed() == true
    }
}

@MainActor
final class MacShellCommandBridge: ObservableObject {
    @Published private(set) var snapshot: MacShellCommandSnapshot = .inactive
    let dispatcher = MacShellCommandDispatcher()

    init() {}

    var serverViewTabActions: ServerViewTabActions? {
        guard snapshot.hasTabActions else { return nil }
        return ServerViewTabActions(
            openNew: { [dispatcher] in dispatcher.dispatch(.openNewTab) },
            closeSelected: { [dispatcher] in dispatcher.dispatch(.closeSelectedTab) },
            selectPrevious: { [dispatcher] in dispatcher.dispatch(.selectPreviousTab) },
            selectNext: { [dispatcher] in dispatcher.dispatch(.selectNextTab) },
            selectIndex: { [dispatcher] index in dispatcher.dispatch(.selectTab(index)) }
        )
    }

    var splitActions: TerminalSplitActions? {
        guard snapshot.hasSplitActions else { return nil }
        return TerminalSplitActions(
            perform: { [dispatcher] command in dispatcher.dispatch(.performSplit(command)) },
            isEnabled: { [dispatcher] command in dispatcher.isSplitEnabled(command) },
            isZoomed: { [dispatcher] in dispatcher.isSplitZoomed }
        )
    }

    var activeServerId: UUID? { snapshot.activeServerId }
    var activePaneId: UUID? { snapshot.activePaneId }

    func update(
        ownerId: String,
        serverViewTabActions: ServerViewTabActions?,
        splitActions: TerminalSplitActions?,
        activeServerId: UUID?,
        activePaneId: UUID?
    ) {
        dispatcher.install(
            ownerId: ownerId,
            tabActions: serverViewTabActions,
            splitActions: splitActions
        )
        snapshot.ownerId = ownerId
        snapshot.activeServerId = activeServerId
        snapshot.activePaneId = activePaneId
        snapshot.hasTabActions = serverViewTabActions != nil
        snapshot.hasSplitActions = splitActions != nil
    }

    func clear(ownerId: String) {
        guard snapshot.ownerId == ownerId else { return }
        dispatcher.clear(ownerId: ownerId)
        snapshot.ownerId = nil
        snapshot.activeServerId = nil
        snapshot.activePaneId = nil
        snapshot.hasTabActions = false
        snapshot.hasSplitActions = false
    }
}
#endif
