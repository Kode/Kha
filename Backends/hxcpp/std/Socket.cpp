/* ************************************************************************ */
/*																			*/
/*  Neko Standard Library													*/
/*  Copyright (c)2005 Motion-Twin											*/
/*																			*/
/* This library is free software; you can redistribute it and/or			*/
/* modify it under the terms of the GNU Lesser General Public				*/
/* License as published by the Free Software Foundation; either				*/
/* version 2.1 of the License, or (at your option) any later version.		*/
/*																			*/
/* This library is distributed in the hope that it will be useful,			*/
/* but WITHOUT ANY WARRANTY; without even the implied warranty of			*/
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU		*/
/* Lesser General Public License or the LICENSE file for more details.		*/
/*																			*/
/* ************************************************************************ */
#include <string.h>
#include <hx/CFFI.h>
#ifdef NEKO_WINDOWS
#	include <winsock2.h>
#	define FDSIZE(n)	(sizeof(u_int) + (n) * sizeof(SOCKET))
#	define SHUT_WR		SD_SEND
#	define SHUT_RD		SD_RECEIVE
#	define SHUT_RDWR	SD_BOTH
	static bool init_done = false;
	static WSADATA init_data;
#else
#	include <sys/types.h>
#	include <sys/socket.h>
#	include <sys/time.h>
#	include <netinet/in.h>
#	include <arpa/inet.h>
#	include <unistd.h>
#	include <netdb.h>
#	include <fcntl.h>
#	include <errno.h>
#	include <stdio.h>
#	include <poll.h>
	typedef int SOCKET;
#	define closesocket close
#	define SOCKET_ERROR (-1)
#	define INVALID_SOCKET (-1)
#endif

#if defined(NEKO_WINDOWS) || defined(NEKO_MAC)
#	define MSG_NOSIGNAL 0
#endif

int __socket_prims() { return 0; }

typedef struct {
	int max;
#	ifdef NEKO_WINDOWS
	struct fd_set *fdr;
	struct fd_set *fdw;
	struct fd_set *outr;
	struct fd_set *outw;
#	else
	struct pollfd *fds;
	int rcount;
	int wcount;
#	endif
	value ridx;
	value widx;
} polldata;

DECLARE_KIND(k_socket);
DECLARE_KIND(k_poll);

typedef size_t socket_int;

#define val_poll(o)		((polldata*)val_data(o))

extern field id___s;


SOCKET val_sock(value inValue)
{
   if (!val_is_null(inValue))
   {
      if (val_is_kind(inValue,k_socket) )
         return ((SOCKET)(socket_int)val_data(inValue));
      inValue = val_field(inValue,id___s);
      if (val_is_kind(inValue,k_socket) )
         return ((SOCKET)(socket_int)val_data(inValue));
   }
   val_throw(alloc_string("Invalid soket handle"));
}


/**
	<doc>
	<h1>Socket</h1>
	<p>
	TCP and UDP sockets
	</p>
	</doc>
**/

static value block_error() {
	gc_exit_blocking();
#ifdef NEKO_WINDOWS
	int err = WSAGetLastError();
	if( err == WSAEWOULDBLOCK || err == WSAEALREADY )
#else
	if( errno == EAGAIN || errno == EWOULDBLOCK || errno == EINPROGRESS || errno == EALREADY )
#endif
		val_throw(alloc_string("Blocking"));
	return alloc_null();
}

/**
	socket_init : void -> void
	<doc>
	Initialize the socket API. Must be called at least once per process
	before using any socket or host function.
	</doc>
**/
static value socket_init() {
#ifdef NEKO_WINDOWS
	if( !init_done ) {
		WSAStartup(MAKEWORD(2,0),&init_data);
		init_done = true;
	}
#endif
	return alloc_bool(true);
}


/**
	socket_new : udp:bool -> 'socket
	<doc>Create a new socket, TCP or UDP</doc>
**/
static value socket_new( value udp ) {
	SOCKET s;
	val_check(udp,bool);
	if( val_bool(udp) )
		s = socket(AF_INET,SOCK_DGRAM,0);
	else
		s = socket(AF_INET,SOCK_STREAM,0);
	if( s == INVALID_SOCKET )
		return alloc_null();
#	ifdef NEKO_MAC
	setsockopt(s,SOL_SOCKET,SO_NOSIGPIPE,NULL,0);
#	endif
#	ifdef NEKO_POSIX
	// we don't want sockets to be inherited in case of exec
	{
		int old = fcntl(s,F_GETFD,0);
		if( old >= 0 ) fcntl(s,F_SETFD,old|FD_CLOEXEC);
	}
#	endif
	return alloc_abstract(k_socket,(void *)s);
}

