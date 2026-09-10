# Omarchy Weather

A **weather pill** for the [Omarchy](https://omarchy.org/) bar — same forecast popup as stock `omarchy.weather`, with the bar sun/moon **optically centered** so it stays aligned next to the clock and calendar at any monitor scale and bar font size.

> **⚡ Built for Omarchy:** drop-in bar widget (`austraz.weather`). Disable stock `omarchy.weather` so you only get one chip.

```
Bar glyph  →  click  →  location + forecast panel
```

Forked from Omarchy’s built-in weather widget; optical alignment by [austrasien](https://github.com/austrasien).

---

### ☕ Support the Project
If this saves you from a sun sitting 1 px too high every time you change DPI, a tip is always appreciated.

[![Donate via PayPal](https://img.shields.io/badge/Donate-PayPal-blue.svg?style=for-the-badge&logo=paypal)](https://paypal.me/austraz)

---

### 💬 Feedback & Community
Got a question, found a bug, or have a suggestion? Open an [**issue**](https://github.com/austrasien/omarchy-weather/issues).

---

## 🚀 Overview

Stock Omarchy draws Weather Icons in a 16 px canvas via `OpticalGlyph`, which only recenters **horizontally**. Those glyphs are not centered in the font em-square, so at HiDPI (1.25, 1.6, …) NativeRendering snaps the sun a pixel up or down relative to the clock. A magic `Translate { y: 1 }` only fits one scale.

This clone keeps the stock panel and places the **painted ink** on the canvas center, snapped to device pixels — so scale and font changes do not need a new nudge.

| | Stock `omarchy.weather` ❌ | This plugin ✅ |
| :--- | :--- | :--- |
| **Bar glyph** | Line-box centered (sun often high/low) | Ink-centered + device-pixel snap |
| **Change scale / font** | Recalibrate by hand | Follows `devicePixelRatio` and bar font |
| **Forecast panel** | Stock | Unchanged |

> **Note:** This is a user plugin under `~/.config/omarchy/plugins/austraz.weather/`. It does not patch `/usr/share/omarchy`.

## ✨ Key Features

### ☀️ Scale-aware bar icon
- Custom glyph renderer on `BarIconButton` (`iconComponent`).
- `TextMetrics.tightBoundingRect` + baseline → ink center.
- Positions snapped with `Screen.devicePixelRatio` (Hyprland monitor scale).

### 🌤 Stock weather panel
- Same wttr.in / Open-Meteo flow, location picker, and click / middle-click / right-click bindings as upstream.

## 🛠 Installation (Omarchy)

```sh
omarchy plugin add https://github.com/austrasien/omarchy-weather.git --enable
omarchy plugin disable omarchy.weather
omarchy restart shell
```

Already running a local `austraz.weather` clone? Point it at GitHub:

```sh
cd ~/.config/omarchy/plugins/austraz.weather
git init -b main   # if needed
git remote add origin https://github.com/austrasien/omarchy-weather.git
git fetch origin && git reset --hard origin/main
omarchy restart shell
```

### Update / remove

```sh
omarchy plugin update austraz.weather
omarchy plugin remove austraz.weather
# restore stock if you want:
# omarchy plugin enable omarchy.weather
```

### Requirements
- Omarchy Quattro shell (`omarchy-shell` / Quickshell)
- Network for forecast fetch (same as stock weather)

No sudo for the plugin itself.

## ⚖️ License

Licensed under the **MIT License**. Stock Omarchy weather panel remains © its upstream authors; this clone’s optical-alignment extras are MIT.

---
*Developed so the weather sun lines up with the clock after you change DPI.*
