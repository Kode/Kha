#ifndef RED_BLACK_H
#define RED_BLACK_H
 
// --------------------------------------------------------------------------------------------
 
 
/*
  Red Black balanced tree library
 
    > Created (Julienne Walker): August 23, 2003
    > Modified (Julienne Walker): March 14, 2008
 
  This code is in the public domain. Anyone may
  use it or change it in any way that they see
  fit. The author assumes no responsibility for
  damages incurred through use of the original
  code or any variations thereof.
 
  It is requested, but not required, that due
  credit is given to the original author and
  anyone who has modified the code through
  a header comment, such as this one.
*/
 
 
/*
  Red Black balanced tree library
 
    > Created (Julienne Walker): August 23, 2003
    > Modified (Julienne Walker): March 14, 2008
*/
 
#ifndef HEIGHT_LIMIT
#define HEIGHT_LIMIT 64 /* Tallest allowable tree */
#endif

#define DO_ALLOC(x) hx::InternalNew(x,false)

 
template<typename KEY,typename VALUE>
struct RBTree {
 
   inline static RBTree *Create( )
   {
     RBTree *rt = (RBTree *)DO_ALLOC( sizeof(*rt) );
 
     if ( rt == NULL )
       return NULL;
 
     rt->tmp_head = NULL;
     rt->root = NULL;
     rt->size = 0;
 
     return rt;
   }
 
 
   VALUE *Find( KEY inKey )
   {
     Node *it = this->root;
 
     while ( it != NULL ) {
        int cmp = DoCompare(it->key,inKey);
        if (cmp==0)
           return &it->value;
 
        it = it->link[cmp < 0];
     }
     return 0;
   }
 
   int Insert(const KEY &inKey, const VALUE &inValue)
   {
      if ( this->root == NULL ) {
        /*
          We have an empty tree; attach the
          new node directly to the root
        */
         this->root = new_node ( inKey, inValue );

        if ( root == NULL )
          return 0;
      }
      else {
        tmp_head = (Node *)DO_ALLOC ( sizeof(Node) );
        Node *g, *t;     /* Grandparent & parent */
        Node *p, *q;     /* Iterator & parent */
        int dir = 0, last = 0;

  
        /* Set up our helpers */
        t = tmp_head;
        g = p = NULL;
        q = t->link[1] = this->root;
  
        /* Search down the tree for a place to insert */
        for ( ; ; ) {
          if ( q == NULL ) {
            /* Insert a new node at the first null link */
            p->link[dir] = q = new_node ( inKey, inValue );
  
            if ( q == NULL )
            {
               tmp_head = 0;
               return 0;
            }
          }
          else if ( is_red ( q->link[0] ) && is_red ( q->link[1] ) ) {
            /* Simple red violation: color flip */
            q->red = 1;
            q->link[0]->red = 0;
            q->link[1]->red = 0;
          }
  
          if ( is_red ( q ) && is_red ( p ) ) {
            /* Hard red violation: rotations necessary */
            int dir2 = t->link[1] == g;
  
            if ( q == p->link[last] )
              t->link[dir2] = g->rot_single ( !last );
            else
              t->link[dir2] = g->rot_double ( !last );
          }
  
          /*
            Stop working if we inserted a node. This
            check also disallows duplicates in the tree
          */
          if ( q->key== inKey )
 			{
 				q->value = inValue;
            break;
 			}
  
          last = dir;
          dir = DoCompare( q->key, inKey ) < 0;
  
          /* Move the helpers down */
          if ( g != NULL )
            t = g;
  
          g = p, p = q;
          q = q->link[dir];
        }
  
        /* Update the root (it may be different) */
        root = tmp_head->link[1];
      }
  
      /* Make the root black for simplified logic */
      root->red = 0;
      ++size;
  
      tmp_head = 0;
      return 1;
    }
 
 
 
