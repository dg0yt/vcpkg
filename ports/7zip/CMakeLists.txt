cmake_minimum_required(VERSION 3.19)

project(7zip LANGUAGES C CXX)

option(BUILD_TOOL "Build the 7z tool" OFF)
set(ASM_TARGET "OFF" CACHE STRING "vcpkg target architecture for assembler")

set(MASM_x86 0)  # 
set(MASM_x64 0)  # aka IS_X64
set(ASM_arm64 0) # aka IS_ARM64
if(WIN32 AND NOT MINGW AND (ASM_TARGET STREQUAL "x86" OR ASM_TARGET STREQUAL "x64"))
    enable_language(ASM_MASM)
    set(MASM_x86 1)
    if(ASM_TARGET STREQUAL "x64")
        set(MASM_x64 1)
    endif()
elseif(LINUX AND ASM_TARGET STREQUAL "arm64")
    enable_language(ASM)
    set(ASM_arm64 1)
endif()

set_source_files_properties(
    Asm/x86/7zCrcOpt.asm
    Asm/x86/AesOpt.asm
    Asm/x86/Sha1Opt.asm
    Asm/x86/Sha256Opt.asm
    Asm/x86/XzCrc64Opt.asm
    Asm/x86/LzFindOpt.asm
    Asm/x86/LzmaDecOpt.asm
    PROPERTIES LANGUAGE "ASM_MASM"
)

# Propagated to all binary artifacts
add_library(7zip_common_definitions INTERFACE)
target_compile_definitions(7zip_common_definitions
    INTERFACE
        -D_REENTRANT
        -D_FILE_OFFSET_BITS=64
        -D_LARGEFILE_SOURCE
        -DEXTERNAL_CODECS
        -D_7ZIP_LARGE_PAGES
        -DUNICODE
        -D_UNICODE
        $<$<OR:${MASM_x86},${ASM_arm64}>:_LZMA_DEC_OPT>
        #$<$<BOOL:${MINGW}>:_7ZIP_LARGE_PAGES>
        #$<$<BOOL:${MINGW}>:WIN_LONG_PATH>
        #$<$<BOOL:${MINGW}>:SUPPORT_DEVICE_FILE>
)

