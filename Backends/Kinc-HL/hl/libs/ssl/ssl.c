#define HL_NAME(n) ssl_##n

#define _WINSOCKAPI_
#include <hl.h>
#ifdef HL_WIN
#include <winsock2.h>
#include <wincrypt.h>
#else
#include <sys/socket.h>
#include <strings.h>
#include <errno.h>
typedef int SOCKET;
#endif

#include <stdio.h>
#include <string.h>

#ifdef HL_MAC
#include <Security/Security.h>
#endif

#define SOCKET_ERROR (-1)
#define NRETRYS	20

#include "mbedtls/platform.h"
#include "mbedtls/error.h"
#include "mbedtls/entropy.h"
#include "mbedtls/ctr_drbg.h"
#include "mbedtls/md.h"
#include "mbedtls/pk.h"
#include "mbedtls/oid.h"
#include "mbedtls/x509_crt.h"
#include "mbedtls/ssl.h"

#ifdef HL_CONSOLE
mbedtls_x509_crt *hl_init_cert_chain();
#endif

#if defined(HL_WIN) || defined(HL_MAC) || defined(HL_IOS) || defined(HL_TVOS)
#	define MSG_NOSIGNAL 0
#endif

// Duplicate from socket.c
typedef struct _hl_socket {
	SOCKET sock;
} hl_socket;

typedef struct _hl_ssl_cert hl_ssl_cert;
struct _hl_ssl_cert {
	void(*finalize)(hl_ssl_cert *);
	mbedtls_x509_crt *c;
};

typedef struct _hl_ssl_pkey hl_ssl_pkey;
struct _hl_ssl_pkey {
	void(*finalize)(hl_ssl_pkey *);
	mbedtls_pk_context *k;
};

#define _SOCK	_ABSTRACT(hl_socket)
#define TSSL _ABSTRACT(mbedtls_ssl_context)
#define TCONF _ABSTRACT(mbedtls_ssl_config)
#define TCERT _ABSTRACT(hl_ssl_cert)
#define TPKEY _ABSTRACT(hl_ssl_pkey)

static bool ssl_init_done = false;
static mbedtls_entropy_context entropy;
static mbedtls_ctr_drbg_context ctr_drbg;

static bool is_ssl_blocking( int r ) {
	return r == MBEDTLS_ERR_SSL_WANT_READ || r == MBEDTLS_ERR_SSL_WANT_WRITE;
}

static int ssl_block_error( int r ) {
	return is_ssl_blocking(r) ? -1 : -2;
}

static void cert_finalize(hl_ssl_cert *c) {
	mbedtls_x509_crt_free(c->c);
	free(c->c);
	c->c = NULL;
}

static void pkey_finalize(hl_ssl_pkey *k) {
	mbedtls_pk_free(k->k);
	free(k->k);
	k->k = NULL;
}

static int ssl_error(int ret) {
	char buf[128];
	uchar buf16[128];
	mbedtls_strerror(ret, buf, sizeof(buf));
	hl_from_utf8(buf16, (int)strlen(buf), buf);
	hl_error("%s",buf16);
	return ret;
}

HL_PRIM mbedtls_ssl_context *HL_NAME(ssl_new)(mbedtls_ssl_config *config) {
	int ret;
	mbedtls_ssl_context *ssl;
	ssl = (mbedtls_ssl_context *)hl_gc_alloc_noptr(sizeof(mbedtls_ssl_context));
	mbedtls_ssl_init(ssl);
	if ((ret = mbedtls_ssl_setup(ssl, config)) != 0) {
		mbedtls_ssl_free(ssl);
		ssl_error(ret);
		return NULL;
	}
	return ssl;
}

HL_PRIM void HL_NAME(ssl_close)(mbedtls_ssl_context *ssl) {
	mbedtls_ssl_free(ssl);
}

