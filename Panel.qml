import QtQuick
import Quickshell
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "zakarch.notepad"
  ipcTarget: "zakarch.notepad.panel"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root
  readonly property var svc: bar && bar.shell ? bar.shell.serviceFor("zakarch.notepad") : null

  readonly property color fg: bar ? bar.foreground : Color.foreground
  readonly property string ff: bar ? bar.fontFamily : Style.font.family
  property string copiedId: ""

  function tint(a) { return Qt.rgba(fg.r, fg.g, fg.b, a) }

  function submit() {
    if (svc && svc.addNote(input.text)) input.text = ""
  }

  Timer { id: copiedTimer; interval: 1200; onTriggered: root.copiedId = "" }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: input
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(mainCol.implicitHeight, Style.space(560))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      blocked: input.activeFocus
      onCloseRequested: root.close()

      Column {
        id: mainCol
        width: parent.width
        spacing: Style.space(10)

        // Input
        Rectangle {
          width: parent.width
          height: Math.max(Style.space(44), input.contentHeight + Style.space(24))
          radius: Style.cornerRadius
          color: root.tint(0.05)
          border.width: 1
          border.color: input.activeFocus ? Color.accent : root.tint(0.12)
          Behavior on border.color { ColorAnimation { duration: 150 } }

          TextInput {
            id: input
            anchors.left: parent.left
            anchors.right: addBtn.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: Style.space(14)
            anchors.rightMargin: Style.space(8)
            color: root.fg
            font.family: root.ff
            font.pixelSize: Style.font.body
            wrapMode: TextInput.Wrap
            selectByMouse: true
            clip: true
            onAccepted: root.submit()
            Keys.onEscapePressed: root.close()

            Text {
              visible: !input.text
              text: "Write a note…"
              color: root.tint(0.4)
              font: input.font
            }
          }

          Rectangle {
            id: addBtn
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: Style.space(8)
            width: Style.space(30)
            height: Style.space(30)
            radius: width / 2
            color: input.text.trim() ? Color.accent : root.tint(0.08)
            opacity: addArea.containsMouse ? 0.85 : 1
            Behavior on color { ColorAnimation { duration: 150 } }

            Text {
              anchors.centerIn: parent
              text: "󰐕"
              color: input.text.trim() ? Color.background : root.tint(0.5)
              font.family: root.ff
              font.pixelSize: Style.font.body
            }
            MouseArea { id: addArea; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.submit() }
          }
        }

        // Empty state
        Text {
          visible: !root.svc || root.svc.noteCount === 0
          width: parent.width
          topPadding: Style.space(24)
          bottomPadding: Style.space(24)
          horizontalAlignment: Text.AlignHCenter
          text: "No notes yet"
          color: root.tint(0.4)
          font.family: root.ff
          font.pixelSize: Style.font.body
        }

        // List
        Flickable {
          visible: root.svc && root.svc.noteCount > 0
          width: parent.width
          height: Math.min(list.implicitHeight, Style.space(400))
          contentHeight: list.implicitHeight
          clip: true
          boundsBehavior: Flickable.StopAtBounds

          Column {
            id: list
            width: parent.width
            spacing: Style.space(6)

            Repeater {
              model: root.svc ? root.svc.notes : []

              delegate: Rectangle {
                id: card
                required property var modelData
                readonly property bool copied: root.copiedId === modelData.id
                width: list.width
                height: noteText.implicitHeight + Style.space(24)
                radius: Style.cornerRadius
                color: cardArea.containsMouse ? root.tint(0.08) : root.tint(0.04)
                Behavior on color { ColorAnimation { duration: 120 } }

                MouseArea {
                  id: cardArea
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: Qt.PointingHandCursor
                  onClicked: {
                    root.svc.copyNote(card.modelData.text)
                    root.copiedId = card.modelData.id
                    copiedTimer.restart()
                  }
                }

                Text {
                  id: noteText
                  anchors.left: parent.left
                  anchors.right: actions.left
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.leftMargin: Style.space(14)
                  anchors.rightMargin: Style.space(8)
                  text: card.modelData.text
                  color: root.fg
                  font.family: root.ff
                  font.pixelSize: Style.font.body
                  wrapMode: Text.Wrap
                  maximumLineCount: 6
                  elide: Text.ElideRight
                }

                Row {
                  id: actions
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  anchors.rightMargin: Style.space(10)
                  spacing: Style.space(4)

                  Text {
                    visible: card.copied
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Copied"
                    color: Color.accent
                    font.family: root.ff
                    font.pixelSize: Style.font.caption
                  }

                  Rectangle {
                    width: Style.space(26)
                    height: Style.space(26)
                    radius: width / 2
                    color: copyArea.containsMouse ? Qt.rgba(Color.accent.r, Color.accent.g, Color.accent.b, 0.2) : "transparent"
                    Text {
                      anchors.centerIn: parent
                      text: card.copied ? "󰄬" : "󰆏"
                      color: card.copied || copyArea.containsMouse ? Color.accent : root.tint(0.5)
                      font.family: root.ff
                      font.pixelSize: Style.font.body
                    }
                    MouseArea {
                      id: copyArea
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: {
                        root.svc.copyNote(card.modelData.text)
                        root.copiedId = card.modelData.id
                        copiedTimer.restart()
                      }
                    }
                  }

                  Rectangle {
                    visible: cardArea.containsMouse || delArea.containsMouse || copyArea.containsMouse
                    width: Style.space(26)
                    height: Style.space(26)
                    radius: width / 2
                    color: delArea.containsMouse ? Qt.rgba(Color.urgent.r, Color.urgent.g, Color.urgent.b, 0.2) : "transparent"
                    Text {
                      anchors.centerIn: parent
                      text: "󰆴"
                      color: delArea.containsMouse ? Color.urgent : root.tint(0.5)
                      font.family: root.ff
                      font.pixelSize: Style.font.body
                    }
                    MouseArea {
                      id: delArea
                      anchors.fill: parent
                      hoverEnabled: true
                      cursorShape: Qt.PointingHandCursor
                      onClicked: root.svc.removeNote(card.modelData.id)
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
