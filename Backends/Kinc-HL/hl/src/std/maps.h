
#undef t_map
#undef t_entry
#undef t_value
#undef t_key
#define t_key _MKEY_TYPE
#define t_map _MNAME(_map)
#define t_entry _MNAME(_entry)
#define t_value _MNAME(_value)
#define _MLIMIT 128
#define _MINDEX(m,ckey) ((m)->maxentries < _MLIMIT ? (int)((signed char*)(m)->cells)[ckey] : ((int*)(m)->cells)[ckey])
#define _MNEXT(m,ckey) ((m)->maxentries < _MLIMIT ? (int)((signed char*)(m)->nexts)[ckey] : ((int*)(m)->nexts)[ckey])

typedef struct {
	void *cells;
	void *nexts;
	t_entry *entries;
	t_value *values;
	hl_free_list lfree;
	int ncells;
	int nentries;
	int maxentries;
} t_map;

HL_PRIM t_map *_MNAME(alloc)() {
	t_map *m = (t_map*)hl_gc_alloc_raw(sizeof(t_map));
	memset(m,0,sizeof(t_map));
	return m;
}

static vdynamic **_MNAME(find)( t_map *m, t_key key ) {
	int c, ckey;
	unsigned int hash;

	if( !m->values ) return NULL;
	hash = _MNAME(hash)(key);
	ckey = hash % ((unsigned)m->ncells);
	c = _MINDEX(m,ckey);
	while( c >= 0 ) {
		if( _MMATCH(c) )
			return &m->values[c].value;
		c = _MNEXT(m,c);
	}
	return NULL;
}

static void _MNAME(resize)( t_map *m );

static void _MNAME(set_impl)( t_map *m, t_key key, vdynamic *value ) {
	int c, ckey = 0;
	unsigned int hash = _MNAME(hash)(key);
	if( m->values ) {
		ckey = hash % ((unsigned)m->ncells);
		c = _MINDEX(m,ckey);
		while( c >= 0 ) {
			if( _MMATCH(c) ) {
				m->values[c].value = value;
				return;
			}
			c = _MNEXT(m,c);
		}
	}
	c = hl_freelist_get(&m->lfree);
	if( c < 0 ) {
		_MNAME(resize)(m);
		ckey = hash % ((unsigned)m->ncells);
		c = hl_freelist_get(&m->lfree);
	}
	_MSET(c);
	if( m->maxentries < _MLIMIT ) {
		((signed char*)m->nexts)[c] = ((signed char*)m->cells)[ckey];
		((signed char*)m->cells)[ckey] = (signed char)c;
	} else {
		((int*)m->nexts)[c] = ((int*)m->cells)[ckey];
		((int*)m->cells)[ckey] = c;
	}
	m->values[c].value = value;
	m->nentries++;
}

static void _MNAME(resize)( t_map *m ) {
	// save
	t_map old = *m;

	if( m->nentries != m->maxentries ) hl_error("assert");

	// resize
	int i = 0;
	int nentries = m->maxentries ? ((m->maxentries * 3) + 1) >> 1 : H_SIZE_INIT;
	int ncells = nentries >> 2;

	while( H_PRIMES[i] < ncells ) i++;
	ncells = H_PRIMES[i];

	int ksize = nentries < _MLIMIT ? 1 : sizeof(int);
	m->entries = (t_entry*)hl_gc_alloc_noptr(nentries * sizeof(t_entry));
	m->values = (t_value*)hl_gc_alloc_raw(nentries * sizeof(t_value));
	m->maxentries = nentries;

	if( old.ncells == ncells && (nentries < _MLIMIT || old.maxentries >= _MLIMIT) ) {
		// simply expand
		m->nexts = hl_gc_alloc_noptr(nentries * ksize);
		memcpy(m->entries,old.entries,old.maxentries * sizeof(t_entry));
		memcpy(m->values,old.values,old.maxentries * sizeof(t_value));
		memcpy(m->nexts,old.nexts,old.maxentries * ksize);
		memset(m->values + old.maxentries, 0, (nentries - old.maxentries) * sizeof(t_value));
		hl_freelist_add_range(&m->lfree,old.maxentries,m->maxentries - old.maxentries);
	} else {
		// expand and remap
		m->cells = hl_gc_alloc_noptr((ncells + nentries) * ksize);
		m->nexts = (signed char*)m->cells + ncells * ksize;
		m->ncells = ncells;
		m->nentries = 0;
		memset(m->cells,0xFF,ncells * ksize);
		memset(m->values, 0, nentries * sizeof(t_value));
		hl_freelist_init(&m->lfree);
		hl_freelist_add_range(&m->lfree,0,m->maxentries);
		for(i=0;i<old.ncells;i++) {
			int c = old.maxentries < _MLIMIT ? ((signed char*)old.cells)[i] : ((int*)old.cells)[i];
			while( c >= 0 ) {
				_MNAME(set_impl)(m,_MKEY((&old),c),old.values[c].value);
				c = _MNEXT(&old,c);
			}
		}
	}
}