HL_PRIM int HL_NAME(ssl_handshake)(mbedtls_ssl_context *ssl) {
	int r;
	r = mbedtls_ssl_handshake(ssl);
	if( is_ssl_blocking(r) )
		return -1;
	if( r == MBEDTLS_ERR_SSL_CONN_EOF )
		return -2;
	if( r != 0 )
		return ssl_error(r);
	return 0;
}


static bool is_block_error() {
#ifdef HL_WIN
	int err = WSAGetLastError();
	if (err == WSAEWOULDBLOCK || err == WSAEALREADY || err == WSAETIMEDOUT)
#else
	if (errno == EAGAIN || errno == EWOULDBLOCK || errno == EINPROGRESS || errno == EALREADY)
#endif
		return true;
	return false;
}

static int net_read(void *fd, unsigned char *buf, size_t len) {
	int r = recv((SOCKET)(int_val)fd, (char *)buf, (int)len, MSG_NOSIGNAL);
	if( r == SOCKET_ERROR && is_block_error() )
		return MBEDTLS_ERR_SSL_WANT_READ;
	return r;
}

static int net_write(void *fd, const unsigned char *buf, size_t len) {
	int r = send((SOCKET)(int_val)fd, (char *)buf, (int)len, MSG_NOSIGNAL);
	if( r == SOCKET_ERROR && is_block_error() )
		return MBEDTLS_ERR_SSL_WANT_WRITE;
	return r;
}

HL_PRIM void HL_NAME(ssl_set_socket)(mbedtls_ssl_context *ssl, hl_socket *socket) {
	mbedtls_ssl_set_bio(ssl, (void*)(int_val)socket->sock, net_write, net_read, NULL);
}

static int arr_read( void *arr, unsigned char *buf, size_t len ) {
	int r = ((int (*)(vdynamic*,unsigned char*,int))hl_aptr(arr,vclosure*)[1]->fun)( hl_aptr(arr,vdynamic*)[0], buf, (int)len );
	if( r == -2 ) return MBEDTLS_ERR_SSL_WANT_READ;
	return r;
}

static int arr_write( void *arr, const unsigned char *buf, size_t len ) {
	int r = ((int (*)(vdynamic*,const unsigned char*,int))hl_aptr(arr,vclosure*)[2]->fun)( hl_aptr(arr,vdynamic*)[0], buf, (int)len );
	if( r == -2 ) return MBEDTLS_ERR_SSL_WANT_WRITE;
	return r;
}

HL_PRIM void HL_NAME(ssl_set_bio)( mbedtls_ssl_context *ssl, varray *ctx ) {
	mbedtls_ssl_set_bio(ssl, ctx, arr_write, arr_read, NULL);	
}

HL_PRIM void HL_NAME(ssl_set_hostname)(mbedtls_ssl_context *ssl, vbyte *hostname) {
	int ret;
	if ((ret = mbedtls_ssl_set_hostname(ssl, (char*)hostname)) != 0)
		ssl_error(ret);
}

HL_PRIM hl_ssl_cert *HL_NAME(ssl_get_peer_certificate)(mbedtls_ssl_context *ssl) {
	hl_ssl_cert *cert = (hl_ssl_cert*)hl_gc_alloc_noptr(sizeof(hl_ssl_cert));
	cert->c = (mbedtls_x509_crt*)mbedtls_ssl_get_peer_cert(ssl);
	return cert;
}

DEFINE_PRIM(TSSL, ssl_new, TCONF);
DEFINE_PRIM(_VOID, ssl_close, TSSL);
DEFINE_PRIM(_I32, ssl_handshake, TSSL);
DEFINE_PRIM(_VOID, ssl_set_bio, TSSL _DYN);
DEFINE_PRIM(_VOID, ssl_set_socket, TSSL _SOCK);
DEFINE_PRIM(_VOID, ssl_set_hostname, TSSL _BYTES);
DEFINE_PRIM(TCERT, ssl_get_peer_certificate, TSSL);

