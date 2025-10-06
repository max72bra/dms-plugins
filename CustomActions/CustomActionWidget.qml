import QtQuick
import Quickshell
import Quickshell.Io
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginComponent {
    id: root

    property string variantId: ""
    property var variantData: null

    property string displayIcon: variantData?.icon || "terminal"
    property string displayText: variantData?.displayText || ""
    property string displayCommand: variantData?.displayCommand || ""
    property string clickCommand: variantData?.clickCommand || ""
    property bool showIcon: variantData?.showIcon ?? true
    property bool showText: variantData?.showText ?? true

    property string currentOutput: displayText
    property bool isLoading: false

    onDisplayCommandChanged: {
        if (displayCommand) {
            Qt.callLater(refreshOutput)
        }
    }

    Component.onCompleted: {
        if (displayCommand) {
            Qt.callLater(refreshOutput)
        } else {
            currentOutput = displayText
        }
    }

    function refreshOutput() {
        if (!displayCommand) {
            currentOutput = displayText
            return
        }

        isLoading = true
        displayProcess.running = true
    }

    function executeClickAction() {
        if (!clickCommand) return

        isLoading = true
        clickProcess.running = true
    }

    Process {
        id: displayProcess
        command: ["bash", "-c", root.displayCommand]
        running: false

        stdout: SplitParser {
            onRead: data => {
                root.currentOutput = data.trim()
            }
        }

        onExited: (exitCode, exitStatus) => {
            root.isLoading = false
            if (exitCode !== 0) {
                console.warn("CustomActions: Display command failed with code", exitCode)
            }
        }
    }

    Process {
        id: clickProcess
        command: ["bash", "-c", root.clickCommand]
        running: false

        onExited: (exitCode, exitStatus) => {
            root.isLoading = false
            if (exitCode === 0) {
                if (root.displayCommand) {
                    root.refreshOutput()
                }
            } else {
                console.warn("CustomActions: Click command failed with code", exitCode)
            }
        }
    }

    pillClickAction: () => {
        if (clickCommand) {
            executeClickAction()
        }
    }

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.displayIcon
                size: Theme.iconSize - 6
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                visible: root.showIcon
            }

            StyledText {
                text: root.currentOutput || ""
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
                visible: root.showText && root.currentOutput
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DankIcon {
                name: root.displayIcon
                size: Theme.iconSize - 6
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.showIcon
            }

            StyledText {
                text: root.currentOutput || ""
                font.pixelSize: Theme.fontSizeSmall
                font.weight: Font.Medium
                color: Theme.surfaceText
                anchors.horizontalCenter: parent.horizontalCenter
                visible: root.showText && root.currentOutput
                rotation: 90
            }
        }
    }
}
