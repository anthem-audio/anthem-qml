#ifndef EXCEPTIONS_H
#define EXCEPTIONS_H

#include <exception>

struct InvalidProjectException : public std::exception {
    const char* what() const noexcept {
        return "The provided file does not contain a valid project";
    }
};

#endif // EXCEPTIONS_H
