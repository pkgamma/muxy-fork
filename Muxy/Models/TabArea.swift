import Foundation

@MainActor
@Observable
final class TabArea: Identifiable {
    let id = UUID()
    let projectPath: String
    var tabs: [TerminalTab] = []
    var activeTabID: UUID?
    private var tabHistory: [UUID] = []

    init(projectPath: String) {
        self.projectPath = projectPath
        let tab = TerminalTab(pane: TerminalPaneState(projectPath: projectPath))
        tabs.append(tab)
        activeTabID = tab.id
    }

    var activeTab: TerminalTab? {
        guard let activeTabID else { return nil }
        return tabs.first { $0.id == activeTabID }
    }

    func createTab() {
        let tab = TerminalTab(pane: TerminalPaneState(projectPath: projectPath))
        tabs.append(tab)
        if let current = activeTabID {
            tabHistory.append(current)
        }
        activeTabID = tab.id
    }

    func closeTab(_ tabID: UUID) {
        if let tab = tabs.first(where: { $0.id == tabID }) {
            TerminalViewRegistry.shared.removeView(for: tab.pane.id)
        }
        tabs.removeAll { $0.id == tabID }
        tabHistory.removeAll { $0 == tabID }
        guard activeTabID == tabID else { return }
        let validIDs = Set(tabs.map(\.id))
        while let prev = tabHistory.popLast() {
            if validIDs.contains(prev) {
                activeTabID = prev
                return
            }
        }
        activeTabID = tabs.last?.id
    }

    func selectTab(_ tabID: UUID) {
        if let current = activeTabID, current != tabID {
            tabHistory.append(current)
        }
        activeTabID = tabID
    }

    func selectTabByIndex(_ index: Int) {
        guard index >= 0, index < tabs.count else { return }
        selectTab(tabs[index].id)
    }
}
