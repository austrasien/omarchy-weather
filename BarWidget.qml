import QtQuick
import QtQuick.Window
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "omarchy.weather"

  function injectPanel() {
    var target = panelLoader.item
    if (!target) return
    if ("bar" in target) target.bar = root.bar
    if ("settings" in target) target.settings = root.settings
    if ("anchorItem" in target) target.anchorItem = button
    if ("hostWidget" in target) target.hostWidget = root
  }

  function refresh() {
    if (panelLoader.item && panelLoader.item.refresh) panelLoader.item.refresh()
  }

  function togglePanel() {
    if (panelLoader.item && panelLoader.item.toggle) panelLoader.item.toggle()
  }

  // Shape contract for shell.summon/hide/toggle routing (Bar.findPanelWidget
  // requires open/close/opened on the bar-widget root). Open maps to the
  // panel's hotkey path so summoning suppresses the center hover reveal,
  // matching what the old per-plugin IpcHandler did.
  readonly property bool opened: panelLoader.item ? panelLoader.item.opened === true : false

  function open() {
    if (panelLoader.item && panelLoader.item.openFromHotkey) panelLoader.item.openFromHotkey()
  }

  function close() {
    if (panelLoader.item && panelLoader.item.close) panelLoader.item.close()
  }

  // Forwarded so this widget can stand in for the panel as the bar's popout
  // identity: Bar.requestPopout prefers closeForPopoutSwitch over close, and
  // KeyboardPanel reads popoutSwitchClosing back off its owner.
  readonly property bool popoutSwitchClosing: panelLoader.item ? panelLoader.item.popoutSwitchClosing === true : false

  function closeForPopoutSwitch() {
    if (panelLoader.item) panelLoader.item.closeForPopoutSwitch()
  }

  visible: panelLoader.item && panelLoader.item.label !== ""
  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: injectPanel()
  onSettingsChanged: injectPanel()

  Loader {
    id: panelLoader
    active: true
    source: Qt.resolvedUrl("Panel.qml")
    visible: false
    onLoaded: {
      root.injectPanel()
      Qt.callLater(root.injectPanel)
    }
  }

  // Stock OpticalGlyph only recenters horizontally. Weather Icons sit
  // off-center in the em-square, and NativeRendering + a canvas smaller than
  // the line box then snaps that error differently at each monitor scale
  // and bar font. Place the painted ink on the canvas center, snapped to
  // device pixels, so it tracks both.
  Component {
    id: weatherGlyph

    Item {
      id: canvas

      readonly property real dpr: {
        var win = button.Window.window
        var ratio = win && win.screen ? win.screen.devicePixelRatio : Screen.devicePixelRatio
        return ratio > 0 ? ratio : 1
      }

      function snap(v) {
        return Math.round(v * canvas.dpr) / canvas.dpr
      }

      TextMetrics {
        id: metrics
        font.family: button.fontFamily
        font.pixelSize: Math.max(1, Math.round(button.fontSize))
        text: button.text
      }

      Text {
        id: glyph
        textFormat: Text.PlainText
        text: button.text
        color: button.foreground
        font.family: button.fontFamily
        font.pixelSize: Math.max(1, Math.round(button.fontSize))
        renderType: Text.NativeRendering
        rotation: button.textRotation
        x: {
          var tb = metrics.tightBoundingRect
          return canvas.snap(canvas.width / 2 - (tb.x + Math.max(1, tb.width) / 2))
        }
        y: {
          var tb = metrics.tightBoundingRect
          var inkCy = glyph.baselineOffset + tb.y + tb.height / 2
          return canvas.snap(canvas.height / 2 - inkCy)
        }
      }
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: panelLoader.item ? panelLoader.item.label : ""
    slotSize: Style.bar.statusSlot
    iconComponent: weatherGlyph
    tooltipText: ""

    onPressed: function(b) {
      if (!root.bar) return
      if (b === Qt.RightButton) root.bar.run("omarchy-notification-send \"$(omarchy-weather-status)\"")
      else if (b === Qt.MiddleButton) root.refresh()
      else root.togglePanel()
    }
  }
}
