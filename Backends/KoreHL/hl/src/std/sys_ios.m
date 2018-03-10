/*
 * Copyright (C)2005-2018 Haxe Foundation
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 */

#include <hl.h>

#if defined(HL_MOBILE) && defined(HL_IOS)

#include <sys/utsname.h>
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

static const char* ios_get_document_path()
{
	NSString* string = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	const char* path = strdup([string fileSystemRepresentation]);
	return path;
}

static const char* ios_get_resource_path()
{
	NSString* string = [[NSBundle mainBundle] resourcePath];
	const char* path = strdup([string UTF8String]);
	return path;
}

static const char* ios_get_device_name()
{
	struct utsname systemInfo;
	uname(&systemInfo);
	return strdup(systemInfo.machine);
}

static int ios_get_retina_scale_factor()
{
	return [[UIScreen mainScreen] scale];
}

const char *hl_sys_special( const char *key ) { 
	if (strcmp(key, "ios_resource_path")==0)
		return ios_get_resource_path();
	else if (strcmp(key, "ios_document_path")==0)
		return ios_get_document_path();
	else if (strcmp(key, "ios_retina_scale_factor")==0)
		return ios_get_retina_scale_factor();
	else if (strcmp(key, "ios_device_name")==0)
		return ios_get_device_name();
	else
		hl_error("Unknown sys_special key");
	return NULL;
}

DEFINE_PRIM(_BYTES, sys_special, _BYTES);

#endif
