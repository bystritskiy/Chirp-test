/**-----------------------------------------------------------------------------
 *
 *  ASIO CONFIDENTIAL
 *
 *  @file chirp_sdk_package.h
 *
 *  @brief Chirp package structure shared across the SDKs.
 *
 *  All contents are strictly proprietary, and not for copying, resale,
 *  or use outside of the agreed license.
 *
 *  Copyright © 2011-2018, Asio Ltd.
 *  All rights reserved.
 *
 *----------------------------------------------------------------------------*/

#ifndef CHIRP_SDK_PACKAGE_H
#define CHIRP_SDK_PACKAGE_H

#ifdef __cplusplus
extern "C" {
#endif

typedef struct _chirp_package_t {
    const char *name;
    const char *version;
    const char *build;
} chirp_package_t;

#ifdef __cplusplus
}
#endif

#endif /* !CHIRP_SDK_PACKAGE_H */
