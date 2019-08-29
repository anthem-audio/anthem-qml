QT += quick
CONFIG += c++11

# The following define makes your compiler emit warnings if you use
# any Qt feature that has been marked deprecated (the exact warnings
# depend on your compiler). Refer to the documentation for the
# deprecated API to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
        Core/modelitem.cpp \
        Core/engine.cpp \
        Model/project.cpp \
        Model/transport.cpp \
        Presenter/mainpresenter.cpp \
        Utilities/idgenerator.cpp \
        Utilities/mousehelper.cpp \
        Utilities/projectfile.cpp \
        main.cpp

RESOURCES += qml.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    Core/modelitem.h \
    Core/engine.h \
    Include/rapidjson/include/rapidjson/allocators.h \
    Include/rapidjson/include/rapidjson/cursorstreamwrapper.h \
    Include/rapidjson/include/rapidjson/document.h \
    Include/rapidjson/include/rapidjson/encodedstream.h \
    Include/rapidjson/include/rapidjson/encodings.h \
    Include/rapidjson/include/rapidjson/error/en.h \
    Include/rapidjson/include/rapidjson/error/error.h \
    Include/rapidjson/include/rapidjson/filereadstream.h \
    Include/rapidjson/include/rapidjson/filewritestream.h \
    Include/rapidjson/include/rapidjson/fwd.h \
    Include/rapidjson/include/rapidjson/internal/biginteger.h \
    Include/rapidjson/include/rapidjson/internal/diyfp.h \
    Include/rapidjson/include/rapidjson/internal/dtoa.h \
    Include/rapidjson/include/rapidjson/internal/ieee754.h \
    Include/rapidjson/include/rapidjson/internal/itoa.h \
    Include/rapidjson/include/rapidjson/internal/meta.h \
    Include/rapidjson/include/rapidjson/internal/pow10.h \
    Include/rapidjson/include/rapidjson/internal/regex.h \
    Include/rapidjson/include/rapidjson/internal/stack.h \
    Include/rapidjson/include/rapidjson/internal/strfunc.h \
    Include/rapidjson/include/rapidjson/internal/strtod.h \
    Include/rapidjson/include/rapidjson/internal/swap.h \
    Include/rapidjson/include/rapidjson/istreamwrapper.h \
    Include/rapidjson/include/rapidjson/memorybuffer.h \
    Include/rapidjson/include/rapidjson/memorystream.h \
    Include/rapidjson/include/rapidjson/msinttypes/inttypes.h \
    Include/rapidjson/include/rapidjson/msinttypes/stdint.h \
    Include/rapidjson/include/rapidjson/ostreamwrapper.h \
    Include/rapidjson/include/rapidjson/pointer.h \
    Include/rapidjson/include/rapidjson/prettywriter.h \
    Include/rapidjson/include/rapidjson/rapidjson.h \
    Include/rapidjson/include/rapidjson/reader.h \
    Include/rapidjson/include/rapidjson/schema.h \
    Include/rapidjson/include/rapidjson/stream.h \
    Include/rapidjson/include/rapidjson/stringbuffer.h \
    Include/rapidjson/include/rapidjson/writer.h \
    Include/snowflake.h \
    Model/project.h \
    Model/transport.h \
    Presenter/mainpresenter.h \
    Utilities/exceptions.h \
    Utilities/idgenerator.h \
    Utilities/mousehelper.h \
    Utilities/projectfile.h
