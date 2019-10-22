#ifndef EXCEPTIONS_H
#define EXCEPTIONS_H

#include <exception>
#include <QString>

struct InvalidProjectException : public std::exception {
    InvalidProjectException(QString const &message) : _message(message) {}
    const char* what() const noexcept {
        return _message.toUtf8();
    }

private:
    QString _message;
};

#endif // EXCEPTIONS_H
