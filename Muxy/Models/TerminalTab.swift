import Foundation

@MainActor
@Observable
final class TerminalTab: Identifiable {
    let id = UUID()
    var title: String
    var rootNode: SplitNode
    var focusedPaneID: UUID?

    init(title: String = "Terminal", pane: TerminalPaneState) {
        self.title = title
        self.rootNode = .pane(pane)
        self.focusedPaneID = pane.id
    }

    var focusedPane: TerminalPaneState? {
        guard let focusedPaneID else { return nil }
        return rootNode.findPane(id: focusedPaneID)
    }

    func splitFocusedPane(direction: SplitDirection, projectPath: String) {
        guard let focusedPaneID else { return }
        let newPane = TerminalPaneState(projectPath: projectPath)
        rootNode = rootNode.splitting(paneID: focusedPaneID, direction: direction, newPane: newPane)
        self.focusedPaneID = newPane.id
    }

    func closeFocusedPane() {
        guard let focusedPaneID else { return }
        if let newRoot = rootNode.removing(paneID: focusedPaneID) {
            rootNode = newRoot
            self.focusedPaneID = newRoot.allPanes().first?.id
        }
    }

    func focusNextPane() {
        let panes = rootNode.allPanes()
        guard panes.count > 1, let currentID = focusedPaneID else { return }
        guard let index = panes.firstIndex(where: { $0.id == currentID }) else { return }
        let nextIndex = (index + 1) % panes.count
        focusedPaneID = panes[nextIndex].id
    }

    func focusPreviousPane() {
        let panes = rootNode.allPanes()
        guard panes.count > 1, let currentID = focusedPaneID else { return }
        guard let index = panes.firstIndex(where: { $0.id == currentID }) else { return }
        let prevIndex = (index - 1 + panes.count) % panes.count
        focusedPaneID = panes[prevIndex].id
    }
}