# CPP/7zip/Bundles/Format7zF/Arc_gcc.mak
add_library(7zip_common OBJECT)
target_sources(7zip_common PRIVATE
    # ASM_OBJS (CPP/7zip/LzmaDec_gcc.make)
    $<IF:${MASM_x86},Asm/x86/LzmaDecOpt.asm,>
    $<IF:${ASM_arm64},Asm/arm64/LzmaDecOpt.S,>

    # C_OBJS
    C/7zBuf2.c
    C/7zStream.c
    C/Alloc.c
    C/Bcj2.c
    C/Bcj2Enc.c
    C/Blake2s.c
    C/Bra.c
    C/Bra86.c
    C/BraIA64.c
    C/BwtSort.c
    C/CpuArch.c
    C/Delta.c
    C/HuffEnc.c
    C/LzFind.c
    C/Lzma2Dec.c
    C/Lzma2DecMt.c
    C/Lzma2Enc.c
    C/LzmaDec.c
    C/LzmaEnc.c
    C/LzmaLib.c
    C/MtCoder.c
    C/MtDec.c
    C/Ppmd7.c
    C/Ppmd7aDec.c
    C/Ppmd7Dec.c
    C/Ppmd7Enc.c
    C/Ppmd8.c
    C/Ppmd8Dec.c
    C/Ppmd8Enc.c
    C/Sort.c
    C/Xz.c
    C/XzDec.c
    C/XzEnc.c
    C/XzIn.c
    C/XzCrc64.c
    $<IF:${MASM_x86},Asm/x86/XzCrc64Opt.asm,C/XzCrc64Opt.c>
    C/7zCrc.c
    $<IF:${MASM_x86},Asm/x86/7zCrcOpt.asm,C/7zCrcOpt.c>
    C/Aes.c
    $<IF:${MASM_x86},Asm/x86/AesOpt.asm,C/AesOpt.c>
    C/Sha1.c
    $<IF:${MASM_x86},Asm/x86/Sha1Opt.asm,C/Sha1Opt.c>
    C/Sha256.c
    $<IF:${MASM_x86},Asm/x86/Sha256Opt.asm,C/Sha256Opt.c>

    # MT_OBJS
    #[[vvv ST_MODE i.e. single-threaded]]
      # mingw: Threads.o, -D_7ZIP_ST
    #[[^^^ ST_MODE / !ST_MODE vvv i.e. multi-threaded]]
    C/LzFindMt.c
    $<IF:${MASM_x64},Asm/x86/LzFindOpt.asm,C/LzFindOpt.c>
    CPP/7zip/Common/StreamBinder.cpp
    CPP/Windows/Synchronization.cpp # Windows?
    CPP/7zip/Common/VirtThread.cpp
    CPP/7zip/Common/MemBlocks.cpp
    CPP/7zip/Common/OutMemStream.cpp
    CPP/7zip/Common/ProgressMt.cpp
    C/Threads.c
    #[[!ST_MODE ^^^]]

    # COMMON_OBJS
    CPP/Common/CRC.cpp
    CPP/Common/CrcReg.cpp
    CPP/Common/DynLimBuf.cpp
    CPP/Common/IntToString.cpp
    CPP/Common/LzFindPrepare.cpp
    CPP/Common/MyMap.cpp
    CPP/Common/MyString.cpp
    CPP/Common/MyVector.cpp
    #CPP/Common/MyWindows.cpp
    CPP/Common/MyXml.cpp
    CPP/Common/NewHandler.cpp
    CPP/Common/Sha1Prepare.cpp
    CPP/Common/Sha1Reg.cpp
    CPP/Common/Sha256Prepare.cpp
    CPP/Common/Sha256Reg.cpp
    CPP/Common/StringConvert.cpp
    CPP/Common/StringToInt.cpp
    CPP/Common/UTFConvert.cpp
    CPP/Common/Wildcard.cpp
    CPP/Common/XzCrc64Init.cpp
    CPP/Common/XzCrc64Reg.cpp

    # WIN_OBJS
    CPP/Windows/FileDir.cpp
    CPP/Windows/FileFind.cpp
    CPP/Windows/FileIO.cpp
    CPP/Windows/FileName.cpp
    CPP/Windows/PropVariant.cpp
    CPP/Windows/PropVariantConv.cpp # NEW
    CPP/Windows/PropVariantUtils.cpp
    CPP/Windows/System.cpp
    CPP/Windows/TimeUtils.cpp

    # AR_OBJS
    CPP/7zip/Archive/ApfsHandler.cpp # NEW
    CPP/7zip/Archive/ApmHandler.cpp
    CPP/7zip/Archive/ArHandler.cpp
    CPP/7zip/Archive/ArjHandler.cpp
    CPP/7zip/Archive/Base64Handler.cpp
    CPP/7zip/Archive/Bz2Handler.cpp
    CPP/7zip/Archive/ComHandler.cpp
    CPP/7zip/Archive/CpioHandler.cpp
    CPP/7zip/Archive/CramfsHandler.cpp
    CPP/7zip/Archive/DeflateProps.cpp
    CPP/7zip/Archive/DmgHandler.cpp
    CPP/7zip/Archive/ElfHandler.cpp
    CPP/7zip/Archive/ExtHandler.cpp
    CPP/7zip/Archive/FatHandler.cpp
    CPP/7zip/Archive/FlvHandler.cpp
    CPP/7zip/Archive/GzHandler.cpp
    CPP/7zip/Archive/GptHandler.cpp
    CPP/7zip/Archive/HandlerCont.cpp
    CPP/7zip/Archive/HfsHandler.cpp
    CPP/7zip/Archive/IhexHandler.cpp
    CPP/7zip/Archive/LzhHandler.cpp
    CPP/7zip/Archive/LzmaHandler.cpp
    CPP/7zip/Archive/MachoHandler.cpp
    CPP/7zip/Archive/MbrHandler.cpp
    CPP/7zip/Archive/MslzHandler.cpp
    CPP/7zip/Archive/MubHandler.cpp
    CPP/7zip/Archive/NtfsHandler.cpp
    CPP/7zip/Archive/PeHandler.cpp
    CPP/7zip/Archive/PpmdHandler.cpp
    CPP/7zip/Archive/QcowHandler.cpp
    CPP/7zip/Archive/RpmHandler.cpp
    CPP/7zip/Archive/SparseHandler.cpp # NEW
    CPP/7zip/Archive/SplitHandler.cpp
    CPP/7zip/Archive/SquashfsHandler.cpp
    CPP/7zip/Archive/SwfHandler.cpp
    CPP/7zip/Archive/UefiHandler.cpp
    CPP/7zip/Archive/VdiHandler.cpp
    CPP/7zip/Archive/VhdHandler.cpp
    CPP/7zip/Archive/VhdxHandler.cpp # NEW
    CPP/7zip/Archive/VmdkHandler.cpp
    CPP/7zip/Archive/XarHandler.cpp
    CPP/7zip/Archive/XzHandler.cpp
    CPP/7zip/Archive/ZHandler.cpp

    # AR_COMMON_OBJS
    CPP/7zip/Archive/Common/CoderMixer2.cpp
    CPP/7zip/Archive/Common/DummyOutStream.cpp
    CPP/7zip/Archive/Common/FindSignature.cpp
    CPP/7zip/Archive/Common/InStreamWithCRC.cpp
    CPP/7zip/Archive/Common/ItemNameUtils.cpp
    CPP/7zip/Archive/Common/MultiStream.cpp
    CPP/7zip/Archive/Common/OutStreamWithCRC.cpp
    CPP/7zip/Archive/Common/OutStreamWithSha1.cpp
    CPP/7zip/Archive/Common/HandlerOut.cpp
    CPP/7zip/Archive/Common/ParseProperties.cpp

    # 7Z_OBJS
    CPP/7zip/Archive/7z/7zCompressionMode.cpp
    CPP/7zip/Archive/7z/7zDecode.cpp
    CPP/7zip/Archive/7z/7zEncode.cpp
    CPP/7zip/Archive/7z/7zExtract.cpp
    CPP/7zip/Archive/7z/7zFolderInStream.cpp
    CPP/7zip/Archive/7z/7zHandler.cpp
    CPP/7zip/Archive/7z/7zHandlerOut.cpp
    CPP/7zip/Archive/7z/7zHeader.cpp
    CPP/7zip/Archive/7z/7zIn.cpp
    CPP/7zip/Archive/7z/7zOut.cpp
    CPP/7zip/Archive/7z/7zProperties.cpp
    CPP/7zip/Archive/7z/7zSpecStream.cpp
    CPP/7zip/Archive/7z/7zUpdate.cpp
    CPP/7zip/Archive/7z/7zRegister.cpp

    # CAB_OBJS
    CPP/7zip/Archive/Cab/CabBlockInStream.cpp
    CPP/7zip/Archive/Cab/CabHandler.cpp
    CPP/7zip/Archive/Cab/CabHeader.cpp
    CPP/7zip/Archive/Cab/CabIn.cpp
    CPP/7zip/Archive/Cab/CabRegister.cpp

    # CHM_OBJS
    CPP/7zip/Archive/Chm/ChmHandler.cpp
    CPP/7zip/Archive/Chm/ChmIn.cpp

    # COM_OBJS

    # ISO_OBJS
    CPP/7zip/Archive/Iso/IsoHandler.cpp
    CPP/7zip/Archive/Iso/IsoHeader.cpp
    CPP/7zip/Archive/Iso/IsoIn.cpp
    CPP/7zip/Archive/Iso/IsoRegister.cpp

    # NSIS_OBJS
    CPP/7zip/Archive/Nsis/NsisDecode.cpp
    CPP/7zip/Archive/Nsis/NsisHandler.cpp
    CPP/7zip/Archive/Nsis/NsisIn.cpp
    CPP/7zip/Archive/Nsis/NsisRegister.cpp

    # RAR_OBJS # OPTIONAL (!DISABLE_RAR)
    CPP/7zip/Archive/Rar/RarHandler.cpp
    CPP/7zip/Archive/Rar/Rar5Handler.cpp

    # TAR_OBJS
    CPP/7zip/Archive/Tar/TarHandler.cpp
    CPP/7zip/Archive/Tar/TarHandlerOut.cpp
    CPP/7zip/Archive/Tar/TarHeader.cpp
    CPP/7zip/Archive/Tar/TarIn.cpp
    CPP/7zip/Archive/Tar/TarOut.cpp
    CPP/7zip/Archive/Tar/TarUpdate.cpp
    CPP/7zip/Archive/Tar/TarRegister.cpp

    # UDF_OBJS
    CPP/7zip/Archive/Udf/UdfHandler.cpp
    CPP/7zip/Archive/Udf/UdfIn.cpp

    # WIM_OBJS
    CPP/7zip/Archive/Wim/WimHandler.cpp
    CPP/7zip/Archive/Wim/WimHandlerOut.cpp
    CPP/7zip/Archive/Wim/WimIn.cpp
    CPP/7zip/Archive/Wim/WimRegister.cpp

    # ZIP_OBJS
    CPP/7zip/Archive/Zip/ZipAddCommon.cpp
    CPP/7zip/Archive/Zip/ZipHandler.cpp
    CPP/7zip/Archive/Zip/ZipHandlerOut.cpp
    CPP/7zip/Archive/Zip/ZipIn.cpp
    CPP/7zip/Archive/Zip/ZipItem.cpp
    CPP/7zip/Archive/Zip/ZipOut.cpp
    CPP/7zip/Archive/Zip/ZipUpdate.cpp
    CPP/7zip/Archive/Zip/ZipRegister.cpp

    # COMPRESS_OBJS
    CPP/7zip/Compress/Bcj2Coder.cpp
    CPP/7zip/Compress/Bcj2Register.cpp
    CPP/7zip/Compress/BcjCoder.cpp
    CPP/7zip/Compress/BcjRegister.cpp
    CPP/7zip/Compress/BitlDecoder.cpp
    CPP/7zip/Compress/BranchMisc.cpp
    CPP/7zip/Compress/BranchRegister.cpp
    CPP/7zip/Compress/ByteSwap.cpp
    CPP/7zip/Compress/BZip2Crc.cpp
    CPP/7zip/Compress/BZip2Decoder.cpp
    CPP/7zip/Compress/BZip2Encoder.cpp
    CPP/7zip/Compress/BZip2Register.cpp
    CPP/7zip/Compress/CopyCoder.cpp
    CPP/7zip/Compress/CopyRegister.cpp
    CPP/7zip/Compress/Deflate64Register.cpp
    CPP/7zip/Compress/DeflateDecoder.cpp
    CPP/7zip/Compress/DeflateEncoder.cpp
    CPP/7zip/Compress/DeflateRegister.cpp
    CPP/7zip/Compress/DeltaFilter.cpp
    CPP/7zip/Compress/ImplodeDecoder.cpp
    CPP/7zip/Compress/LzfseDecoder.cpp
    CPP/7zip/Compress/LzhDecoder.cpp
    CPP/7zip/Compress/Lzma2Decoder.cpp
    CPP/7zip/Compress/Lzma2Encoder.cpp
    CPP/7zip/Compress/Lzma2Register.cpp
    CPP/7zip/Compress/LzmaDecoder.cpp
    CPP/7zip/Compress/LzmaEncoder.cpp
    CPP/7zip/Compress/LzmaRegister.cpp
    CPP/7zip/Compress/LzmsDecoder.cpp
    CPP/7zip/Compress/LzOutWindow.cpp
    CPP/7zip/Compress/LzxDecoder.cpp
    CPP/7zip/Compress/PpmdDecoder.cpp
    CPP/7zip/Compress/PpmdEncoder.cpp
    CPP/7zip/Compress/PpmdRegister.cpp
    CPP/7zip/Compress/PpmdZip.cpp
    CPP/7zip/Compress/QuantumDecoder.cpp
    # !DISABLE_RAR
    CPP/7zip/Compress/Rar1Decoder.cpp
    CPP/7zip/Compress/Rar2Decoder.cpp
    CPP/7zip/Compress/Rar3Decoder.cpp
    CPP/7zip/Compress/Rar3Vm.cpp
    CPP/7zip/Compress/Rar5Decoder.cpp
    CPP/7zip/Compress/RarCodecsRegister.cpp
    # ^ !DISABLE_RAR
    CPP/7zip/Compress/ShrinkDecoder.cpp
    CPP/7zip/Compress/XpressDecoder.cpp
    CPP/7zip/Compress/XzDecoder.cpp
    CPP/7zip/Compress/XzEncoder.cpp
    CPP/7zip/Compress/ZlibDecoder.cpp
    CPP/7zip/Compress/ZlibEncoder.cpp
    CPP/7zip/Compress/ZDecoder.cpp

    # CRYPTO_OBJS
    CPP/7zip/Crypto/7zAes.cpp
    CPP/7zip/Crypto/7zAesRegister.cpp
    CPP/7zip/Crypto/HmacSha1.cpp
    CPP/7zip/Crypto/HmacSha256.cpp
    CPP/7zip/Crypto/MyAes.cpp
    CPP/7zip/Crypto/MyAesReg.cpp
    CPP/7zip/Crypto/Pbkdf2HmacSha1.cpp
    CPP/7zip/Crypto/RandGen.cpp
    # !DISABLE_RAR
    CPP/7zip/Crypto/Rar20Crypto.cpp
    CPP/7zip/Crypto/Rar5Aes.cpp
    CPP/7zip/Crypto/RarAes.cpp
    # ^ !DISABLE_RAR
    CPP/7zip/Crypto/WzAes.cpp
    CPP/7zip/Crypto/ZipCrypto.cpp
    CPP/7zip/Crypto/ZipStrong.cpp

    # $(7ZIP_COMMON_OBJS)
    CPP/7zip/Common/CreateCoder.cpp
    CPP/7zip/Common/CWrappers.cpp
    CPP/7zip/Common/InBuffer.cpp
    CPP/7zip/Common/InOutTempBuffer.cpp
    CPP/7zip/Common/FilterCoder.cpp
    CPP/7zip/Common/LimitedStreams.cpp
    CPP/7zip/Common/LockedStream.cpp
    CPP/7zip/Common/MethodId.cpp
    CPP/7zip/Common/MethodProps.cpp
    CPP/7zip/Common/OffsetStream.cpp
    CPP/7zip/Common/OutBuffer.cpp
    CPP/7zip/Common/ProgressUtils.cpp
    CPP/7zip/Common/PropId.cpp
    CPP/7zip/Common/StreamObjects.cpp
    CPP/7zip/Common/StreamUtils.cpp
    CPP/7zip/Common/UniqBlocks.cpp
)
target_link_libraries(7zip_common PUBLIC 7zip_common_definitions)

