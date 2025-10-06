import QtQuick
import QtQuick.Controls
import qs.Common
import qs.Services
import qs.Widgets
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "customActions"

    onVariantsChanged: {
        variantsModel.clear()
        for (var i = 0; i < variants.length; i++) {
            variantsModel.append(variants[i])
        }
    }

    StyledText {
        width: parent.width
        text: "Custom Action Manager"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Create custom widgets that execute commands and display dynamic output"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    StyledRect {
        width: parent.width
        height: addActionColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: addActionColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
                text: "Create New Action"
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            Row {
                width: parent.width
                spacing: Theme.spacingM

                Column {
                    width: (parent.width - Theme.spacingM) / 2
                    spacing: Theme.spacingXS

                    StyledText {
                        text: "Variant Name *"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }

                    DankTextField {
                        id: nameField
                        width: parent.width
                        placeholderText: "e.g., Power Profile"
                    }
                }

                Column {
                    width: (parent.width - Theme.spacingM) / 2
                    spacing: Theme.spacingXS

                    StyledText {
                        text: "Icon Name"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }

                    DankTextField {
                        id: iconField
                        width: parent.width
                        placeholderText: "e.g., power_settings_new"
                    }
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingXS

                StyledText {
                    text: "Static Display Text (optional)"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

                DankTextField {
                    id: displayTextField
                    width: parent.width
                    placeholderText: "Text to show (or leave empty if using command output)"
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingXS

                StyledText {
                    text: "Display Command (optional)"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

                DankTextField {
                    id: displayCommandField
                    width: parent.width
                    placeholderText: 'e.g., echo "Hello World" or powerprofilesctl get'
                }

                StyledText {
                    text: "Command output will replace static text. Runs on widget load."
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingXS

                StyledText {
                    text: "Click Command (optional)"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                }

                DankTextField {
                    id: clickCommandField
                    width: parent.width
                    placeholderText: "e.g., notify-send 'Clicked!' or cycle-power-profile.sh"
                }

                StyledText {
                    text: "Command to run when widget is clicked. After completion, display command refreshes."
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }

            Row {
                width: parent.width
                spacing: Theme.spacingL

                Column {
                    spacing: Theme.spacingXS

                    StyledText {
                        text: "Show Icon"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }

                    DankToggle {
                        id: showIconToggle
                        checked: true
                    }
                }

                Column {
                    spacing: Theme.spacingXS

                    StyledText {
                        text: "Show Text"
                        font.pixelSize: Theme.fontSizeSmall
                        color: Theme.surfaceVariantText
                    }

                    DankToggle {
                        id: showTextToggle
                        checked: true
                    }
                }
            }

            DankButton {
                text: "Create Action"
                iconName: "add"
                onClicked: {
                    if (!nameField.text) {
                        ToastService.showError("Please enter a variant name")
                        return
                    }

                    var variantConfig = {
                        icon: iconField.text || "terminal",
                        displayText: displayTextField.text || "",
                        displayCommand: displayCommandField.text || "",
                        clickCommand: clickCommandField.text || "",
                        showIcon: showIconToggle.checked,
                        showText: showTextToggle.checked
                    }

                    createVariant(nameField.text, variantConfig)
                    ToastService.showInfo("Action created: " + nameField.text)

                    nameField.text = ""
                    iconField.text = ""
                    displayTextField.text = ""
                    displayCommandField.text = ""
                    clickCommandField.text = ""
                    showIconToggle.checked = true
                    showTextToggle.checked = true
                }
            }
        }
    }

    StyledRect {
        width: parent.width
        height: Math.max(200, variantsColumn.implicitHeight + Theme.spacingL * 2)
        radius: Theme.cornerRadius
        color: Theme.surfaceContainerHigh

        Column {
            id: variantsColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            StyledText {
                text: "Existing Actions"
                font.pixelSize: Theme.fontSizeMedium
                font.weight: Font.Medium
                color: Theme.surfaceText
            }

            ListView {
                width: parent.width
                height: Math.max(100, contentHeight)
                clip: true
                spacing: Theme.spacingXS

                model: ListModel {
                    id: variantsModel
                }

                delegate: StyledRect {
                    required property var model
                    width: ListView.view.width
                    height: variantColumn.implicitHeight + Theme.spacingM * 2
                    radius: Theme.cornerRadius
                    color: variantMouseArea.containsMouse ? Theme.surfaceContainerHighest : Theme.surfaceContainer

                    Column {
                        id: variantColumn
                        anchors.fill: parent
                        anchors.margins: Theme.spacingM
                        spacing: Theme.spacingXS

                        Row {
                            width: parent.width
                            spacing: Theme.spacingM

                            Item {
                                width: Theme.iconSize
                                height: Theme.iconSize
                                anchors.verticalCenter: parent.verticalCenter

                                DankIcon {
                                    anchors.centerIn: parent
                                    name: model.icon || "terminal"
                                    size: Theme.iconSize
                                    color: Theme.surfaceText
                                }
                            }

                            Column {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 2
                                width: parent.width - Theme.iconSize - deleteButton.width - Theme.spacingM * 3

                                StyledText {
                                    text: model.name || "Unnamed"
                                    font.pixelSize: Theme.fontSizeMedium
                                    font.weight: Font.Medium
                                    color: Theme.surfaceText
                                    width: parent.width
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    text: {
                                        var parts = []
                                        if (model.displayText) parts.push("Text: " + model.displayText)
                                        if (model.displayCommand) parts.push("Cmd: " + model.displayCommand)
                                        return parts.join(" | ") || "No display config"
                                    }
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                    elide: Text.ElideRight
                                }

                                StyledText {
                                    text: model.clickCommand ? "Click: " + model.clickCommand : "No click action"
                                    font.pixelSize: Theme.fontSizeSmall
                                    color: Theme.surfaceVariantText
                                    width: parent.width
                                    elide: Text.ElideRight
                                }
                            }

                            Rectangle {
                                id: deleteButton
                                width: 32
                                height: 32
                                radius: 16
                                color: deleteArea.containsMouse ? Theme.error : "transparent"
                                anchors.verticalCenter: parent.verticalCenter

                                DankIcon {
                                    anchors.centerIn: parent
                                    name: "delete"
                                    size: 16
                                    color: deleteArea.containsMouse ? Theme.onError : Theme.surfaceVariantText
                                }

                                MouseArea {
                                    id: deleteArea
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        removeVariant(model.id)
                                        ToastService.showInfo("Action removed: " + model.name)
                                    }
                                }
                            }
                        }
                    }

                    MouseArea {
                        id: variantMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        propagateComposedEvents: true
                    }
                }

                StyledText {
                    anchors.centerIn: parent
                    text: "No actions created yet"
                    font.pixelSize: Theme.fontSizeSmall
                    color: Theme.surfaceVariantText
                    visible: variantsModel.count === 0
                }
            }
        }
    }

    StyledRect {
        width: parent.width
        height: examplesColumn.implicitHeight + Theme.spacingL * 2
        radius: Theme.cornerRadius
        color: Theme.surface

        Column {
            id: examplesColumn
            anchors.fill: parent
            anchors.margins: Theme.spacingL
            spacing: Theme.spacingM

            Row {
                spacing: Theme.spacingM

                DankIcon {
                    name: "lightbulb"
                    size: Theme.iconSize
                    color: Theme.primary
                    anchors.verticalCenter: parent.verticalCenter
                }

                StyledText {
                    text: "Usage Examples"
                    font.pixelSize: Theme.fontSizeMedium
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Column {
                width: parent.width
                spacing: Theme.spacingS

                StyledText {
                    text: "• Power Profile Cycler"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
                StyledText {
                    text: "Display: powerprofilesctl get\nClick: powerprofilesctl set $(powerprofilesctl list | grep -v \"$(powerprofilesctl get)\" | head -1)"
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: "monospace"
                    color: Theme.surfaceVariantText
                    wrapMode: Text.Wrap
                    width: parent.width
                    leftPadding: Theme.spacingM
                }

                StyledText {
                    text: "• System Uptime"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
                StyledText {
                    text: "Display: uptime -p | sed 's/up //'\nClick: notify-send \"Uptime\" \"$(uptime -p)\""
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: "monospace"
                    color: Theme.surfaceVariantText
                    wrapMode: Text.Wrap
                    width: parent.width
                    leftPadding: Theme.spacingM
                }

                StyledText {
                    text: "• Custom Greeting"
                    font.pixelSize: Theme.fontSizeSmall
                    font.weight: Font.Medium
                    color: Theme.surfaceText
                }
                StyledText {
                    text: "Display: echo \"Hello $(whoami)!\"\nClick: notify-send \"Hi!\" \"Welcome back!\""
                    font.pixelSize: Theme.fontSizeSmall
                    font.family: "monospace"
                    color: Theme.surfaceVariantText
                    wrapMode: Text.Wrap
                    width: parent.width
                    leftPadding: Theme.spacingM
                }
            }

            StyledText {
                text: "After creating actions, add them to your bar from Bar Settings → Add Widget"
                font.pixelSize: Theme.fontSizeSmall
                color: Theme.surfaceVariantText
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }
    }
}