HL_PRIM int HL_NAME(ssl_send_char)(mbedtls_ssl_context *ssl, int c) {
	unsigned char cc;
	int r;
	cc = (unsigned char)c;
	r = mbedtls_ssl_write(ssl, &cc, 1);
	if( r < 0 )
		return ssl_block_error(r);
	return 1;
}

HL_PRIM int HL_NAME(ssl_send)(mbedtls_ssl_context *ssl, vbyte *buf, int pos, int len) {
	int r = mbedtls_ssl_write(ssl, (const unsigned char *)buf + pos, len);
	if( r < 0 ) 
		return ssl_block_error(r);
	return r;
}

HL_PRIM int HL_NAME(ssl_recv_char)(mbedtls_ssl_context *ssl) {
	unsigned char c;
	int ret = mbedtls_ssl_read(ssl, &c, 1);
	if( ret != 1 )
		return ssl_block_error(ret);
	return c;
}

HL_PRIM int HL_NAME(ssl_recv)(mbedtls_ssl_context *ssl, vbyte *buf, int pos, int len) {
	int ret = mbedtls_ssl_read(ssl, (unsigned char*)buf+pos, len);
	if( ret == MBEDTLS_ERR_SSL_PEER_CLOSE_NOTIFY )
		return 0;
	if( ret < 0 )
		return ssl_block_error(ret);
	return ret;
}

DEFINE_PRIM(_I32, ssl_send_char, TSSL _I32);
DEFINE_PRIM(_I32, ssl_send, TSSL _BYTES _I32 _I32);
DEFINE_PRIM(_I32, ssl_recv_char, TSSL);
DEFINE_PRIM(_I32, ssl_recv, TSSL _BYTES _I32 _I32);

HL_PRIM mbedtls_ssl_config *HL_NAME(conf_new)(bool server) {
	int ret;
	mbedtls_ssl_config *conf;
	conf = (mbedtls_ssl_config *)hl_gc_alloc_noptr(sizeof(mbedtls_ssl_config));
	mbedtls_ssl_config_init(conf);
	if ((ret = mbedtls_ssl_config_defaults(conf, server ? MBEDTLS_SSL_IS_SERVER : MBEDTLS_SSL_IS_CLIENT,
		MBEDTLS_SSL_TRANSPORT_STREAM, 0)) != 0) {
		mbedtls_ssl_config_free(conf);
		ssl_error(ret);
		return NULL;
	}
	mbedtls_ssl_conf_rng(conf, mbedtls_ctr_drbg_random, &ctr_drbg);
	return conf;
}

HL_PRIM void HL_NAME(conf_close)(mbedtls_ssl_config *conf) {
	mbedtls_ssl_config_free(conf);
}

HL_PRIM void HL_NAME(conf_set_ca)(mbedtls_ssl_config *conf, hl_ssl_cert *cert) {
	mbedtls_ssl_conf_ca_chain(conf, cert->c, NULL);
}

HL_PRIM void HL_NAME(conf_set_verify)(mbedtls_ssl_config *conf, int mode) {
	if (mode == 2)
		mbedtls_ssl_conf_authmode(conf, MBEDTLS_SSL_VERIFY_OPTIONAL);
	else if (mode == 1)
		mbedtls_ssl_conf_authmode(conf, MBEDTLS_SSL_VERIFY_REQUIRED);
	else
		mbedtls_ssl_conf_authmode(conf, MBEDTLS_SSL_VERIFY_NONE);
}

HL_PRIM void HL_NAME(conf_set_cert)(mbedtls_ssl_config *conf, hl_ssl_cert *cert, hl_ssl_pkey *key) {
	int r;
	if ((r = mbedtls_ssl_conf_own_cert(conf, cert->c, key->k)) != 0)
		ssl_error(r);
}

typedef struct {
	hl_type *t;
	hl_ssl_cert *cert;
	hl_ssl_pkey *key;
} sni_callb_ret;

