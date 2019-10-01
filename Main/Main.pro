QT += quick
QT += testlib
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
        Core/communicator.cpp \
        Core/engine.cpp \
        Core/modelitem.cpp \
        Model/control.cpp \
        Model/project.cpp \
        Model/transport.cpp \
        Presenter/mainpresenter.cpp \
        Utilities/idgenerator.cpp \
        Utilities/mousehelper.cpp \
        Utilities/patch.cpp \
        Utilities/patchfragment.cpp \
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
    Core/communicator.h \
    Core/engine.h \
    Core/modelitem.h \
    Include/rapidjson/allocators.h \
    Include/rapidjson/cursorstreamwrapper.h \
    Include/rapidjson/document.h \
    Include/rapidjson/encodedstream.h \
    Include/rapidjson/encodings.h \
    Include/rapidjson/error/en.h \
    Include/rapidjson/error/error.h \
    Include/rapidjson/filereadstream.h \
    Include/rapidjson/filewritestream.h \
    Include/rapidjson/fwd.h \
    Include/rapidjson/internal/biginteger.h \
    Include/rapidjson/internal/diyfp.h \
    Include/rapidjson/internal/dtoa.h \
    Include/rapidjson/internal/ieee754.h \
    Include/rapidjson/internal/itoa.h \
    Include/rapidjson/internal/meta.h \
    Include/rapidjson/internal/pow10.h \
    Include/rapidjson/internal/regex.h \
    Include/rapidjson/internal/stack.h \
    Include/rapidjson/internal/strfunc.h \
    Include/rapidjson/internal/strtod.h \
    Include/rapidjson/internal/swap.h \
    Include/rapidjson/istreamwrapper.h \
    Include/rapidjson/memorybuffer.h \
    Include/rapidjson/memorystream.h \
    Include/rapidjson/msinttypes/inttypes.h \
    Include/rapidjson/msinttypes/stdint.h \
    Include/rapidjson/ostreamwrapper.h \
    Include/rapidjson/pointer.h \
    Include/rapidjson/prettywriter.h \
    Include/rapidjson/rapidjson.h \
    Include/rapidjson/reader.h \
    Include/rapidjson/schema.h \
    Include/rapidjson/stream.h \
    Include/rapidjson/stringbuffer.h \
    Include/rapidjson/writer.h \
    Include/snowflake.h \
    Model/control.h \
    Model/project.h \
    Model/transport.h \
    Presenter/mainpresenter.h \
    Tests/modeltests.h \
    Utilities/exceptions.h \
    Utilities/idgenerator.h \
    Utilities/mousehelper.h \
    Utilities/patch.h \
    Utilities/patchfragment.h \
    Utilities/projectfile.h
