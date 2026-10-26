import QtQuick
import QtQuick.Shapes

// Bar glyph: a sticky note with a folded corner and one written line per note (up to three).
Item {
  id: root

  property int count: 0
  property color color: "#888888"

  readonly property real s: width / 16
  readonly property var lineEnds: [11.5, 11.5, 8]

  Shape {
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
      strokeColor: root.color
      strokeWidth: 1.4 * root.s
      fillColor: "transparent"
      joinStyle: ShapePath.RoundJoin
      capStyle: ShapePath.RoundCap
      startX: 4 * root.s; startY: 2 * root.s
      PathLine { x: 12 * root.s; y: 2 * root.s }
      PathQuad { x: 14 * root.s; y: 4 * root.s; controlX: 14 * root.s; controlY: 2 * root.s }
      PathLine { x: 14 * root.s; y: 10 * root.s }
      PathLine { x: 10 * root.s; y: 14 * root.s }
      PathLine { x: 4 * root.s; y: 14 * root.s }
      PathQuad { x: 2 * root.s; y: 12 * root.s; controlX: 2 * root.s; controlY: 14 * root.s }
      PathLine { x: 2 * root.s; y: 4 * root.s }
      PathQuad { x: 4 * root.s; y: 2 * root.s; controlX: 2 * root.s; controlY: 2 * root.s }
      // folded corner
      PathMove { x: 14 * root.s; y: 10 * root.s }
      PathLine { x: 11.5 * root.s; y: 10 * root.s }
      PathQuad { x: 10 * root.s; y: 11.5 * root.s; controlX: 10 * root.s; controlY: 10 * root.s }
      PathLine { x: 10 * root.s; y: 14 * root.s }
    }
  }

  Repeater {
    model: 3
    Rectangle {
      required property int index
      x: 4.5 * root.s
      y: (4.8 + index * 2.6) * root.s
      width: (root.lineEnds[index] - 4.5) * root.s
      height: 1.3 * root.s
      radius: height / 2
      color: root.color
      opacity: index < root.count ? 1 : 0.25
    }
  }
}