static int sni_callback(void *arg, mbedtls_ssl_context *ctx, const unsigned char *name, size_t len) {
	if (name && arg) {
		vclosure *c = (vclosure*)arg;
		sni_callb_ret *ret;
		if( c->hasValue )
			ret = ((sni_callb_ret*(*)(void*, vbyte*))c->fun)(c->value, (vbyte*)name);
		else
			ret = ((sni_callb_ret*(*)(vbyte*))c->fun)((vbyte*)name);
		if (ret && ret->cert && ret->key) {
			return mbedtls_ssl_set_hs_own_cert(ctx, ret->cert->c, ret->key->k);
		}
	}
	return -1;
}

HL_PRIM void HL_NAME(conf_set_servername_callback)(mbedtls_ssl_config *conf, vclosure *cb) {
	mbedtls_ssl_conf_sni(conf, sni_callback, (void *)cb);
}


DEFINE_PRIM(TCONF, conf_new, _BOOL);
DEFINE_PRIM(_VOID, conf_close, TCONF);
DEFINE_PRIM(_VOID, conf_set_ca, TCONF TCERT);
DEFINE_PRIM(_VOID, conf_set_verify, TCONF _I32);
DEFINE_PRIM(_VOID, conf_set_cert, TCONF TCERT TPKEY);
DEFINE_PRIM(_VOID, conf_set_servername_callback, TCONF _FUN(_OBJ(TCERT TPKEY), _BYTES));

HL_PRIM hl_ssl_cert *HL_NAME(cert_load_file)(vbyte *file) {
#ifdef HL_CONSOLE
	return NULL;
#else
	int r;
	hl_ssl_cert *cert;
	mbedtls_x509_crt *x = (mbedtls_x509_crt*)malloc(sizeof(mbedtls_x509_crt));
	mbedtls_x509_crt_init(x);
	if ((r = mbedtls_x509_crt_parse_file(x, (char*)file)) != 0) {
		mbedtls_x509_crt_free(x);
		free(x);
		ssl_error(r);
		return NULL;
	}
	cert = (hl_ssl_cert*)hl_gc_alloc_finalizer(sizeof(hl_ssl_cert));
	cert->c = x;
	cert->finalize = cert_finalize;
	return cert;
#endif
}

HL_PRIM hl_ssl_cert *HL_NAME(cert_load_path)(vbyte *path) {
#ifdef HL_CONSOLE
	return NULL;
#else
	int r;
	hl_ssl_cert *cert;
	mbedtls_x509_crt *x = (mbedtls_x509_crt*)malloc(sizeof(mbedtls_x509_crt));
	mbedtls_x509_crt_init(x);
	if ((r = mbedtls_x509_crt_parse_path(x, (char*)path)) != 0) {
		mbedtls_x509_crt_free(x);
		free(x);
		ssl_error(r);
		return NULL;
	}
	cert = (hl_ssl_cert*)hl_gc_alloc_finalizer(sizeof(hl_ssl_cert));
	cert->c = x;
	cert->finalize = cert_finalize;
	return cert;
#endif
}

