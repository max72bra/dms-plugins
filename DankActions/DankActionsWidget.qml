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
    property string middleClickCommand: variantData?.middleClickCommand || ""
    property string rightClickCommand: variantData?.rightClickCommand || ""
    property int updateInterval: variantData?.updateInterval || 0
    property bool showIcon: variantData?.showIcon ?? true
    property bool showText: variantData?.showText ?? true

    property string currentOutput: displayText
    property bool isLoading: false

    onDisplayCommandChanged: {
        if (displayCommand) {
            Qt.callLater(refreshOutput)
        }
    }

    onUpdateIntervalChanged: {
        updateTimer.restart()
    }

    Component.onCompleted: {
        if (displayCommand) {
            Qt.callLater(refreshOutput)
        } else {
            currentOutput = displayText
        }
        if (updateInterval > 0) {
            updateTimer.start()
        }
    }

    Timer {
        id: updateTimer
        interval: root.updateInterval * 1000
        repeat: true
        running: false
        onTriggered: {
            if (root.displayCommand) {
                root.refreshOutput()
            }
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

    function executeCommand(command) {
        if (!command) return

        isLoading = true
        actionProcess.command = ["sh", "-c", command]
        actionProcess.running = true
    }

    Process {
        id: displayProcess
        command: ["sh", "-c", root.displayCommand]
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
        id: actionProcess
        command: ["sh", "-c", ""]
        running: false

        onExited: (exitCode, exitStatus) => {
            root.isLoading = false
            if (exitCode === 0) {
                if (root.displayCommand) {
                    root.refreshOutput()
                }
            } else {
                console.warn("CustomActions: Action command failed with code", exitCode)
            }
        }
    }

    pillClickAction: () => {
        if (root.clickCommand) {
            root.executeCommand(root.clickCommand)
        }
    }

    horizontalBarPill: Component {
        MouseArea {
            implicitWidth: contentRow.implicitWidth
            implicitHeight: contentRow.implicitHeight
            acceptedButtons: Qt.MiddleButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: (mouse) => {
                if (mouse.button === Qt.MiddleButton && root.middleClickCommand) {
                    root.executeCommand(root.middleClickCommand)
                } else if (mouse.button === Qt.RightButton && root.rightClickCommand) {
                    root.executeCommand(root.rightClickCommand)
                }
            }

            Row {
                id: contentRow
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
    }

    verticalBarPill: Component {
        MouseArea {
            implicitWidth: contentColumn.implicitWidth
            implicitHeight: contentColumn.implicitHeight
            acceptedButtons: Qt.MiddleButton | Qt.RightButton
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor

            onClicked: (mouse) => {
                if (mouse.button === Qt.MiddleButton && root.middleClickCommand) {
                    root.executeCommand(root.middleClickCommand)
                } else if (mouse.button === Qt.RightButton && root.rightClickCommand) {
                    root.executeCommand(root.rightClickCommand)
                }
            }

            Column {
                id: contentColumn
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
}
