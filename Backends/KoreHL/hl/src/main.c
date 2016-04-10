/*
 * Copyright (C)2015-2016 Haxe Foundation
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
#include "hlmodule.h"

#ifdef HL_VCC
#	include <crtdbg.h>
#else
#	define _CrtSetDbgFlag(x)
#endif

int main( int argc, char *argv[] ) {
	_CrtSetDbgFlag ( _CRTDBG_ALLOC_MEM_DF | _CRTDBG_DELAY_FREE_MEM_DF | _CRTDBG_LEAK_CHECK_DF | _CRTDBG_CHECK_ALWAYS_DF );
	if( argc == 1 ) {
		printf("HLVM %d.%d.%d (c)2015 Haxe Foundation\n  Usage : hl <file>\n",HL_VERSION/100,(HL_VERSION/10)%10,HL_VERSION%10);
		return 1;
	}
	hl_global_init();
	{
		hl_code *code;
		hl_module *m;
		const char *file = argv[1];
		FILE *f = fopen(file,"rb");
		int pos, size;
		char *fdata;
		if( f == NULL ) {
			printf("File not found '%s'\n",file);
			return 1;
		}
		fseek(f, 0, SEEK_END);
		size = (int)ftell(f);
		fseek(f, 0, SEEK_SET);
		fdata = (char*)malloc(size);
		pos = 0;
		while( pos < size ) {
			int r = (int)fread(fdata + pos, 1, size-pos, f);
			if( r <= 0 ) {
				printf("Failed to read '%s'\n",file);
				return 2;
			}
			pos += r;
		}
		fclose(f);
		code = hl_code_read((unsigned char*)fdata, size);
		free(fdata);
		if( code == NULL )
			return 3;
		m = hl_module_alloc(code);
		if( m == NULL )
			return 4;
		if( !hl_module_init(m) )
			return 5;
		hl_callback(m->functions_ptrs[m->code->entrypoint],0,NULL);
		hl_module_free(m);
		hl_free(&code->alloc);
	}
	hl_global_free();
	return 0;
}