HL_PRIM hl_ssl_cert *HL_NAME(cert_load_defaults)() {
	hl_ssl_cert *v = NULL;
	mbedtls_x509_crt *chain = NULL;
#if defined(HL_WIN)
	HCERTSTORE store;
	PCCERT_CONTEXT cert;
	
	if (store = CertOpenSystemStore(0, (LPCWSTR)L"Root")) {
		cert = NULL;
		while (cert = CertEnumCertificatesInStore(store, cert)) {
			if (chain == NULL) {
				chain = (mbedtls_x509_crt*)malloc(sizeof(mbedtls_x509_crt));
				mbedtls_x509_crt_init(chain);
			}
			mbedtls_x509_crt_parse_der(chain, (unsigned char *)cert->pbCertEncoded, cert->cbCertEncoded);
		}
		CertCloseStore(store, 0);
	}
#elif defined(HL_MAC)
	CFMutableDictionaryRef search;
	CFArrayRef result;
	SecKeychainRef keychain;
	SecCertificateRef item;
	CFDataRef dat;
	// Load keychain
	if (SecKeychainOpen("/System/Library/Keychains/SystemRootCertificates.keychain", &keychain) != errSecSuccess)
		return NULL;

	// Search for certificates
	search = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
	CFDictionarySetValue(search, kSecClass, kSecClassCertificate);
	CFDictionarySetValue(search, kSecMatchLimit, kSecMatchLimitAll);
	CFDictionarySetValue(search, kSecReturnRef, kCFBooleanTrue);
	CFDictionarySetValue(search, kSecMatchSearchList, CFArrayCreate(NULL, (const void **)&keychain, 1, NULL));
	if (SecItemCopyMatching(search, (CFTypeRef *)&result) == errSecSuccess) {
		CFIndex n = CFArrayGetCount(result);
		for (CFIndex i = 0; i < n; i++) {
			item = (SecCertificateRef)CFArrayGetValueAtIndex(result, i);

			// Get certificate in DER format
			dat = SecCertificateCopyData(item);
			if (dat) {
				if (chain == NULL) {
					chain = (mbedtls_x509_crt*)malloc(sizeof(mbedtls_x509_crt));
					mbedtls_x509_crt_init(chain);
				}
				mbedtls_x509_crt_parse_der(chain, (unsigned char *)CFDataGetBytePtr(dat), CFDataGetLength(dat));
				CFRelease(dat);
			}
		}
	}
	CFRelease(keychain);
#elif defined(HL_CONSOLE)
	chain = hl_init_cert_chain();
#endif
	if (chain != NULL) {
		v = (hl_ssl_cert*)hl_gc_alloc_finalizer(sizeof(hl_ssl_cert));
		v->c = chain;
		v->finalize = cert_finalize;
	}
	return v;
}

static vbyte *asn1_buf_to_string(mbedtls_asn1_buf *dat) {
	unsigned int i, c;
	hl_buffer *buf = hl_alloc_buffer();
	for (i = 0; i < dat->len; i++) {
		c = dat->p[i];
		if (c < 32 || c == 127 || (c > 128 && c < 160))
			hl_buffer_char(buf, '?');
		else
			hl_buffer_char(buf, c);
	}
	return (vbyte*)hl_buffer_content(buf,NULL);
}

HL_PRIM vbyte *HL_NAME(cert_get_subject)(hl_ssl_cert *cert, vbyte *objname) {
	mbedtls_x509_name *obj;
	int r;
	const char *oname, *rname;
	obj = &cert->c->subject;
	if (obj == NULL)
		hl_error("Invalid subject");
	rname = (char*)objname;
	while (obj != NULL) {
		r = mbedtls_oid_get_attr_short_name(&obj->oid, &oname);
		if (r == 0 && strcmp(oname, rname) == 0)
			return asn1_buf_to_string(&obj->val);
		obj = obj->next;
	}
	return NULL;
}

HL_PRIM vbyte *HL_NAME(cert_get_issuer)(hl_ssl_cert *cert, vbyte *objname) {
	mbedtls_x509_name *obj;
	int r;
	const char *oname, *rname;
	obj = &cert->c->issuer;
	if (obj == NULL)
		hl_error("Invalid issuer");
	rname = (char*)objname;
	while (obj != NULL) {
		r = mbedtls_oid_get_attr_short_name(&obj->oid, &oname);
		if (r == 0 && strcmp(oname, rname) == 0)
			return asn1_buf_to_string(&obj->val);
		obj = obj->next;
	}
	return NULL;
}

