# Anthem

Anthem is a cross-platform digital audio workstation. It is written in Rust, QML, and C++.

## Architecture

Anthem has two main parts: the engine and the UI. The engine handles sequencing and audio processing, and the UI handles user interaction and data display.

These two components are separated into two processes that communicate with each other via a socket connection.

## Engine

(insert engine info here)

## UI

The UI is written in QML and C++ and follows a lose interpretation of the [model-view-presenter](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93presenter) design pattern. The C++ model is strictly for handling data storage, retrieval, and serialization. The view is written in QML and handles data display and user interaction. The presenter connects the view to the model and houses any application logic (for example, saving and loading) that is not directly related to manipulating the UI.
