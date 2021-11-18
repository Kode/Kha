set(MINIMP3_INCLUDE_DIR ${INCLUDES_BASE_DIR}/minimp3)
set(MIKKTSPACE_INCLUDE_DIR ${INCLUDES_BASE_DIR}/mikktspace)

if(WIN32)
    set(ZLIB_INCLUDE_DIRS ${INCLUDES_BASE_DIR}/zlib)
    set(PNG_INCLUDE_DIRS ${INCLUDES_BASE_DIR}/png)
    set(VORBIS_INCLUDE_DIR ${INCLUDES_BASE_DIR}/vorbis)

    if(CMAKE_SIZEOF_VOID_P EQUAL 8)
        set(TurboJPEG_INCLUDE_DIRS ${INCLUDES_BASE_DIR}/turbojpeg ${INCLUDES_BASE_DIR}/turbojpeg/x64)
        find_library(TurboJPEG_LIBRARIES simd PATHS ${INCLUDES_BASE_DIR}/turbojpeg/x64)
    else()
        set(TurboJPEG_INCLUDE_DIRS ${INCLUDES_BASE_DIR}/turbojpeg ${INCLUDES_BASE_DIR}/turbojpeg/x86)
        find_library(TurboJPEG_LIBRARIES simd PATHS ${INCLUDES_BASE_DIR}/turbojpeg/x86)
    endif()

    add_library(fmt.hdll SHARED
        ${INCLUDES_BASE_DIR}/png/png.c
        ${INCLUDES_BASE_DIR}/png/pngerror.c
        ${INCLUDES_BASE_DIR}/png/pngget.c
        ${INCLUDES_BASE_DIR}/png/pngmem.c
        ${INCLUDES_BASE_DIR}/png/pngpread.c
        ${INCLUDES_BASE_DIR}/png/pngread.c
        ${INCLUDES_BASE_DIR}/png/pngrio.c
        ${INCLUDES_BASE_DIR}/png/pngrtran.c
        ${INCLUDES_BASE_DIR}/png/pngrutil.c
        ${INCLUDES_BASE_DIR}/png/pngset.c
        ${INCLUDES_BASE_DIR}/png/pngtrans.c
        ${INCLUDES_BASE_DIR}/png/pngwio.c
        ${INCLUDES_BASE_DIR}/png/pngwrite.c
        ${INCLUDES_BASE_DIR}/png/pngwtran.c
        ${INCLUDES_BASE_DIR}/png/pngwutil.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jaricom.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcapimin.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcapistd.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcarith.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jccoefct.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jccolor.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcdctmgr.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jchuff.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcinit.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcmainct.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcmarker.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcmaster.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcomapi.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcparam.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcphuff.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcprepct.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jcsample.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jctrans.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdapimin.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdapistd.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdarith.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdatadst-tj.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdatadst.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdatasrc-tj.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdatasrc.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdcoefct.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdcolor.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jddctmgr.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdhuff.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdinput.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdmainct.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdmarker.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdmaster.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdmerge.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdphuff.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdpostct.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdsample.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jdtrans.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jerror.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jfdctflt.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jfdctfst.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jfdctint.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jidctflt.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jidctfst.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jidctint.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jidctred.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jmemmgr.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jmemnobs.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jquant1.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jquant2.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jsimd.c
        ${INCLUDES_BASE_DIR}/turbojpeg/jutils.c
        ${INCLUDES_BASE_DIR}/turbojpeg/transupp.c
        ${INCLUDES_BASE_DIR}/turbojpeg/turbojpeg.c
        ${INCLUDES_BASE_DIR}/zlib/adler32.c
        ${INCLUDES_BASE_DIR}/zlib/crc32.c
        ${INCLUDES_BASE_DIR}/zlib/deflate.c
        ${INCLUDES_BASE_DIR}/zlib/inffast.c
        ${INCLUDES_BASE_DIR}/zlib/inflate.c
        ${INCLUDES_BASE_DIR}/zlib/inftrees.c
        ${INCLUDES_BASE_DIR}/zlib/trees.c
        ${INCLUDES_BASE_DIR}/zlib/zutil.c
        ${INCLUDES_BASE_DIR}/vorbis/bitrate.c
        ${INCLUDES_BASE_DIR}/vorbis/bitwise.c
        ${INCLUDES_BASE_DIR}/vorbis/block.c
        ${INCLUDES_BASE_DIR}/vorbis/codebook.c
        ${INCLUDES_BASE_DIR}/vorbis/envelope.c
        ${INCLUDES_BASE_DIR}/vorbis/floor0.c
        ${INCLUDES_BASE_DIR}/vorbis/floor1.c
        ${INCLUDES_BASE_DIR}/vorbis/framing.c
        ${INCLUDES_BASE_DIR}/vorbis/info.c
        ${INCLUDES_BASE_DIR}/vorbis/lookup.c
        ${INCLUDES_BASE_DIR}/vorbis/lpc.c
        ${INCLUDES_BASE_DIR}/vorbis/lsp.c
        ${INCLUDES_BASE_DIR}/vorbis/mapping0.c
        ${INCLUDES_BASE_DIR}/vorbis/mdct.c
        ${INCLUDES_BASE_DIR}/vorbis/psy.c
        ${INCLUDES_BASE_DIR}/vorbis/registry.c
        ${INCLUDES_BASE_DIR}/vorbis/res0.c
        ${INCLUDES_BASE_DIR}/vorbis/sharedbook.c
        ${INCLUDES_BASE_DIR}/vorbis/smallft.c
        ${INCLUDES_BASE_DIR}/vorbis/synthesis.c
        ${INCLUDES_BASE_DIR}/vorbis/vorbisfile.c
        ${INCLUDES_BASE_DIR}/vorbis/window.c
        fmt.c
        sha1.c
        dxt.c
        mikkt.c
        ${MIKKTSPACE_INCLUDE_DIR}/mikktspace.c
    )
else()
    find_package(ZLIB REQUIRED)
    find_package(PNG REQUIRED)

    find_package(TurboJPEG QUIET)
    if(NOT TurboJPEG_FOUND)
        pkg_check_modules(TurboJPEG REQUIRED libjpeg)
    endif()

    find_package(OggVorbis QUIET)
    if(NOT OGGVORBIS_FOUND)
        pkg_check_modules(OGGVORBIS REQUIRED vorbis vorbisenc vorbisfile)
    endif()

    add_library(fmt.hdll SHARED
        fmt.c
        sha1.c
        dxt.c
        mikkt.c
        ${MIKKTSPACE_INCLUDE_DIR}/mikktspace.c
    )
endif()

set_as_hdll(fmt)

target_include_directories(fmt.hdll
    PRIVATE
    ${ZLIB_INCLUDE_DIRS}
    ${PNG_INCLUDE_DIRS}
    ${TurboJPEG_INCLUDE_DIRS}
    ${VORBIS_INCLUDE_DIR}
    ${MINIMP3_INCLUDE_DIR}
    ${MIKKTSPACE_INCLUDE_DIR}
)

target_link_libraries(fmt.hdll
    libhl
    ${ZLIB_LIBRARIES}
    ${PNG_LIBRARIES}
    ${TurboJPEG_LIBRARIES}
    ${OGGVORBIS_LIBRARIES}
)

target_compile_definitions(fmt.hdll
    PRIVATE
    ${PNG_DEFINITIONS}
)

install(
    TARGETS
        fmt.hdll
    DESTINATION ${HDLL_DESTINATION}
)
