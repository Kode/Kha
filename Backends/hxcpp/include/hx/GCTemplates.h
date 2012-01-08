#ifndef HX_GC_TEMPLATES_H
#define HX_GC_TEMPLATES_H



namespace hx
{


template<typename T> inline void MarkMember(T &outT HX_MARK_ADD_PARAMS) { }

template<typename T> inline void MarkMember(hx::ObjectPtr<T> &outT HX_MARK_ADD_PARAMS)
{
	HX_MARK_OBJECT(outT.mPtr);
}
template<> inline void MarkMember(Dynamic &outT HX_MARK_ADD_PARAMS)
{
	HX_MARK_OBJECT(outT.mPtr);
}
template<typename T> inline void MarkMember(Array<T> &outT HX_MARK_ADD_PARAMS)
{
	HX_MARK_OBJECT(outT.mPtr);
}
template<> inline void MarkMember<int>(int &outT HX_MARK_ADD_PARAMS) {  }
template<> inline void MarkMember<bool>(bool &outT HX_MARK_ADD_PARAMS) {  }
template<> inline void MarkMember<double>(double &outT HX_MARK_ADD_PARAMS) {  }
template<> inline void MarkMember<String>(String &outT HX_MARK_ADD_PARAMS)
{
   HX_MARK_STRING(outT.__s);
}
template<> inline void MarkMember<Void>(Void &outT HX_MARK_ADD_PARAMS) {  }


// Template used to register and initialise the statics in the one call.
//  Do nothing...
template<typename T> inline T &Static(T &t) {  return t; }


} // end namespace hx




#endif