HL_PRIM varray *HL_NAME(cert_get_altnames)(hl_ssl_cert *cert) {
	mbedtls_asn1_sequence *cur;
	int count = 0;
	int pos = 0;
	varray *a = NULL;
	vbyte **current = NULL;
	mbedtls_x509_crt *crt = cert->c;
	if (crt->ext_types & MBEDTLS_X509_EXT_SUBJECT_ALT_NAME) {
		cur = &crt->subject_alt_names;
		while (cur != NULL) {
			if (pos == count) {
				int ncount = count == 0 ? 16 : count * 2;
				varray *narr = hl_alloc_array(&hlt_bytes, ncount);
				vbyte **ncur = hl_aptr(narr, vbyte*);
				memcpy(ncur, current, count * sizeof(void*));
				current = ncur;
				a = narr;
				count = ncount;
			}
			current[pos++] = asn1_buf_to_string(&cur->buf);
			cur = cur->next;
		}
	}
	if (a == NULL) a = hl_alloc_array(&hlt_bytes, 0);
	a->size = pos;
	return a;
}

static varray *x509_time_to_array(mbedtls_x509_time *t) {
	varray *a = NULL;
	int *p;
	if (!t)
		hl_error("Invalid x509 time");
	a = hl_alloc_array(&hlt_i32, 6);
	p = hl_aptr(a, int);
	p[0] = t->year;
	p[1] = t->mon;
	p[2] = t->day;
	p[3] = t->hour;
	p[4] = t->min;
	p[5] = t->sec;
	return a;
}

HL_PRIM varray *HL_NAME(cert_get_notbefore)(hl_ssl_cert *cert) {
	return x509_time_to_array(&cert->c->valid_from);
}

HL_PRIM varray *HL_NAME(cert_get_notafter)(hl_ssl_cert *cert) {
	return x509_time_to_array(&cert->c->valid_to);
}

HL_PRIM hl_ssl_cert *HL_NAME(cert_get_next)(hl_ssl_cert *cert) {
	hl_ssl_cert *ncert;
	if (cert->c->next == NULL)
		return NULL;
	ncert = (hl_ssl_cert*)hl_gc_alloc_noptr(sizeof(hl_ssl_cert));
	ncert->c = cert->c->next;
	return ncert;
}

HL_PRIM hl_ssl_cert *HL_NAME(cert_add_pem)(hl_ssl_cert *cert, vbyte *data) {
	mbedtls_x509_crt *crt;
	int r, len;
	unsigned char *buf;
	if (cert != NULL)
		crt = cert->c;
	else{
		crt = (mbedtls_x509_crt*)malloc(sizeof(mbedtls_x509_crt));
		mbedtls_x509_crt_init(crt);
	}
	len = (int)strlen((char*)data) + 1;
	buf = (unsigned char *)malloc(len);
	memcpy(buf, (char*)data, len - 1);
	buf[len - 1] = '\0';
	r = mbedtls_x509_crt_parse(crt, buf, len);
	free(buf);
	if (r < 0) {
		if (cert == NULL) {
			mbedtls_x509_crt_free(crt);
			free(crt);
		}
		ssl_error(r);
		return NULL;
	}
	if (cert == NULL) {
		cert = (hl_ssl_cert*)hl_gc_alloc_finalizer(sizeof(hl_ssl_cert));
		cert->c = crt;
		cert->finalize = cert_finalize;
	}
	return cert;
}

HL_PRIM hl_ssl_cert *HL_NAME(cert_add_der)(hl_ssl_cert *cert, vbyte *data, int len) {
	mbedtls_x509_crt *crt;
	int r;
	if (cert != NULL)
		crt = cert->c;
	else {
		crt = (mbedtls_x509_crt*)malloc(sizeof(mbedtls_x509_crt));
		mbedtls_x509_crt_init(crt);
	}
	if ((r = mbedtls_x509_crt_parse_der(crt, (const unsigned char*)data, len)) < 0) {
		if (cert == NULL) {
			mbedtls_x509_crt_free(crt);
			free(crt);
		}
		ssl_error(r);
		return NULL;
	}
	if (cert == NULL) {
		cert = (hl_ssl_cert*)hl_gc_alloc_finalizer(sizeof(hl_ssl_cert));
		cert->c = crt;
		cert->finalize = cert_finalize;
	}
	return cert;
}


