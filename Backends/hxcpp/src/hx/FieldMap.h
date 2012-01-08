#ifndef HX_FIELD_MAP_H
#define HX_FIELD_MAP_H


inline int DoCompare(const String &inA, const String &inB)
{
	return inA.compare(inB);
}

#include "RedBlack.h"

namespace hx
{

class FieldMap : public RBTree<String,Dynamic>
{
};

struct KeyGetter
{
	KeyGetter(Array<String> &inArray) : mArray(inArray)  { }
	void Visit(void *, const String &inStr, const Dynamic &) { mArray->push(inStr); }
	Array<String> &mArray;
};

} // end namespace hx



#endif
