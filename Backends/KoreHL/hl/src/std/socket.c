/*
 * Copyright (C)2005-2016 Haxe Foundation
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
#include <string.h>
#define _WINSOCKAPI_
#include <hl.h>
#ifdef HL_WIN
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
#	include <netinet/tcp.h>
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
#ifdef HL_LINUX
#	include <linux/version.h>
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,5,44)
#	include <sys/epoll.h>
#	define HAS_EPOLL
#endif
#endif
#ifndef HAS_EPOLL
#	define EPOLLIN 0x001
#	define EPOLLOUT 0x004
#endif

#if defined(HL_WIN) || defined(HL_MAC)
#	define MSG_NOSIGNAL 0
#endif

typedef struct _hl_socket {
	SOCKET sock;
} hl_socket;

static int block_error() {
#ifdef HL_WIN
	int err = WSAGetLastError();
	if( err == WSAEWOULDBLOCK || err == WSAEALREADY || err == WSAETIMEDOUT )
#else
	if( errno == EAGAIN || errno == EWOULDBLOCK || errno == EINPROGRESS || errno == EALREADY )
#endif
		return -1;
	return -2;
}

void hl_socket_init() {
#ifdef HL_WIN
	if( !init_done ) {
		WSAStartup(MAKEWORD(2,0),&init_data);
		init_done = true;
	}
#endif
}

hl_socket *hl_socket_new( bool udp ) {
	SOCKET s;
	if( udp )
		s = socket(AF_INET,SOCK_DGRAM,0);
	else
		s = socket(AF_INET,SOCK_STREAM,0);
	if( s == INVALID_SOCKET )
		return NULL;
#	ifdef HL_MAC
	setsockopt(s,SOL_SOCKET,SO_NOSIGPIPE,NULL,0);
#	endif
#	ifdef HL_POSIX
	// we don't want sockets to be inherited in case of exec
	{
		int old = fcntl(s,F_GETFD,0);
		if( old >= 0 ) fcntl(s,F_SETFD,old|FD_CLOEXEC);
	}
#	endif
	{
		hl_socket *hs = hl_gc_alloc_noptr(sizeof(hl_socket));
		hs->sock = s;
		return hs;
	}
}

void hl_socket_close( hl_socket *s ) {
	closesocket(s->sock);
	s->sock = INVALID_SOCKET;
}

int hl_socket_send_char( hl_socket *s, int c ) {
	unsigned char cc;
	cc = (unsigned char)c;
	if( send(s->sock,&cc,1,MSG_NOSIGNAL) == SOCKET_ERROR )
		return block_error();
	return 1;
}

int hl_socket_send( hl_socket *s, vbyte *buf, int pos, int len ) {
	int r = send(s->sock, (char*)buf + pos, len, MSG_NOSIGNAL);
	if( len == SOCKET_ERROR )
		return block_error();
	return len;
}


int hl_socket_recv( hl_socket *s, vbyte *buf, int pos, int len ) {
	int	ret = recv(s->sock, (char*)buf + pos, len, MSG_NOSIGNAL);
	if( ret == SOCKET_ERROR )
		return block_error();
	return ret;
}

int hl_socket_recv_char( hl_socket *s ) {
	unsigned char cc;
	int ret = recv(s->sock,&cc,1,MSG_NOSIGNAL);
	if( ret == SOCKET_ERROR || ret == 0 )
		return block_error();
	return cc;
}

int hl_host_resolve( vbyte *host ) {
	unsigned int ip;
	ip = inet_addr((char*)host);
	if( ip == INADDR_NONE ) {
		struct hostent *h;
#	if defined(HL_WIN) || defined(HL_MAC)
		h = gethostbyname((char*)host);
#	else
		struct hostent hbase;
		char buf[1024];
		int errcode;
		gethostbyname_r((char*)host,&hbase,buf,1024,&h,&errcode);
#	endif
		if( h == NULL )
			return 0;
		ip = *((unsigned int*)h->h_addr);
	}
	return ip;
}

vbyte *hl_host_to_string( int ip ) {
	struct in_addr i;
	*(int*)&i = ip;
	return (vbyte*)inet_ntoa(i);
}

vbyte *hl_host_reverse( int ip ) {
	struct hostent *h;
#	if defined(HL_WIN) || defined(HL_MAC)
	h = gethostbyaddr((char *)&ip,4,AF_INET);
#	else
	struct hostent htmp;
	int errcode;
	char buf[1024];
	gethostbyaddr_r((char*)&ip,4,AF_INET,&htmp,buf,1024,&h,&errcode);
#	endif
	if( h == NULL )
		return NULL; 
	return (vbyte*)h->h_name;
}

vbyte *hl_host_local() {
	char buf[256];
	if( gethostname(buf,256) == SOCKET_ERROR )
		return NULL;
	return hl_copy_bytes((vbyte*)buf,(int)strlen(buf)+1);
}

bool hl_socket_connect( hl_socket *s, int host, int port ) {
	struct sockaddr_in addr;
	memset(&addr,0,sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	*(int*)&addr.sin_addr.s_addr = host;
	if( connect(s->sock,(struct sockaddr*)&addr,sizeof(addr)) != 0 ) {
		int err = block_error();
		if( err == -1 ) return true; // in progress
		return false;
	}
	return true;
}

bool hl_socket_listen( hl_socket *s, int n ) {
	return listen(s->sock,n) != SOCKET_ERROR;
}

bool hl_socket_bind( hl_socket *s, int host, int port ) {
	int opt = 1;
	struct sockaddr_in addr;
	memset(&addr,0,sizeof(addr));
	addr.sin_family = AF_INET;
	addr.sin_port = htons(port);
	*(int*)&addr.sin_addr.s_addr = host;
	#ifndef HL_WIN
	setsockopt(s->sock,SOL_SOCKET,SO_REUSEADDR,(char*)&opt,sizeof(opt));
	#endif
	return bind(s->sock,(struct sockaddr*)&addr,sizeof(addr)) != SOCKET_ERROR;
}

hl_socket *hl_socket_accept( hl_socket *s ) {
	struct sockaddr_in addr;
	unsigned int addrlen = sizeof(addr);
	SOCKET nsock;
	hl_socket *hs;
	nsock = accept(s->sock,(struct sockaddr*)&addr,&addrlen);
	if( nsock == INVALID_SOCKET )
		return NULL;
	hs = (hl_socket*)hl_gc_alloc_noptr(sizeof(hl_socket));
	hs->sock = nsock;
	return hs;
}

bool hl_socket_peer( hl_socket *s, int *host, int *port ) {
	struct sockaddr_in addr;
	unsigned int addrlen = sizeof(addr);
	if( getpeername(s->sock,(struct sockaddr*)&addr,&addrlen) == SOCKET_ERROR )
		return false;
	*host = *(int*)&addr.sin_addr;
	*port = ntohs(addr.sin_port);
	return true;
}

bool hl_socket_host( hl_socket *s, int *host, int *port ) {
	struct sockaddr_in addr;
	unsigned int addrlen = sizeof(addr);
	if( getsockname(s->sock,(struct sockaddr*)&addr,&addrlen) == SOCKET_ERROR )
		return false;
	*host = *(int*)&addr.sin_addr;
	*port = ntohs(addr.sin_port);
	return true;
}

bool hl_socket_set_timeout( hl_socket *s, double t ) {
#ifdef HL_WIN
	int time = (int)(t * 1000);
#else
	struct timeval time;
	//init_timeval(t,&time);
#endif
	if( setsockopt(s->sock,SOL_SOCKET,SO_SNDTIMEO,(char*)&time,sizeof(time)) != 0 )
		return false;
	if( setsockopt(s->sock,SOL_SOCKET,SO_RCVTIMEO,(char*)&time,sizeof(time)) != 0 )
		return false;
	return true;
}

bool hl_socket_shutdown( hl_socket *s, bool r, bool w ) {
	if( !r && !w )
		return true;
	return shutdown(s->sock,r?(w?SHUT_RDWR:SHUT_RD):SHUT_WR) == 0;
}

bool hl_socket_set_blocking( hl_socket *s, bool b ) {
#ifdef HL_WIN
	unsigned long arg = b?0:1;
	return ioctlsocket(s->sock,FIONBIO,&arg) == 0;
#else
	int rights = fcntl(s->sock,F_GETFL);
	if( rights == -1 )
		return false;
	if( b )
		rights &= ~O_NONBLOCK;
	else
		rights |= O_NONBLOCK;
	return false;//fcntl(val_sock(o),F_SETFL,rights) != -1;
#endif
}

bool hl_socket_set_fast_send( hl_socket *s, bool b ) {
	int fast = b;
	return setsockopt(s->sock,IPPROTO_TCP,TCP_NODELAY,(char*)&fast,sizeof(fast)) == 0;
}
