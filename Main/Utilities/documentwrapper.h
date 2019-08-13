#ifndef DOCUMENTWRAPPER_H
#define DOCUMENTWRAPPER_H

// This class exists so I can put pointers to it in a QVector.
// If you figure out a way to create a rapidjson::Document with
// new, please refactor projectFiles in MainPresenter to use
// rapidjson::Document pointers instead of this.

#include "../Include/rapidjson/include/rapidjson/document.h"

class DocumentWrapper {
public:
    rapidjson::Document document;
};

#endif // DOCUMENTWRAPPER_H