HL_PRIM void _MNAME(set)( t_map *m, t_key key, vdynamic *value ) {
	_MNAME(set_impl)(m,_MNAME(filter)(key),value);
}

HL_PRIM bool _MNAME(exists)( t_map *m, t_key key ) {
	return _MNAME(find)(m,_MNAME(filter)(key)) != NULL;
}

HL_PRIM vdynamic* _MNAME(get)( t_map *m, t_key key ) {
	vdynamic **v = _MNAME(find)(m,_MNAME(filter)(key));
	if( v == NULL ) return NULL;
	return *v;
}

HL_PRIM bool _MNAME(remove)( t_map *m, t_key key ) {
	int c, prev = -1, ckey;
	unsigned int hash;
	if( !m->cells ) return false;
	key = _MNAME(filter)(key);
	hash = _MNAME(hash)(key);
	ckey = hash % ((unsigned)m->ncells);
	c = _MINDEX(m,ckey);
	while( c >= 0 ) {
		if( _MMATCH(c) ) {
			hl_freelist_add(&m->lfree,c);
			m->nentries--;
			_MERASE(c);
			m->values[c].value = NULL;
			if( m->maxentries < _MLIMIT ) {
				if( prev >= 0 )
					((signed char*)m->nexts)[prev] = ((signed char*)m->nexts)[c];
				else
					((signed char*)m->cells)[ckey] = ((signed char*)m->nexts)[c];
			} else {
				if( prev >= 0 )
					((int*)m->nexts)[prev] = ((int*)m->nexts)[c];
				else
					((int*)m->cells)[ckey] = ((int*)m->nexts)[c];
			}
			return true;
		}
		prev = c;
		c = _MNEXT(m,c);
	}
	return false;
}

HL_PRIM varray* _MNAME(keys)( t_map *m ) {
	varray *a = hl_alloc_array(&hlt_key,m->nentries);
	t_key *keys = hl_aptr(a,t_key);
	int p = 0;
	int i;
	for(i=0;i<m->ncells;i++) {
		int c = _MINDEX(m,i);
		while( c >= 0 ) {
			keys[p++] = _MKEY(m,c);
			c = _MNEXT(m,c);
		}
	}
	return a;
}

HL_PRIM varray* _MNAME(values)( t_map *m ) {
	varray *a = hl_alloc_array(&hlt_dyn,m->nentries);
	vdynamic **values = hl_aptr(a,vdynamic*);
	int p = 0;
	int i;
	for(i=0;i<m->ncells;i++) {
		int c = _MINDEX(m,i);
		while( c >= 0 ) {
			values[p++] = m->values[c].value;
			c = _MNEXT(m,c);
		}
	}
	return a;
}

HL_PRIM void _MNAME(clear)( t_map *m ) {
	memset(m,0,sizeof(t_map));
}

HL_PRIM int _MNAME(size)( t_map *m ) {
	return m->nentries;
}


#undef hlt_key
#undef hl_hbhash
#undef _MKEY_TYPE
#undef _MNAME
#undef _MMATCH
#undef _MKEY
#undef _MSET
#undef _MERASE
#undef _MOLD_KEY
#undef _MINDEX
#undef _MNEXT