   bool Erase ( const KEY &inKey )
   {
      if ( root != NULL ) {
        tmp_head = (Node *)DO_ALLOC ( sizeof(Node) );
        Node *q, *p, *g; /* Helpers */
        Node *f = NULL;  /* Found item */
        int dir = 1;
  
        /* Set up our helpers */
        q = tmp_head;
        g = p = NULL;
        q->link[1] = root;
  
        /*
          Search and push a red node down
          to fix red violations as we go
        */
        while ( q->link[dir] != NULL ) {
          int last = dir;
  
          /* Move the helpers down */
          g = p, p = q;
          q = q->link[dir];
          int cmp = DoCompare ( q->key, inKey );
          dir = cmp < 0;
  
          /*
            Save the node with matching data and keep
            going; we'll do removal tasks at the end
          */
          if ( cmp == 0 )
            f = q;
  
          /* Push the red node down with rotations and color flips */
          if ( !is_red ( q ) && !is_red ( q->link[dir] ) ) {
            if ( is_red ( q->link[!dir] ) )
              p = p->link[last] = q->rot_single ( dir );
            else if ( !is_red ( q->link[!dir] ) ) {
              Node *s = p->link[!last];
  
              if ( s != NULL ) {
                if ( !is_red ( s->link[!last] ) && !is_red ( s->link[last] ) ) {
                  /* Color flip */
                  p->red = 0;
                  s->red = 1;
                  q->red = 1;
                }
                else {
                  int dir2 = g->link[1] == p;
  
                  if ( is_red ( s->link[last] ) )
                    g->link[dir2] = p->rot_double ( last );
                  else if ( is_red ( s->link[!last] ) )
                    g->link[dir2] = p->rot_single ( last );
  
                  /* Ensure correct coloring */
                  q->red = g->link[dir2]->red = 1;
                  g->link[dir2]->link[0]->red = 0;
                  g->link[dir2]->link[1]->red = 0;
                }
              }
            }
          }
        }
  
        /* Replace and remove the saved node */
        if ( f != NULL ) {
          f->key = q->key;
          f->value = q->value;
          p->link[p->link[1] == q] =
            q->link[q->link[0] == NULL];
          // free ( q );
        }
  
        /* Update the root (it may be different) */
        root = tmp_head->link[1];
  
        /* Make the root black for simplified logic */
        if ( root != NULL )
          root->red = 0;
  
        --size;
        tmp_head = 0;
        return true;
      }
  
      tmp_head = 0;
      return false;
    }
 
   size_t Size( ) { return size; }

	template<typename VISITOR>
	void Iterate(VISITOR &inVisitor)
	{
		if (root)
			root->Visit(inVisitor);
		if (tmp_head)
			tmp_head->Visit(inVisitor);
	}
 
 
 
protected:
 
   struct Node
	{
      Node() : red(0) { link[0]=link[1]=0; }

		Node *rot_single ( int dir )
		{
		   Node *save = this->link[!dir];
	 
		   this->link[!dir] = save->link[dir];
		   save->link[dir] = this;
	 
		   this->red = 1;
		   save->red = 0;
	 
		   return save;
		}
	 
		Node *rot_double( int dir )
		{
		   this->link[!dir] = this->link[!dir]->rot_single ( !dir );
	 
		   return rot_single (  dir );
		}

		template<typename VISITOR>
		void Visit(VISITOR &inVisitor)
		{
			if (link[0])
				link[0]->Visit(inVisitor);
			inVisitor.Visit(this,key,value);
			if (link[1])
				link[1]->Visit(inVisitor);
		}
 
 
     int                 red;     /* Color (1=red, 0=black) */
     KEY                 key;
     VALUE               value;
     struct Node *link[2]; /* Left (0) and right (1) links */
   };
 
 
   Node *new_node(const KEY &inKey, const VALUE &inValue)
   {
     Node *rn = (Node *)DO_ALLOC ( sizeof(*rn) );
 
     if ( rn == NULL )
       return NULL;
 
     rn->red = 1;
     rn->key = inKey;
     rn->value = inValue;
     rn->link[0] = rn->link[1] = NULL;
 
     return rn;
   }
 
 
   int is_red ( Node *node) { return node != NULL && node->red == 1; }
 
   Node     *root; /* Top of the tree */
   Node     *tmp_head; /* Top of the tree */
   size_t   size; /* Number of items (user-defined) */
};
 
 
 
 
#endif
 
 


