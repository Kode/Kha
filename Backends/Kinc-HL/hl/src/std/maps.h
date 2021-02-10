
#undef t_map
#undef t_entry
#undef t_value
#undef t_key
#define t_key _MKEY_TYPE
#define t_map _MNAME(_map)
#define t_entry _MNAME(_entry)
#define t_value _MNAME(_value)

typedef struct {
	int *cells;
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
	if( !m->entries ) return NULL;
	hash = _MNAME(hash)(key);
	ckey = hash % ((unsigned)m->ncells);
	c = m->cells[ckey];
	while( c >= 0 ) {
		if( _MMATCH(c) )
			return &m->values[c].value;
		c = m->entries[c].next;
	}
	return NULL;
}

static void _MNAME(resize)( t_map *m );

static void _MNAME(set_impl)( t_map *m, t_key key, vdynamic *value ) {
	int c, ckey = 0;
	unsigned int hash = _MNAME(hash)(key);
	if( m->entries ) {
		ckey = hash % ((unsigned)m->ncells);
		c = m->cells[ckey];
		while( c >= 0 ) {
			if( _MMATCH(c) ) {
				m->values[c].value = value;
				return;
			}
			c = m->entries[c].next;
		}
	}
	c = hl_freelist_get(&m->lfree);
	if( c < 0 ) {
		_MNAME(resize)(m);
		ckey = hash % ((unsigned)m->ncells);
		c = hl_freelist_get(&m->lfree);
	}
	_MSET(c);
	m->entries[c].next = m->cells[ckey];
	m->cells[ckey] = c;
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

	m->entries = (t_entry*)hl_gc_alloc_noptr(nentries * sizeof(t_entry));
	m->values = (t_value*)hl_gc_alloc_raw(nentries * sizeof(t_value));
	m->maxentries = nentries;

	if( old.ncells == ncells ) {
		// simply expand
		memcpy(m->entries,old.entries,old.maxentries * sizeof(t_entry));
		memcpy(m->values,old.values,old.maxentries * sizeof(t_value));
		memset(m->values + old.maxentries, 0, (nentries - old.maxentries) * sizeof(t_value));
		hl_freelist_add_range(&m->lfree,old.maxentries,m->maxentries - old.maxentries);
	} else {
		// expand and remap
		m->cells = (int*)hl_gc_alloc_noptr(ncells * sizeof(int));
		m->ncells = ncells;
		m->nentries = 0;
		memset(m->cells,0xFF,ncells * sizeof(int));
		memset(m->values, 0, nentries * sizeof(t_value));
		hl_freelist_init(&m->lfree);
		hl_freelist_add_range(&m->lfree,0,m->maxentries);

		hl_add_root(&old); // prevent old.cells pointer aliasing
		for(i=0;i<old.ncells;i++) {
			int c = old.cells[i];
			while( c >= 0 ) {
				_MNAME(set_impl)(m,_MKEY((&old),c),old.values[c].value);
				c = old.entries[c].next;
			}
		}
		hl_remove_root(&old);
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
	c = m->cells[ckey];
	while( c >= 0 ) {
		if( _MMATCH(c) ) {
			hl_freelist_add(&m->lfree,c);
			m->nentries--;
			_MERASE(c);
			m->values[c].value = NULL;
			if( prev >= 0 )
				m->entries[prev].next = m->entries[c].next;
			else
				m->cells[ckey] = m->entries[c].next;
			return true;
		}
		prev = c;
		c = m->entries[c].next;
	}
	return false;
}

HL_PRIM varray* _MNAME(keys)( t_map *m ) {
	varray *a = hl_alloc_array(&hlt_key,m->nentries);
	t_key *keys = hl_aptr(a,t_key);
	int p = 0;
	int i;
	for(i=0;i<m->ncells;i++) {
		int c = m->cells[i];
		while( c >= 0 ) {
			keys[p++] = _MKEY(m,c);
			c = m->entries[c].next;
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
		int c = m->cells[i];
		while( c >= 0 ) {
			values[p++] = m->values[c].value;
			c = m->entries[c].next;
		}
	}
	return a;
}

HL_PRIM void _MNAME(clear)( t_map *m ) {
	memset(m,0,sizeof(t_map));
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