/**
	socket_close : 'socket -> void
	<doc>Close a socket. Any subsequent operation on this socket will fail</doc>
**/
static value socket_close( value o ) {
	POSIX_LABEL(close_again);
	if( closesocket(val_sock(o)) ) {
		HANDLE_EINTR(close_again);
	}
	return alloc_bool(true);
}

/**
	socket_send_char : 'socket -> int -> void
	<doc>Send a character over a connected socket. Must be in the range 0..255</doc>
**/
static value socket_send_char( value o, value v ) {
	int c;
	unsigned char cc;
        SOCKET sock = val_sock(o);
	val_check(v,int);
	c = val_int(v);
	if( c < 0 || c > 255 )
		return alloc_null();
	cc = (unsigned char)c;
	gc_enter_blocking();
	POSIX_LABEL(send_char_again);
	if( send(sock,(const char *)&cc,1,MSG_NOSIGNAL) == SOCKET_ERROR ) {
		HANDLE_EINTR(send_char_again);
		return block_error();
	}
	gc_exit_blocking();
	return alloc_bool(true);
}

/**
	socket_send : 'socket -> buf:string -> pos:int -> len:int -> int
	<doc>Send up to [len] bytes from [buf] starting at [pos] over a connected socket.
	Return the number of bytes sent.</doc>
**/
static value socket_send( value o, value data, value pos, value len ) {
	int p,l,dlen;
	SOCKET sock = val_sock(o);
	val_check(pos,int);
	val_check(len,int);
        buffer buf = val_to_buffer(data);
        if (!buf)
           hx_failure("not bytebuffer");
	p = val_int(pos);
	l = val_int(len);
	dlen = buffer_size(buf);
	if( p < 0 || l < 0 || p > dlen || p + l > dlen )
		return alloc_null();
	gc_enter_blocking();
	dlen = send(sock, buffer_data(buf) + p , l, MSG_NOSIGNAL);
	if( dlen == SOCKET_ERROR )
		return block_error();
	gc_exit_blocking();
	return alloc_int(dlen);
}

/**
	socket_recv : 'socket -> buf:string -> pos:int -> len:int -> int
	<doc>Read up to [len] bytes from [buf] starting at [pos] from a connected socket.
	Return the number of bytes readed.</doc>
**/
static value socket_recv( value o, value data, value pos, value len ) {
	int p,l,dlen;
	SOCKET sock = val_sock(o);
	val_check(data,buffer);
	buffer buf = val_to_buffer(data);
	val_check(pos,int);
	val_check(len,int);
	p = val_int(pos);
	l = val_int(len);
	dlen = buffer_size(buf);
	if( p < 0 || l < 0 || p > dlen || p + l > dlen )
		return alloc_null();
	gc_enter_blocking();
	POSIX_LABEL(recv_again);
	dlen = recv(sock, buffer_data(buf) + p, l, MSG_NOSIGNAL);
	if( dlen == SOCKET_ERROR ) {
		HANDLE_EINTR(recv_again);
		return block_error();
	}
	gc_exit_blocking();
	return alloc_int(dlen);
}

/**
	socket_recv_char : 'socket -> int
	<doc>Read a single char from a connected socket.</doc>
**/
static value socket_recv_char( value o ) {
	int ret;
	unsigned char cc;
	SOCKET sock = val_sock(o);
	gc_enter_blocking();
	POSIX_LABEL(recv_char_again);
	ret = recv(sock,(char *)&cc,1,MSG_NOSIGNAL);
	if( ret == SOCKET_ERROR ) {
		HANDLE_EINTR(recv_char_again);
		return block_error();
	}
	gc_exit_blocking();
	if( ret == 0 )
		val_throw(alloc_string("Connection closed"));
	return alloc_int(cc);
}


