#ifndef EXCEPTIONS_H
#define EXCEPTIONS_H

#include <exception>
#include <QString>

struct InvalidProjectException : public std::exception {
    InvalidProjectException(QByteArray message) : _message(message) {}
    const char* what() const noexcept {
        return QString(_message).toUtf8();
    }

private:
    QByteArray _message;
};

#endif // EXCEPTIONS_H
