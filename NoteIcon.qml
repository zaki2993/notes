import QtQuick
import QtQuick.Shapes

// Bar glyph: a page with one written line per note (up to three).
Item {
  id: root

  property int count: 0
  property color color: "#888888"

  readonly property real s: width / 16
  readonly property var lineEnds: [11, 11, 9]

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
      strokeColor: root.color
      strokeWidth: 1.4 * root.s
      fillColor: "transparent"
      PathRectangle { x: 3 * root.s; y: 1.5 * root.s; width: 10 * root.s; height: 13 * root.s; radius: 2 * root.s }
    }
  }

  Repeater {
    model: 3
    Rectangle {
      required property int index
      x: 5.5 * root.s
      y: (4.6 + index * 2.6) * root.s
      width: (root.lineEnds[index] - 5.5) * root.s
      height: 1.3 * root.s
      radius: height / 2
      color: root.color
      opacity: index < root.count ? 1 : 0.25
    }
  }
}