# - CPP/7zip/Bundles/Format7zF/makefile.gcc
add_library(7zip
    # DEF_FILE
    CPP/7zip/Archive/Archive2.def

    # SYS_OBJS
    # mingw: resource.o, -D_7ZIP_LARGE_PAGES
    #[[!mingw]]
    CPP/Common/MyWindows.cpp

    # COMPRESS_OBJS_2
    CPP/7zip/Compress/CodecExports.cpp

    # AR_OBJS_2
    CPP/7zip/Archive/ArchiveExports.cpp
    CPP/7zip/Archive/DllExports2.cpp

    # FIXME
    C/Util/LzmaLib/LzmaLib.def
)
# ARC_OBJS
target_link_libraries(7zip PRIVATE 7zip_common)
target_include_directories(7zip
    INTERFACE
        $<INSTALL_INTERFACE:include>/7zip/CPP
)

install(
    TARGETS 7zip 7zip_common 7zip_common_definitions
    EXPORT 7zip-targets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(
    TARGETS 7zip_common_definitions
    EXPORT 7zip-common
    DESTINATION unused
)

# Headers makes relative includes so directory structure must be kept

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/C/*.h")
install(FILES ${HEADERS} DESTINATION "include/7zip/C")

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/CPP/Common/*.h")
install(FILES ${HEADERS} DESTINATION "include/7zip/CPP/Common")

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/CPP/7zip/*.h")
install(FILES ${HEADERS} DESTINATION "include/7zip/CPP/7zip")

file(GLOB HEADERS "${CMAKE_CURRENT_LIST_DIR}/CPP/7zip/Archive/*.h")
install (FILES ${HEADERS} DESTINATION "include/7zip/CPP/7zip/Archive")

include(CMakePackageConfigHelpers)
configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/7zip-config.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/7zip-config.cmake"
  INSTALL_DESTINATION "share/7zip"
)

install(
    EXPORT 7zip-targets
    DESTINATION share/7zip
    NAMESPACE 7zip::
)

# - CPP/7zip/Bundles/Alone2/makefile.gcc
# - CPP/7zip/Ui/Console/Console.mak
add_executable(7zz)
target_sources(7zz PRIVATE
    # SYS_OBJS
    #mingw
    CPP/Windows/FileSystem.cpp
    CPP/Windows/Registry.cpp
    CPP/Windows/MemoryLock.cpp
    CPP/Windows/DLL.cpp
    C/DllSecur.c # nmake: Console.mak C_OBJS
    CPP/7zip/Bundles/Alone2/resource.rc
    #non-mingw
    CPP/Common/MyWindows.cpp

    # UI_COMMON_OBJS # nmake: Console.mak
    CPP/7zip/UI/Common/ArchiveCommandLine.cpp
    CPP/7zip/UI/Common/ArchiveExtractCallback.cpp
    CPP/7zip/UI/Common/ArchiveOpenCallback.cpp
    CPP/7zip/UI/Common/Bench.cpp
    CPP/7zip/UI/Common/DefaultName.cpp
    CPP/7zip/UI/Common/EnumDirItems.cpp
    CPP/7zip/UI/Common/Extract.cpp
    CPP/7zip/UI/Common/ExtractingFilePath.cpp
    CPP/7zip/UI/Common/HashCalc.cpp
    CPP/7zip/UI/Common/LoadCodecs.cpp
    CPP/7zip/UI/Common/OpenArchive.cpp
    CPP/7zip/UI/Common/PropIDUtils.cpp
    CPP/7zip/UI/Common/SetProperties.cpp
    CPP/7zip/UI/Common/SortUtils.cpp
    CPP/7zip/UI/Common/TempFiles.cpp
    CPP/7zip/UI/Common/Update.cpp
    CPP/7zip/UI/Common/UpdateAction.cpp
    CPP/7zip/UI/Common/UpdateCallback.cpp
    CPP/7zip/UI/Common/UpdatePair.cpp
    CPP/7zip/UI/Common/UpdateProduce.cpp

    # CONSOLE_OBJS # nmake: Console.mak
    CPP/7zip/UI/Console/BenchCon.cpp
    CPP/7zip/UI/Console/ConsoleClose.cpp
    CPP/7zip/UI/Console/ExtractCallbackConsole.cpp
    CPP/7zip/UI/Console/HashCon.cpp
    CPP/7zip/UI/Console/List.cpp
    CPP/7zip/UI/Console/Main.cpp
    CPP/7zip/UI/Console/MainAr.cpp
    CPP/7zip/UI/Console/OpenCallbackConsole.cpp
    CPP/7zip/UI/Console/PercentPrinter.cpp
    CPP/7zip/UI/Console/UpdateCallbackConsole.cpp
    CPP/7zip/UI/Console/UserInputUtils.cpp

    # COMMON_OBJS_2
    CPP/Common/CommandLineParser.cpp
    CPP/Common/ListFileUtils.cpp
    CPP/Common/StdInStream.cpp
    CPP/Common/StdOutStream.cpp

    # WIN_OBJS_2
    # MSVC: DLL
    CPP/Windows/ErrorMsg.cpp
    CPP/Windows/FileLink.cpp
    # MSVC: FileSystem
    # MSVC: MemoryLock
    # MSVC: Registry
    CPP/Windows/SystemInfo.cpp

    # 7ZIP_COMMON_OBJS_2
    CPP/7zip/Common/FilePathAutoRename.cpp
    CPP/7zip/Common/FileStreams.cpp
)
# ARC_OBJS
target_link_libraries(7zz PRIVATE 7zip_common)
target_compile_definitions(7zz
    PRIVATE
        PROG_VARIANT_Z
        _7ZIP_ASM # ?
)
