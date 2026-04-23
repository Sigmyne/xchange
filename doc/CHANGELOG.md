# Changelog

All notable changes to the [Sigmyne/xchange](https://github.com/Sigmyne/xchange) library will be documented 
in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to 
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).


## [1.1.2-rc1] - 2026-04-23

Maintenance release with improved portability (esp. Windows, MacOS, and BSD).

### Fixed

 - #23: Removed unneeded includes of UNIX-specific `unistd.h` (blocking portability). 
 
### Added

 - #23: Portability to Windows, MacOS, and BSD.

 - #23: CMake build configuration, alongside the GNU make config.
 
 - #23: New GitHub Actions workflows for multi-platform checks

### Changed
 
 - #23: Use portable mutexes in `xlookup.c`.
 
 - #23: `xjson` error/warning reporting via `static` functions instead of niche macros that Windows does not support.

 - #23: `xGetAsLongAtIndex()` and `xGetAsDoubleAtIndex()` switch to setting errno to `EINVAL` instead of `ENOSR`, as
   the latter is not defined on BSD.


## [1.1.1] - 2026-02-16

Maintenance release with minor code style improvements.

### Changed

 - #18: A few code style improvements, spotted by cppcheck.
 

## [1.1.0] - 2025-11-10

Minor feature release with bug fixes.

### Fixed

 - #15: `xPrintFloat()` printed an extra digit, which would appear as a 'rounding error' in decimal representations.

 - #16: Width detection of platform-specific built-in integer types (i.e., `short`, `int`, `long`, and `long long`). 
   The previous implementation included `stdint.h` with `__STDC_LIMIT_MACROS` defined. However, if the application 
   source, then included `stdint.h` _before_ `xchange.h`, then the fixed-width integer limits were left undefined. As 
   a result, we no longer rely on `stdint.h` providing these limits.

### Added

 - `xParseFloat()` to parse floats without rounding errors that might result if parsing as `double` and then casting 
   as `float`.


## [1.0.1] - 2025-07-01

Bug fix release.

### Fixed

 - Handling of serialized strings in `xClearField()` and `xCopyOfField()`.
 
 - Handling of heterogeneous arrays (type `X_FIELD`) in `xCopyOfField()`.

### Added
 
 - `xDestroyLookupAndData()` to destroy a lookup table _including_ all the data that was referenced inside it. 
 
### Changed

 - `xCreateField()` to treat `X_RAW` types always as scalars, ignoring the dimensions provided.
 

## [1.0.0] - 2025-03-31

Initial public release.