DEFINE_PRIM(TCERT, cert_load_defaults, _NO_ARG);
DEFINE_PRIM(TCERT, cert_load_file, _BYTES);
DEFINE_PRIM(TCERT, cert_load_path, _BYTES);
DEFINE_PRIM(_BYTES, cert_get_subject, TCERT _BYTES);
DEFINE_PRIM(_BYTES, cert_get_issuer, TCERT _BYTES);
DEFINE_PRIM(_ARR, cert_get_altnames, TCERT);
DEFINE_PRIM(_ARR, cert_get_notbefore, TCERT);
DEFINE_PRIM(_ARR, cert_get_notafter, TCERT);
DEFINE_PRIM(TCERT, cert_get_next, TCERT);
DEFINE_PRIM(TCERT, cert_add_pem, TCERT _BYTES);
DEFINE_PRIM(TCERT, cert_add_der, TCERT _BYTES _I32);


HL_PRIM hl_ssl_pkey *HL_NAME(key_from_der)(vbyte *data, int len, bool pub) {
	int r;
	hl_ssl_pkey *key;
	mbedtls_pk_context *pk = (mbedtls_pk_context *)malloc(sizeof(mbedtls_pk_context));
	mbedtls_pk_init(pk);
	if (pub)
		r = mbedtls_pk_parse_public_key(pk, (const unsigned char*)data, len);
	else
		r = mbedtls_pk_parse_key(pk, (const unsigned char*)data, len, NULL, 0);
	if (r != 0) {
		mbedtls_pk_free(pk);
		free(pk);
		ssl_error(r);
		return NULL;
	}
	key = (hl_ssl_pkey*)hl_gc_alloc_finalizer(sizeof(hl_ssl_pkey));
	key->k = pk;
	key->finalize = pkey_finalize;
	return key;
}

HL_PRIM hl_ssl_pkey *HL_NAME(key_from_pem)(vbyte *data, bool pub, vbyte *pass) {
	int r, len;
	hl_ssl_pkey *key;
	unsigned char *buf;
	mbedtls_pk_context *pk = (mbedtls_pk_context *)malloc(sizeof(mbedtls_pk_context));
	mbedtls_pk_init(pk);
	len = (int)strlen((char*)data) + 1;
	buf = (unsigned char *)malloc(len);
	memcpy(buf, (char*)data, len - 1);
	buf[len - 1] = '\0';
	if (pub)
		r = mbedtls_pk_parse_public_key(pk, buf, len);
	else if (pass == NULL)
		r = mbedtls_pk_parse_key(pk, buf, len, NULL, 0);
	else
		r = mbedtls_pk_parse_key(pk, buf, len, (const unsigned char*)pass, strlen((char*)pass));
	free(buf);
	if (r != 0) {
		mbedtls_pk_free(pk);
		free(pk);
		ssl_error(r);
		return NULL;
	}
	key = (hl_ssl_pkey*)hl_gc_alloc_finalizer(sizeof(hl_ssl_pkey));
	key->k = pk;
	key->finalize = pkey_finalize;
	return key;
}

DEFINE_PRIM(TPKEY, key_from_der, _BYTES _I32 _BOOL);
DEFINE_PRIM(TPKEY, key_from_pem, _BYTES _BOOL _BYTES);

HL_PRIM vbyte *HL_NAME(dgst_make)(vbyte *data, int len, vbyte *alg, int *size) {
	const mbedtls_md_info_t *md;
	int mdlen, r = -1;
	vbyte *out;

	md = mbedtls_md_info_from_string((char*)alg);
	if (md == NULL) {
		hl_error("Invalid hash algorithm");
		return NULL;
	}

	mdlen = mbedtls_md_get_size(md);
	*size = mdlen;
	out = hl_gc_alloc_noptr(mdlen);
	if ((r = mbedtls_md(md, (const unsigned char *)data, len, out)) != 0){
		ssl_error(r);
		return NULL;
	}
	return out;
}

