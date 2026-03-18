# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Garmin Connect IQ watch face application written in Monkey C, targeting the Forerunner 245 Music (fr245m). Battery lasts 5-6 days, so battery level changes roughly once per hour. Priority order: **Battery efficiency > Readability > Features**.

## Build Commands

```bash
# Build for device
monkeyc -d fr245m -f monkey.jungle -o bin/my_watch.prg -y /path/to/developer_key -w

# VS Code: Ctrl+Shift+B or "Monkey C: Build for Device" → select fr245m
```

SDK requirement: Connect IQ SDK 8.3.0+, API level 3.3.0+. Binary should stay under 150KB.

## Testing

40 unit tests in `source/WatchLogicTests.mc` using a custom framework (`source/TestFramework.mc`). Tests run in the Garmin simulator console.

To run tests, add `runTests();` to `my_watchApp.mc` `initialize()`, then build and check simulator console output. Tests cover all pure logic functions (angle calculations, battery logic, coordinate conversions).

To add tests: put logic in `WatchLogic.mc`, write test methods in `WatchLogicTests.mc`, call them from `runAllTests()`. Available assertions: `assertEqual`, `assertApproxEqual`, `assertTrue`, `assertFalse`.

To run the simulator: open `my_watchApp.mc` in VS Code and press F5.

## Architecture

Three-layer separation of concerns:

- **App** (`my_watchApp.mc`): Entry point, lifecycle, settings changes
- **View** (`my_watchView.mc`): WatchFace lifecycle, sleep state tracking, delegates drawing
- **Drawers**: Rendering implementations, each self-contained
  - `StylishWatchDrawer.mc` — current active drawer (diamond hands, battery-colored ticks, burn tracking)
  - `TacticalWatchDrawer.mc` — tactical/military style (inactive)
  - `modernWatchDrawer.mc` — modern minimalist style (inactive)
  - `classicWatchDrawer.mc` — classic style (inactive)
- **Logic** (`WatchLogic.mc`): Pure static functions for calculations — no drawing code, fully unit-tested

The view creates a drawer and calls individual draw methods (tick marks, hands, date, etc.) on each update. Drawers cache system calls (battery, time) once per frame via `initializeContext()`.

## Monkey C Conventions

- Explicit type declarations on all variables (e.g., `var x as Number = 0`)
- Named constants for all magic numbers (drawing ratios, colors)
- No dynamic memory allocation in hot paths
- Cache expensive system calls per frame (battery level, time info)
- Disable second hand rendering during sleep mode to save battery
- Keep testable logic in `WatchLogic.mc`, separate from drawing code

## Settings

Three user-configurable settings defined in `my_watch-settings.json`: background color, foreground color, and military (24-hour) time format.
