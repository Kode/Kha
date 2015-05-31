package js.support;

typedef Callback0 = Null<Error> -> Void;

typedef Callback1<A> = Null<Error> -> Null<A> -> Void;

typedef Callback2<A,B> = Null<Error> -> Null<A> -> Null<B> -> Void;

typedef Callback<T> = Callback1<T>;