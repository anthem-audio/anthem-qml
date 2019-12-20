# Anthem

Anthem is a cross-platform digital audio workstation. It is written in Rust, QML, and C++.

## Architecture

Anthem has two main parts: the engine and the UI. The engine handles sequencing and audio processing, and the UI handles user interaction and data display.

These components run in separate processes and communicate with each other over `stdin` and `stdout`.

## Engine

(insert engine info here)

## UI

### Main page: [UI](ui.md)

### Basic UI components
- [Menu](BasicComponents/Menu)