#ifndef PROJECT_H
#define PROJECT_H

#include <QObject>

#include "Include/rapidjson/document.h"

#include "Core/communicator.h"
#include "transport.h"
#include "Core/modelitem.h"
#include "Utilities/projectfile.h"

class Project : public ModelItem {
    Q_OBJECT
private:
public:
    Transport* transport;
    Project(Communicator* parent, ProjectFile* projectFile);

    void externalUpdate(QStringRef pointer, PatchFragment& patch);

signals:

public slots:
};

#endif // PROJECT_H
