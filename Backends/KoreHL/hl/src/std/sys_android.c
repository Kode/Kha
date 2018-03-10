/*
 * Copyright (C)2005-2018 Haxe Foundation
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

#include <hl.h>

#if defined(HL_MOBILE) && defined(HL_ANDROID)

#ifndef HL_ANDROID_ACTIVITY
#	define HL_ANDROID_ACTIVITY "org/haxe/HashLinkActivity"
#endif

#include <jni.h>
#include <android/log.h>
#include <pthread.h>
#include <sys/types.h>
#include <unistd.h>

#ifndef HL_JNI_LOG_TAG
#define HL_JNI_LOG_TAG "HL_JNI"
#endif

#define HL_ANDROID_EXTERNAL_STORAGE_NOT_MOUNTED	(0)
#define HL_ANDROID_EXTERNAL_STORAGE_MOUNTED_RO	(1)
#define HL_ANDROID_EXTERNAL_STORAGE_MOUNTED_RW	(2 | HL_ANDROID_EXTERNAL_STORAGE_MOUNTED_RO)

/* #define LOGI(...)  __android_log_print(ANDROID_LOG_INFO,HL_JNI_LOG_TAG,__VA_ARGS__) */
/* #define LOGE(...)  __android_log_print(ANDROID_LOG_ERROR,HL_JNI_LOG_TAG,__VA_ARGS__) */
#define LOGI(...) do {} while (0)
#define LOGE(...) do {} while (0)

/* Forward declaration for JNI thread management */
static void hl_android_jni_thread_destructor(void*);

/* pthread key for proper JVM thread handling */
static pthread_key_t hl_java_thread_key;

/* Java VM reference */
static JavaVM* hl_java_vm;

/* Main activity */
static jclass hl_java_activity_class;

/* Method signatures */
static jmethodID hl_java_method_id_get_context;

/* Paths */
static char *hl_android_external_files_path = NULL;
static char *hl_android_internal_files_path = NULL;

/* Function to retrieve JNI environment, and dealing with threading */
static JNIEnv* hl_android_jni_get_env(void)
{
	/* Always try to attach if calling from a non-attached thread */
	JNIEnv *env;
	if((*hl_java_vm)->AttachCurrentThread(hl_java_vm, &env, NULL) < 0) {
		LOGE("failed to attach current thread");
		return 0;
	}
	pthread_setspecific(hl_java_thread_key, (void*) env);

	return env;
}

/* JNI_OnLoad is automatically called when loading shared library through System.loadLibrary() Java call */
JNIEXPORT jint JNICALL JNI_OnLoad(JavaVM* vm, void* reserved)
{
	JNIEnv *env;
	jclass cls;

	hl_java_vm = vm;
	if ((*hl_java_vm)->GetEnv(hl_java_vm, (void**) &env, JNI_VERSION_1_4) != JNI_OK) {
		__android_log_print(ANDROID_LOG_ERROR, HL_JNI_LOG_TAG, "Failed to get the environment using GetEnv()");
		return -1;
	}

	/* Create pthread "destructor" pthread key to detach properly all threads */
	if (pthread_key_create(&hl_java_thread_key, hl_android_jni_thread_destructor) != 0) {
		__android_log_print(ANDROID_LOG_ERROR, HL_JNI_LOG_TAG, "Error initializing pthread key");
	}

	/* Make sure we are attached (we should) and setup pthread destructor */
	env = hl_android_jni_get_env();

	/* Try to retrieve local reference to our Activity class */
	cls = (*env)->FindClass(env, HL_ANDROID_ACTIVITY);
	if (!cls) {
		__android_log_print(ANDROID_LOG_ERROR, HL_JNI_LOG_TAG, "Error cannot find HashLink Activity class");
	}

	/* Create a global reference for our Activity class */
	hl_java_activity_class = (jclass)((*env)->NewGlobalRef(env, cls));

	/* Retrieve the getContext() method id */
	hl_java_method_id_get_context = (*env)->GetStaticMethodID(env, hl_java_activity_class, "getContext","()Landroid/content/Context;");
	if (!hl_java_method_id_get_context) {
		__android_log_print(ANDROID_LOG_ERROR, HL_JNI_LOG_TAG, "Error cannot get getContext() method on specified Activity class (not an Activity ?)");
	}
	
	return JNI_VERSION_1_4;
}

