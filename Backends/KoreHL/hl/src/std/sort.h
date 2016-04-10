#define m_sort TID(m_sort)
#define ms_compare TID(ms_compare)
#define ms_swap TID(ms_swap)
#define ms_lower TID(ms_lower)
#define ms_upper TID(ms_upper)
#define ms_rotate TID(ms_rotate)
#define ms_do_merge TID(ms_do_merge)
#define merge_sort_rec TID(merge_sort_rec)

typedef struct {
	TSORT *arr;
	vclosure *c;
} m_sort;

static int ms_compare( m_sort *m, int a, int b ) {
	return m->c->hasValue ? ((int(*)(void*,TSORT,TSORT))m->c->fun)(m->c->value,m->arr[a],m->arr[b]) : ((int(*)(TSORT,TSORT))m->c->fun)(m->arr[a],m->arr[b]);
}

static void ms_swap( m_sort *m, int a, int b ) {
	TSORT tmp = m->arr[a];
	m->arr[a] = m->arr[b];
	m->arr[b] = tmp;
}

static int ms_lower( m_sort *m, int from, int to, int val ) {
  	int len = to - from, half, mid;
  	while( len > 0 ) {
  		half = len>>1;
		mid = from + half;
		if( ms_compare(m, mid, val) < 0 ) {
    		from = mid+1;
    		len = len - half -1;
   		} else
   			len = half;
  	}
	return from;
}

static int ms_upper( m_sort *m, int from, int to, int val ) {
	int len = to - from, half, mid;
	while( len > 0 ) {
		half = len>>1;
		mid = from + half;
		if( ms_compare(m, val, mid) < 0 )
			len = half;
		else {
			from = mid+1;
			len = len - half -1;
		}
	}
	return from;
}

static void ms_rotate( m_sort *m, int from, int mid, int to ) {
	int n;
	if( from==mid || mid==to ) return;
	n = ms_gcd(to - from, mid - from);
	while (n-- != 0) {
		TSORT val = m->arr[from+n];
		int shift = mid - from;
		int p1 = from+n, p2=from+n+shift;
		while (p2 != from + n) {
			m->arr[p1] = m->arr[p2];
			p1=p2;
			if( to - p2 > shift) p2 += shift;
			else p2=from + (shift - (to - p2));
		}
		m->arr[p1] = val;
	}
}
static void ms_do_merge( m_sort *m, int from, int pivot, int to, int len1, int len2 ) {
	int first_cut, second_cut, len11, len22, new_mid;
	if( len1 == 0 || len2==0 )
		return;
	if( len1+len2 == 2 ) {
		if( ms_compare(m, pivot, from) < 0 )
			ms_swap(m, pivot, from);
   		return;
  	}
	if (len1 > len2) {
		len11=len1>>1;
		first_cut = from + len11;
		second_cut = ms_lower(m, pivot, to, first_cut);
		len22 = second_cut - pivot;
	} else {
		len22 = len2>>1;
		second_cut = pivot + len22;
		first_cut = ms_upper(m, from, pivot, second_cut);
		len11=first_cut - from;
	}
	ms_rotate(m, first_cut, pivot, second_cut);
	new_mid=first_cut+len22;
	ms_do_merge(m, from, first_cut, new_mid, len11, len22);
	ms_do_merge(m, new_mid, second_cut, to, len1 - len11, len2 - len22);
}

static void merge_sort_rec( m_sort *m, int from, int to ) {
	int middle;
	if( to - from < 12 ) {
		// insert sort
		int i;
		if( to <= from ) return;
		for(i=from+1;i<to;i++) {
			int j = i;
			while( j > from ) {
				if( ms_compare(m,j,j-1) < 0 )
					ms_swap(m,j-1,j);
		    	else
		    		break;
			    j--;
			}
   		}
		return;
	}
	middle = (from + to)>>1;
	merge_sort_rec(m, from, middle);
	merge_sort_rec(m, middle, to);
	ms_do_merge(m, from, middle, to, middle-from, to - middle);
}

#undef ms_compare
#undef ms_swap
#undef ms_lower
#undef ms_upper
#undef ms_rotate
#undef ms_do_merge
#undef merge_sort_rec
#undef m_sort
#undef TSORT
#undef TID