/**
	socket_write : 'socket -> string -> void
	<doc>Send the whole content of a string over a connected socket.</doc>
**/
static value socket_write( value o, value data ) {
	const char *cdata;
	int datalen, slen;
	SOCKET sock = val_sock(o);
	val_check(data,buffer);
	buffer buf = val_to_buffer(data);
	cdata = buffer_data(buf);
	datalen = buffer_size(buf);
	gc_enter_blocking();
	while( datalen > 0 ) {
		POSIX_LABEL(write_again);
		slen = send(sock,cdata,datalen,MSG_NOSIGNAL);
		if( slen == SOCKET_ERROR ) {
			HANDLE_EINTR(write_again);
			return block_error();
		}
		cdata += slen;
		datalen -= slen;
	}
	gc_exit_blocking();
	return alloc_bool(true);
}


/**
	socket_read : 'socket -> string
	<doc>Read the whole content of a the data available from a socket until the connection close.
	If the socket hasn't been close by the other side, the function might block.
	</doc>
**/
static value socket_read( value o ) {
	buffer b;
	char buf[256];
	int len;
	SOCKET sock = val_sock(o);
	b = alloc_buffer(NULL);
	gc_enter_blocking();
	while( true ) {
		POSIX_LABEL(read_again);
		len = recv(sock,buf,256,MSG_NOSIGNAL);
		if( len == SOCKET_ERROR ) {
			HANDLE_EINTR(read_again);
			return block_error();
		}
		if( len == 0 )
			break;
	        gc_exit_blocking();
		buffer_append_sub(b,buf,len);
	        gc_enter_blocking();
	}
	gc_exit_blocking();
	return buffer_val(b);
}

/**
	host_resolve : string -> 'int32
	<doc>Resolve the given host string into an IP address.</doc>
**/
static value host_resolve( value host ) {
	unsigned int ip;
	val_check(host,string);
	ip = inet_addr(val_string(host));
	if( ip == INADDR_NONE ) {
		struct hostent *h;
#	if defined(NEKO_WINDOWS) || defined(NEKO_MAC) || defined(BLACKBERRY)
		h = gethostbyname(val_string(host));
#	else
		struct hostent hbase;
		char buf[1024];
		int errcode;
		gethostbyname_r(val_string(host),&hbase,buf,1024,&h,&errcode);
#	endif
		if( h == NULL )
			return alloc_null();
		ip = *((unsigned int*)h->h_addr);
	}
	return alloc_int32(ip);
}

/**
	host_to_string : 'int32 -> string
	<doc>Return a string representation of the IP address.</doc>
**/
static value host_to_string( value ip ) {
	struct in_addr i;
	val_check(ip,int);
	*(int*)&i = val_int(ip);
	return alloc_string( inet_ntoa(i) );
}

/**
	host_reverse : 'int32 -> string
	<doc>Reverse the DNS of the given IP address.</doc>
**/
static value host_reverse( value host ) {
	struct hostent *h;
	unsigned int ip;
	val_check(host,int);
	ip = val_int(host);
#	if defined(NEKO_WINDOWS) || defined(NEKO_MAC) || defined(ANDROID) || defined(BLACKBERRY)
	h = gethostbyaddr((char *)&ip,4,AF_INET);
#	else
	struct hostent htmp;
	int errcode;
	char buf[1024];
	gethostbyaddr_r((char *)&ip,4,AF_INET,&htmp,buf,1024,&h,&errcode);
#	endif
	if( h == NULL )
		return alloc_null();
	return alloc_string( h->h_name );
}

/**
	host_local : void -> string
	<doc>Return the local host name.</doc>
**/
static value host_local() {
	char buf[256];
	if( gethostname(buf,256) == SOCKET_ERROR )
		return alloc_null();
	return alloc_string(buf);
}