static void hl_android_jni_thread_destructor(void* value)
{
	/* The thread is being destroyed, detach it from the Java VM and set the hl_java_thread_key value to NULL as required */
	JNIEnv *env = (JNIEnv*) value;
	if (env != NULL) {
		(*hl_java_vm)->DetachCurrentThread(hl_java_vm);
		pthread_setspecific(hl_java_thread_key, NULL);
	}
}

static int hl_sys_android_get_external_storage_state(void)
{
	jmethodID mid;
	jclass cls;
	jstring stateString;
	const char *state;
	int status = HL_ANDROID_EXTERNAL_STORAGE_NOT_MOUNTED;

	JNIEnv *env = hl_android_jni_get_env();
	if (!env) {
		LOGE("Couldn't get Android JNIEnv !");
		return status;
	}

	cls = (*env)->FindClass(env, "android/os/Environment");
	mid = (*env)->GetStaticMethodID(env, cls, "getExternalStorageState", "()Ljava/lang/String;");
	stateString = (jstring)(*env)->CallStaticObjectMethod(env, cls, mid);
	if (!stateString) {
		LOGE("Call to getExternalStorageState failed");
		return status;
	}

	state = (*env)->GetStringUTFChars(env, stateString, NULL);
	if (strcmp(state, "mounted") == 0) {
		status = HL_ANDROID_EXTERNAL_STORAGE_MOUNTED_RW;
	} else if (strcmp(state, "mounted_ro") == 0) {
		status = HL_ANDROID_EXTERNAL_STORAGE_MOUNTED_RO;
	}
	(*env)->ReleaseStringUTFChars(env, stateString, state);

	return status;
}

static char* hl_sys_android_get_absolute_path_from(const char* method, const char* signature)
{
		jmethodID mid;
		jobject context;
		jobject fileObject;
		jstring pathString;
		const char *path;
		char* retrievedPath = NULL;

		JNIEnv *env = hl_android_jni_get_env();
		if (!env) {
			LOGE("Couldn't get Android JNIEnv !");
			return NULL;
		}

		context = (*env)->CallStaticObjectMethod(env, hl_java_activity_class, hl_java_method_id_get_context);
		if (!context) {
			LOGE("Couldn't get Android context!");
			return NULL;
		}

		mid = (*env)->GetMethodID(env, (*env)->GetObjectClass(env, context), method, signature);
		fileObject = (*env)->CallObjectMethod(env, context, mid, NULL);
		if (!fileObject) {
			LOGE("Couldn't call %s%s on the specified context", method, signature);
			return NULL;
		}

		mid = (*env)->GetMethodID(env, (*env)->GetObjectClass(env, fileObject), "getAbsolutePath", "()Ljava/lang/String;");
		pathString = (jstring)(*env)->CallObjectMethod(env, fileObject, mid);
		if (!pathString) {
			LOGE("Couldn't retrieve absolute path");
			return NULL;
		}

		/* Retrieve as C string */
		path = (*env)->GetStringUTFChars(env, pathString, NULL);
		retrievedPath = strdup(path);
		(*env)->ReleaseStringUTFChars(env, pathString, path);

		return retrievedPath;
}

static const char* hl_sys_android_get_external_storage_path(void)
{
	/* Make sure external storage is mounted (at least read-only) */
	if (hl_sys_android_get_external_storage_state()==HL_ANDROID_EXTERNAL_STORAGE_NOT_MOUNTED)
		return NULL;

	if (!hl_android_external_files_path) {
		hl_android_external_files_path = hl_sys_android_get_absolute_path_from("getExternalFilesDir", "(Ljava/lang/String;)Ljava/io/File;");
	}

	return hl_android_external_files_path;
}

static const char* hl_sys_android_get_internal_storage_path(void)
{
	/* Internal storage is always available */
	if (!hl_android_internal_files_path) {
		hl_android_internal_files_path = hl_sys_android_get_absolute_path_from("getFilesDir", "(Ljava/lang/String;)Ljava/io/File;");
	}

	return hl_android_internal_files_path;
}

const char *hl_sys_special( const char *key ) { 
	if (strcmp(key, "android_external_storage_path")==0)
		return hl_sys_android_get_external_storage_path();
	else if (strcmp(key, "android_internal_storage_path")==0)
		return hl_sys_android_get_internal_storage_path();
	else
		hl_error("Unknown sys_special key");
	return NULL;
}

DEFINE_PRIM(_BYTES, sys_special, _BYTES);

#endif