HL_PRIM vbyte *HL_NAME(dgst_sign)(vbyte *data, int len, hl_ssl_pkey *key, vbyte *alg, int *size) {
	const mbedtls_md_info_t *md;
	int r = -1;
	vbyte *out;
	unsigned char hash[MBEDTLS_MD_MAX_SIZE];
	size_t ssize = size ? *size : 0;

	md = mbedtls_md_info_from_string((char*)alg);
	if (md == NULL) {
		hl_error("Invalid hash algorithm");
		return NULL;
	}

	if ((r = mbedtls_md(md, (unsigned char *)data, len, hash)) != 0){
		ssl_error(r);
		return NULL;
	}

	out = hl_gc_alloc_noptr(MBEDTLS_MPI_MAX_SIZE);
	if ((r = mbedtls_pk_sign(key->k, mbedtls_md_get_type(md), hash, 0, out, (size ? &ssize : NULL), mbedtls_ctr_drbg_random, &ctr_drbg)) != 0){
		ssl_error(r);
		return NULL;
	}
	if( size ) *size = (int)ssize;
	return out;
}

HL_PRIM bool HL_NAME(dgst_verify)(vbyte *data, int dlen, vbyte *sign, int slen, hl_ssl_pkey *key, vbyte *alg) {
	const mbedtls_md_info_t *md;
	int r = -1;
	unsigned char hash[MBEDTLS_MD_MAX_SIZE];
	
	md = mbedtls_md_info_from_string((char*)alg);
	if (md == NULL) {
		hl_error("Invalid hash algorithm");
		return false;
	}

	if ((r = mbedtls_md(md, (const unsigned char *)data, dlen, hash)) != 0)
		return ssl_error(r);

	if ((r = mbedtls_pk_verify(key->k, mbedtls_md_get_type(md), hash, 0, (unsigned char *)sign, slen)) != 0)
		return false;

	return true;
}

DEFINE_PRIM(_BYTES, dgst_make, _BYTES _I32 _BYTES _REF(_I32));
DEFINE_PRIM(_BYTES, dgst_sign, _BYTES _I32 TPKEY _BYTES _REF(_I32));
DEFINE_PRIM(_BOOL, dgst_verify, _BYTES _I32 _BYTES _I32 TPKEY _BYTES);


#if _MSC_VER

static void threading_mutex_init_alt(mbedtls_threading_mutex_t *mutex) {
	if (mutex == NULL)
		return;
	InitializeCriticalSection(&mutex->cs);
	mutex->is_valid = 1;
}

static void threading_mutex_free_alt(mbedtls_threading_mutex_t *mutex) {
	if (mutex == NULL || !mutex->is_valid)
		return;
	DeleteCriticalSection(&mutex->cs);
	mutex->is_valid = 0;
}

static int threading_mutex_lock_alt(mbedtls_threading_mutex_t *mutex) {
	if (mutex == NULL || !mutex->is_valid)
		return(MBEDTLS_ERR_THREADING_BAD_INPUT_DATA);

	EnterCriticalSection(&mutex->cs);
	return(0);
}

static int threading_mutex_unlock_alt(mbedtls_threading_mutex_t *mutex) {
	if (mutex == NULL || !mutex->is_valid)
		return(MBEDTLS_ERR_THREADING_BAD_INPUT_DATA);

	LeaveCriticalSection(&mutex->cs);
	return(0);
}

#endif

HL_PRIM void HL_NAME(ssl_init)() {
	if (ssl_init_done)
		return;
	ssl_init_done = true;
#if _MSC_VER
	mbedtls_threading_set_alt(threading_mutex_init_alt, threading_mutex_free_alt,
		threading_mutex_lock_alt, threading_mutex_unlock_alt);
#endif

	// Init RNG
	mbedtls_entropy_init(&entropy);
	mbedtls_ctr_drbg_init(&ctr_drbg);
	mbedtls_ctr_drbg_seed(&ctr_drbg, mbedtls_entropy_func, &entropy, NULL, 0);
}

DEFINE_PRIM(_VOID, ssl_init, _NO_ARG);