/**
	socket_connect : 'socket -> host:'int32 -> port:int -> void
	<doc>Connect the socket the given [host] and [port]</doc>
**/
static value socket_connect( value o, value host, value port ) {
	struct sockaddr_in addr;
	val_check(host,int);
	val_check(port,int);
	memset(&addr,0,sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(val_int(port));
	*(int*)&addr.sin_addr.s_addr = val_int(host);
	gc_enter_blocking();
	if( connect(val_sock(o),(struct sockaddr*)&addr,sizeof(addr)) != 0 )
	{
		gc_exit_blocking();
		val_throw(alloc_string("std@socket_connect"));
	}
	gc_exit_blocking();
	return alloc_bool(true);
}

/**
	socket_listen : 'socket -> int -> void
	<doc>Listen for a number of connections</doc>
**/
static value socket_listen( value o, value n ) {
	SOCKET sock = val_sock(o);
	val_check(n,int);
	gc_enter_blocking();
	if( listen(sock,val_int(n)) == SOCKET_ERROR )
	{
		gc_exit_blocking();
		return alloc_null();
	}
	gc_exit_blocking();
	return alloc_bool(true);
}

static fd_set INVALID;

static fd_set *make_socket_array( value a, fd_set *tmp, SOCKET *n ) {
	int i, len;
	SOCKET sock;
	FD_ZERO(tmp);
	if( val_is_null(a) )
		return tmp;
	if( !val_is_array(a) )
		return &INVALID;
	len = val_array_size(a);
	if( len > FD_SETSIZE )
		val_throw(alloc_string("Too many sockets in select"));
	for(i=0;i<len;i++) {
		value s = val_array_i(a,i);
                // make sure it is a socket...
		sock = val_sock(s);
		if( sock > *n )
			*n = sock;
		FD_SET(sock,tmp);
	}
	return tmp;
}

static value make_array_result( value a, fd_set *tmp ) {
	value r;
	int i, len;
	int pos = 0;
	if( tmp == NULL )
		return val_null;
	len = val_array_size(a);
	r = alloc_array(len);
	for(i=0;i<len;i++) {
		value s = val_array_i(a,i);
		if( FD_ISSET(val_sock(s),tmp) )
			val_array_set_i(r,pos++,s);
	}
	val_array_set_size(r,pos);
	return r;
}

static void init_timeval( double f, struct timeval *t ) {
	t->tv_usec = (f - (int)f ) * 1000000;
	t->tv_sec = (int)f;
}

/**
	socket_select : read : 'socket array -> write : 'socket array -> others : 'socket array -> timeout:number? -> 'socket array array
	<doc>Perform the [select] operation. Timeout is in seconds or [null] if infinite</doc>
**/
static value socket_select( value rs, value ws, value es, value timeout ) {
	struct timeval tval;
	struct timeval *tt;
	SOCKET n = 0;
	fd_set rx, wx, ex;
	fd_set *ra, *wa, *ea;
	value r;
	POSIX_LABEL(select_again);
	ra = make_socket_array(rs,&rx,&n);
	wa = make_socket_array(ws,&wx,&n);
	ea = make_socket_array(es,&ex,&n);
	if( ra == &INVALID || wa == &INVALID || ea == &INVALID )
	{
		val_throw( alloc_string("No valid sockets") );
		return alloc_null();
	}
	if( val_is_null(timeout) )
		tt = NULL;
	else {
		val_check(timeout,number);
		tt = &tval;
		init_timeval(val_number(timeout),tt);
	}
	gc_enter_blocking();
	if( select((int)(n+1),ra,wa,ea,tt) == SOCKET_ERROR ) {
		HANDLE_EINTR(select_again);
		gc_exit_blocking();
		char buf[100];
		sprintf(buf,"Select error %d", errno );
		val_throw( alloc_string(buf) );
	}
	gc_exit_blocking();
	r = alloc_array(3);
	val_array_set_i(r,0,make_array_result(rs,ra));
	val_array_set_i(r,1,make_array_result(ws,wa));
	val_array_set_i(r,2,make_array_result(es,ea));
	return r;
}

/**
	socket_bind : 'socket -> host : 'int -> port:int -> void
	<doc>Bind the socket for server usage on the given host and port</doc>
**/
static value socket_bind( value o, value host, value port ) {
	int opt = 1;
	struct sockaddr_in addr;
	SOCKET sock = val_sock(o);
	val_check(host,int);
	val_check(port,int);
	memset(&addr,0,sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(val_int(port));
	*(int*)&addr.sin_addr.s_addr = val_int(host);
	#ifndef NEKO_WINDOWS
	setsockopt(sock,SOL_SOCKET,SO_REUSEADDR,(char*)&opt,sizeof(opt));
	#endif
	gc_enter_blocking();
	if( bind(sock,(struct sockaddr*)&addr,sizeof(addr)) == SOCKET_ERROR )
	{
		gc_exit_blocking();
		val_throw(alloc_string("Bind failed"));
	}
	gc_exit_blocking();
	return alloc_bool(true);
}

/**
	socket_accept : 'socket -> 'socket
	<doc>Accept an incoming connection request</doc>
**/

#ifdef _WIN32
   typedef int SockLen;
#elif defined(ANDROID)
   typedef socklen_t SockLen;
#else
   typedef unsigned int SockLen;
#endif
static value socket_accept( value o ) {
	SOCKET sock = val_sock(o);
	struct sockaddr_in addr;
	SockLen addrlen = sizeof(addr);
	SOCKET s;
	gc_enter_blocking();
	s = accept(sock,(struct sockaddr*)&addr,&addrlen);
	if( s == INVALID_SOCKET )
		return block_error();
	gc_exit_blocking();
	return alloc_abstract(k_socket,(void *)(socket_int)s);
}

/**
	socket_peer : 'socket -> #address
	<doc>Return the socket connected peer address composed of an (host,port) array</doc>
**/
static value socket_peer( value o ) {
	SOCKET sock = val_sock(o);
	struct sockaddr_in addr;
	SockLen addrlen = sizeof(addr);
	value ret;
	if( getpeername(sock,(struct sockaddr*)&addr,&addrlen) == SOCKET_ERROR )
		return alloc_null();
	ret = alloc_array(2);
	val_array_set_i(ret,0,alloc_int32(*(int*)&addr.sin_addr));
	val_array_set_i(ret,1,alloc_int(ntohs(addr.sin_port)));
	return ret;
}

/**
	socket_host : 'socket -> #address
	<doc>Return the socket local address composed of an (host,port) array</doc>
**/
static value socket_host( value o ) {
	SOCKET sock = val_sock(o);
	struct sockaddr_in addr;
	SockLen addrlen = sizeof(addr);
	value ret;
	if( getsockname(sock,(struct sockaddr*)&addr,&addrlen) == SOCKET_ERROR )
		return alloc_null();
	ret = alloc_array(2);
	val_array_set_i(ret,0,alloc_int32(*(int*)&addr.sin_addr));
	val_array_set_i(ret,1,alloc_int(ntohs(addr.sin_port)));
	return ret;
}

/**
	socket_set_timeout : 'socket -> timout:number? -> void
	<doc>Set the socket send and recv timeout in seconds to the given value (or null for blocking)</doc>
**/
static value socket_set_timeout( value o, value t ) {
	SOCKET sock = val_sock(o);
#ifdef NEKO_WINDOWS
	int time;
	if( val_is_null(t) )
		time = 0;
	else {
		val_check(t,number);
		time = (int)(val_number(t) * 1000);
	}
#else
	struct timeval time;
	if( val_is_null(t) ) {
		time.tv_usec = 0;
		time.tv_sec = 0;
	} else {
		val_check(t,number);
		init_timeval(val_number(t),&time);
	}
#endif
	if( setsockopt(sock,SOL_SOCKET,SO_SNDTIMEO,(char*)&time,sizeof(time)) != 0 )
		return alloc_null();
	if( setsockopt(sock,SOL_SOCKET,SO_RCVTIMEO,(char*)&time,sizeof(time)) != 0 )
		return alloc_null();
	return alloc_bool(true);
}

/**
	socket_shutdown : 'socket -> read:bool -> write:bool -> void
	<doc>Prevent the socket from further reading or writing or both.</doc>
**/
static value socket_shutdown( value o, value r, value w ) {
	SOCKET sock = val_sock(o);
	val_check(r,bool);
	val_check(w,bool);
	if( !val_bool(r) && !val_bool(w) )
		return alloc_bool(true);
	gc_enter_blocking();
	if( shutdown(sock,val_bool(r)?(val_bool(w)?SHUT_RDWR:SHUT_RD):SHUT_WR) )
	{
		gc_exit_blocking();
		return alloc_null();
	}
	gc_exit_blocking();
	return alloc_bool(true);
}

/**
	socket_set_blocking : 'socket -> bool -> void
	<doc>Turn on/off the socket blocking mode.</doc>
**/
#include <stdlib.h>

static value socket_set_blocking( value o, value b ) {
	SOCKET sock = val_sock(o);
	val_check(b,bool);
#ifdef NEKO_WINDOWS
	{
		unsigned long arg = val_bool(b)?0:1;
		if( ioctlsocket(sock,FIONBIO,&arg) != 0 )
			return alloc_null();
	}
#else
	{
		int rights = fcntl(sock,F_GETFL);
		if( rights == -1 )
			return alloc_null();
		if( val_bool(b) )
			rights &= ~O_NONBLOCK;
		else
			rights |= O_NONBLOCK;
		if( fcntl(sock,F_SETFL,rights) == -1 )
			return alloc_null();
	}
#endif
	return alloc_bool(true);
}

/**
	socket_poll_alloc : int -> 'poll
	<doc>Allocate memory to perform polling on a given number of sockets</doc>
**/

void free_sock(value v)
{
	polldata *p = (polldata *)val_data(v);
#	ifdef NEKO_WINDOWS
	free(p->fdr);
	free(p->fdw);
	free(p->outr);
	free(p->outw);
#	else
#	endif
	val_gc_remove_root(&p->ridx);
	val_gc_remove_root(&p->widx);
	free(p);
}

static value socket_poll_alloc( value nsocks ) {
	polldata *p;
	int i;
	val_check(nsocks,int);
	p = (polldata*)malloc(sizeof(polldata));
	p->max = val_int(nsocks);
	if( p->max < 0 || p->max > 1000000 )
		return alloc_null();
#	ifdef NEKO_WINDOWS
	{
		p->fdr = (fd_set*)malloc(FDSIZE(p->max));
		p->fdw = (fd_set*)malloc(FDSIZE(p->max));
		p->outr = (fd_set*)malloc(FDSIZE(p->max));
		p->outw = (fd_set*)malloc(FDSIZE(p->max));
		p->fdr->fd_count = 0;
		p->fdw->fd_count = 0;
	}
#	else
	p->fds = (struct pollfd*)malloc(sizeof(struct pollfd) * p->max);
	p->rcount = 0;
	p->wcount = 0;
#	endif
	p->ridx = alloc_array(p->max+1);
	p->widx = alloc_array(p->max+1);
        val_gc_add_root(&p->ridx);
        val_gc_add_root(&p->widx);
	for(i=0;i<=p->max;i++) {
		val_array_set_i(p->ridx,i, alloc_int(-1));
		val_array_set_i(p->widx,i, alloc_int(-1));
	}
	value v = alloc_abstract(k_poll, p);
        val_gc(v,free_sock);
        return v;
}

/**
	socket_poll_prepare : 'poll -> read:'socket array -> write:'socket array -> int array array
	<doc>
	Prepare a poll for scanning events on sets of sockets.
	</doc>
**/
static value socket_poll_prepare( value pdata, value rsocks, value wsocks ) {
	polldata *p;
	int i,len;
	val_check(rsocks,array);
	val_check(wsocks,array);
	val_check_kind(pdata,k_poll);
	p = val_poll(pdata);
	len = val_array_size(rsocks);
	if( len + val_array_size(wsocks) > p->max )
		val_throw(alloc_string("Too many sockets in poll"));
#	ifdef NEKO_WINDOWS
	for(i=0;i<len;i++) {
		value s = val_array_i(rsocks,i);
		p->fdr->fd_array[i] = val_sock(s);
	}
	p->fdr->fd_count = len;
	len = val_array_size(wsocks);
	for(i=0;i<len;i++) {
		value s = val_array_i(wsocks,i);
		p->fdw->fd_array[i] = val_sock(s);
	}
	p->fdw->fd_count = len;
#	else
	for(i=0;i<len;i++) {
		value s = val_array_i(rsocks,i);
		p->fds[i].fd = val_sock(s);
		p->fds[i].events = POLLIN;
		p->fds[i].revents = 0;
	}
	p->rcount = len;
	len = val_array_size(wsocks);
	for(i=0;i<len;i++) {
		int k = i + p->rcount;
		value s = val_array_i(wsocks,i);
		p->fds[k].fd = val_sock(s);
		p->fds[k].events = POLLOUT;
		p->fds[k].revents = 0;
	}
	p->wcount = len;
#	endif
	{
		value a = alloc_array(2);
		val_array_set_i(a,0, p->ridx);
		val_array_set_i(a,1, p->widx);
		return a;
	}
}

/**
	socket_poll_events : 'poll -> timeout:float -> void
	<doc>
	Update the read/write flags arrays that were created with [socket_poll_prepare].
	</doc>
**/
static value socket_poll_events( value pdata, value timeout ) {
	polldata *p;
#	ifdef NEKO_WINDOWS
	unsigned int i;
	int k = 0;
	struct timeval t;
	val_check_kind(pdata,k_poll);
	p = val_poll(pdata);
	memcpy(p->outr,p->fdr,FDSIZE(p->fdr->fd_count));
	memcpy(p->outw,p->fdw,FDSIZE(p->fdw->fd_count));
	val_check(timeout,number);
	init_timeval(val_number(timeout),&t);
	gc_enter_blocking();
	if( p->fdr->fd_count + p->fdw->fd_count != 0 && select(0,p->outr,p->outw,NULL,&t) == SOCKET_ERROR )
	{
		gc_exit_blocking();
		return alloc_null();
	}
	gc_exit_blocking();
	k = 0;
	for(i=0;i<p->fdr->fd_count;i++)
		if( FD_ISSET(p->fdr->fd_array[i],p->outr) )
			val_array_set_i(p->ridx,k++,alloc_int(i));
	val_array_set_i(p->ridx,k,alloc_int(-1));
	k = 0;
	for(i=0;i<p->fdw->fd_count;i++)
		if( FD_ISSET(p->fdw->fd_array[i],p->outw) )
			val_array_set_i(p->widx,k++, alloc_int(i));
	val_array_set_i(p->widx,k,alloc_int(-1));
#else
	int i,k;
	int tot;
	val_check_kind(pdata,k_poll);
	val_check(timeout,number);
	p = val_poll(pdata);
	tot = p->rcount + p->wcount;
	gc_enter_blocking();
	POSIX_LABEL(poll_events_again);
	if( poll(p->fds,tot,(int)(val_number(timeout) * 1000)) < 0 ) {
		HANDLE_EINTR(poll_events_again);
		gc_exit_blocking();
		return alloc_null();
	}
	gc_exit_blocking();
	k = 0;
	for(i=0;i<p->rcount;i++)
		if( p->fds[i].revents & (POLLIN|POLLHUP) )
			val_array_set_i(p->ridx,k++,alloc_int(i));
	val_array_set_i(p->ridx,k, alloc_int(-1));
	k = 0;
	for(;i<tot;i++)
		if( p->fds[i].revents & (POLLOUT|POLLHUP) )
			val_array_set_i(p->widx,k++, alloc_int(i - p->rcount));
	val_array_set_i(p->widx,k, alloc_int(-1));
#endif
	return val_null;
}


/**
	socket_poll : 'socket array -> 'poll -> timeout:float -> 'socket array
	<doc>
	Perform a polling for data available over a given set of sockets. This is similar to [socket_select]
	except that [socket_select] is limited to a given number of simultaneous sockets to check.
	</doc>
**/
static value socket_poll( value socks, value pdata, value timeout ) {
	polldata *p;
	value a;
	int i, rcount = 0;
	if( val_is_null( socket_poll_prepare(pdata,socks,alloc_array(0))) )
		return alloc_null();
	if( val_is_null( socket_poll_events(pdata,timeout) ) )
		return alloc_null();
	p = val_poll(pdata);
	while( val_int(val_array_i(p->ridx,rcount)) != -1 )
		rcount++;
	a = alloc_array(rcount);
	for(i=0;i<rcount;i++)
		val_array_set_i(a,i, val_array_i(socks,val_int(val_array_i(p->ridx,i))));
	return a;
}

DEFINE_PRIM(socket_init,0);
DEFINE_PRIM(socket_new,1);
DEFINE_PRIM(socket_send,4);
DEFINE_PRIM(socket_send_char,2);
DEFINE_PRIM(socket_recv,4);
DEFINE_PRIM(socket_recv_char,1);
DEFINE_PRIM(socket_write,2);
DEFINE_PRIM(socket_read,1);
DEFINE_PRIM(socket_close,1);
DEFINE_PRIM(socket_connect,3);
DEFINE_PRIM(socket_listen,2);
DEFINE_PRIM(socket_select,4);
DEFINE_PRIM(socket_bind,3);
DEFINE_PRIM(socket_accept,1);
DEFINE_PRIM(socket_peer,1);
DEFINE_PRIM(socket_host,1);
DEFINE_PRIM(socket_set_timeout,2);
DEFINE_PRIM(socket_shutdown,3);
DEFINE_PRIM(socket_set_blocking,2);

DEFINE_PRIM(socket_poll_alloc,1);
DEFINE_PRIM(socket_poll,3);
DEFINE_PRIM(socket_poll_prepare,3);
DEFINE_PRIM(socket_poll_events,2);

DEFINE_PRIM(host_local,0);
DEFINE_PRIM(host_resolve,1);
DEFINE_PRIM(host_to_string,1);
DEFINE_PRIM(host_reverse,1);

/* ************************************************************************ */
