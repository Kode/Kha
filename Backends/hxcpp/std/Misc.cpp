#include <hx/CFFI.h>

int __misc_prims() { return 0; }

static bool is_big_endian()
{
	static unsigned char bytes[] = { 1, 0, 0, 0 };
	return (*(int *)bytes) != 1;
};

/**
	float_bytes : number -> bigendian:bool -> string
	<doc>Returns the 4 bytes representation of the number as an IEEE 32-bit float</doc>
**/
static value float_bytes( value n, value be ) {
	float f;
	val_check(n,number);
	val_check(be,bool);
	f = (float)val_number(n);
	char *ptr = (char *)&f;
	buffer bytes = alloc_buffer_len(4);
	char *dest = (char *)buffer_data(bytes);
	if( is_big_endian() != val_bool(be) ) {
		dest[3] = *ptr++;
		dest[2] = *ptr++;
		dest[1] = *ptr++;
		dest[0] = *ptr++;
	}
	else {
		dest[0] = *ptr++;
		dest[1] = *ptr++;
		dest[2] = *ptr++;
		dest[3] = *ptr++;
	}
	return buffer_val(bytes);
}


static value double_bytes( value n, value be ) {
	double f;
	val_check(n,number);
	val_check(be,bool);
	f = (double)val_number(n);
	unsigned char *ptr = (unsigned char *)&f;
	buffer bytes = alloc_buffer_len(8);
	char *dest = (char *)buffer_data(bytes);
	if( is_big_endian() != val_bool(be) ) {
		dest[7] = *ptr++;
		dest[6] = *ptr++;
		dest[5] = *ptr++;
		dest[4] = *ptr++;
		dest[3] = *ptr++;
		dest[2] = *ptr++;
		dest[1] = *ptr++;
		dest[0] = *ptr++;
	}
	else {
		dest[0] = *ptr++;
		dest[1] = *ptr++;
		dest[2] = *ptr++;
		dest[3] = *ptr++;
		dest[4] = *ptr++;
		dest[5] = *ptr++;
		dest[6] = *ptr++;
		dest[7] = *ptr++;
	}
	return buffer_val(bytes);
}


/**
	float_of_bytes : string -> bigendian:bool -> float
	<doc>Returns a float from a 4 bytes IEEE 32-bit representation</doc>
**/
static value float_of_bytes( value s, value be ) {
	float f;
	val_check(be,bool);
	buffer bytes = val_to_buffer(s);
	if( bytes==0)
		return alloc_null();
	f = *(float*)buffer_data(bytes);
	char *c = (char*)&f;
	if( is_big_endian() != val_bool(be) ) {
		char *c = (char*)&f;
		char tmp;
		tmp = c[0];	c[0] = c[3]; c[3] = tmp;
		tmp = c[1];	c[1] = c[2]; c[2] = tmp;
	}
	return alloc_float(f);
}

static value double_of_bytes( value s, value be ) {
	double f;
	val_check(be,bool);
	buffer bytes = val_to_buffer(s);
	if( bytes==0)
		return alloc_null();
	f = *(double*)buffer_data(bytes);
	if( is_big_endian() != val_bool(be) ) {
		char *c = (char*)&f;
		char tmp;
		tmp = c[0]; c[0] = c[7]; c[7] = tmp;
		tmp = c[1];	c[1] = c[6]; c[6] = tmp;
		tmp = c[2]; c[2] = c[5]; c[5] = tmp;
		tmp = c[3];	c[3] = c[4]; c[4] = tmp;
	}
	return alloc_float(f);
}



#if 0

/**
	double_of_bytes : string -> bigendian:bool -> float
	<doc>Returns a float from a 8 bytes IEEE 64-bit representation</doc>
**/

/**
	run_gc : major:bool -> void
	<doc>Run the Neko garbage collector</doc>
**/
static value run_gc( value b ) {
	val_check(b,bool);
	if( val_bool(b) )
		neko_gc_major();
	else
		neko_gc_loop();
	return val_null;
}

/**
	gc_stats : void -> { heap => int, free => int }
	<doc>Return the size of the GC heap and the among of free space, in bytes</doc>
**/
static value gc_stats() {
	int heap, free;
	value o;
	neko_gc_stats(&heap,&free);
	o = alloc_object(NULL);
	alloc_field(o,val_id("heap"),alloc_int(heap));
	alloc_field(o,val_id("free"),alloc_int(free));
	return o;
}

/**
	enable_jit : bool -> void
	<doc>Enable or disable the JIT.</doc>
**/
static value enable_jit( value b ) {	
	val_check(b,bool);
	neko_vm_jit(neko_vm_current(),val_bool(b));
	return val_null;
}

/**
	test : void -> void
	<doc>The test function, to check that library is reachable and correctly linked</doc>
**/
static value test() {
	val_print(alloc_string("Calling a function inside std library...\n"));
	return val_null;
}

/**
	print_redirect : function:1? -> void
	<doc>
	Set a redirection function for all printed values. 
	Setting it to null will cancel the redirection and restore previous printer.
	</doc>
**/

static void print_callback( const char *s, int size, void *f ) {	
	val_call1(f,copy_string(s,size));
}

static value print_redirect( value f ) {
	neko_vm *vm = neko_vm_current();
	if( val_is_null(f) ) {
		neko_vm_redirect(vm,NULL,NULL);
		return val_null;
	}
	val_check_function(f,1);
	neko_vm_redirect(vm,print_callback,f);
	return val_null;
}

/**
	set_trusted : bool -> void
	<doc>
	Change the trusted mode of the VM.
	This can optimize some operations such as module loading by turning off some checks.
	</doc>
**/
static value set_trusted( value b ) {
	val_check(b,bool);
	neko_vm_trusted(neko_vm_current(),val_bool(b));
	return val_null;
}

/**
	same_closure : f1 -> f2 -> bool
	<doc>
	Compare two functions by checking that they refer to the same implementation and that their environments contains physically equal values.
	</doc>
**/
static value same_closure( value _f1, value _f2 ) {
	vfunction *f1 = (vfunction*)_f1;
	vfunction *f2 = (vfunction*)_f2;
	int i;
	if( !val_is_function(f1) || !val_is_function(f2) )
		return val_false;
	if( f1 == f2 )
		return val_true;
	if( f1->nargs != f2->nargs || f1->addr != f2->addr || f1->module != f2->module || val_array_size(f1->env) != val_array_size(f2->env) )
		return val_false;
	for(i=0;i<val_array_size(f1->env);i++)
		if( val_array_ptr(f1->env)[i] != val_array_ptr(f2->env)[i] )
			return val_false;
	return val_true;
}

DEFINE_PRIM(run_gc,1);
DEFINE_PRIM(gc_stats,0);
DEFINE_PRIM(enable_jit,1);
DEFINE_PRIM(test,0);
DEFINE_PRIM(print_redirect,1);
DEFINE_PRIM(set_trusted,1);
DEFINE_PRIM(same_closure,2);

/* ************************************************************************ */

#endif

DEFINE_PRIM(float_bytes,2);
DEFINE_PRIM(double_bytes,2);
DEFINE_PRIM(float_of_bytes,2);
DEFINE_PRIM(double_of_bytes,2);
