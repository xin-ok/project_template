#pragma once

#ifdef _WIN32
#ifdef SHAREDLIB1_EXPORT
#define SHAREDLIB1_DECL __declspec(dllexport)
#else
#define SHAREDLIB1_DECL __declspec(dllimport)
#endif  // SHAREDLIB1_EXPORT
#else
#define SHAREDLIB1_DECL
#endif  // _WIN32