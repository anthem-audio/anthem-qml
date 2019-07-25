pragma Singleton

import QtQuick 2.13

QtObject {
    property FontLoader notoSansRegular: FontLoader {
        source: "../Fonts/NotoSans-Regular.ttf"
        name: "Noto Sans Regular"
    }

    property FontLoader sourceCodeProSemiBold: FontLoader {
        source: "../Fonts/SourceCodePro-SemiBold.ttf"
        name: "Source Code Pro Semi Bold"
    }
}
