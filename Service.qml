import QtQuick
import Quickshell
import Quickshell.Io

Item {
  id: root

  property var shell: null
  property var manifest: null

  readonly property string statePath: Quickshell.env("HOME") + "/.local/state/omarchy/notepad.json"
  property var notes: []
  property bool loaded: false
  readonly property int noteCount: notes.length

  function addNote(content) {
    var text = String(content || "").trim()
    if (!text) return false
    var next = notes.slice()
    next.unshift({ id: Date.now() + "-" + Math.floor(Math.random() * 1e6), text: text, created: Date.now() })
    notes = next
    scheduleSave()
    return true
  }

  function removeNote(id) {
    notes = notes.filter(function(n) { return n.id !== id })
    scheduleSave()
  }

  function clearAll() {
    notes = []
    scheduleSave()
  }

  function copyNote(text) {
    Quickshell.execDetached(["wl-copy", "--", String(text)])
  }

  FileView {
    id: stateFile
    path: root.statePath
    watchChanges: false
    atomicWrites: true
    printErrors: false
    onLoaded: root.hydrate(text())
    onLoadFailed: root.hydrate("")
  }

  Timer {
    id: saveTimer
    interval: 150
    onTriggered: stateFile.setText(JSON.stringify({ version: 1, notes: root.notes }, null, 2))
  }

  function scheduleSave() {
    if (loaded) saveTimer.restart()
  }

  function hydrate(raw) {
    if (loaded) return
    var data = {}
    try { data = JSON.parse(raw || "{}") } catch (e) {}
    var list = []
    if (data && Array.isArray(data.notes)) {
      for (var i = 0; i < data.notes.length; i++) {
        var n = data.notes[i]
        if (n && n.text) list.push({ id: String(n.id || Date.now() + "-" + i), text: String(n.text), created: Number(n.created) || Date.now() })
      }
    }
    notes = list
    loaded = true
  }
}
