# Wrapper script to serialize windeployqt calls via file lock.
# Prevents parallel write conflicts when multiple targets deploy to the same directory (Ninja).
#
# Expected -D variables:
#   DEPLOYQT_EXE    — path to windeployqt/macdeployqt
#   CONFIG          — build configuration (Debug, Release, ...)
#   OUTPUT_DIR      — destination directory for deployed files
#   EXECUTABLE      — the binary to scan for dependencies
#   LOCK_DIR        — directory holding the lock file that serializes the calls

# Callers pass EXECUTABLE through a generator expression that may legitimately
# expand to nothing: the QScintilla DLL is only defined for Debug and Release,
# so it is empty under RelWithDebInfo. Nothing to deploy is not a failure, but
# the skip is reported so it stays visible. Checked before taking the lock.
if("${EXECUTABLE}" STREQUAL "")
	message(STATUS "deployqt: nothing to deploy for config ${CONFIG} - skipped")
	return()
endif()

if(NOT EXISTS "${EXECUTABLE}")
	message(FATAL_ERROR "deployqt: binary to deploy does not exist: ${EXECUTABLE}")
endif()

file(LOCK "${LOCK_DIR}/deployqt.lock" TIMEOUT 30)

# RelWithDebInfo and MinSizeRel link the release runtime, so they deploy the
# release Qt libraries. Only Debug differs.
string(TOLOWER "${CONFIG}" _config_lower)
if(_config_lower STREQUAL "debug")
	set(_config_flag "--debug")
	set(_pdb_flag "--pdb")
else()
	set(_config_flag "--release")
	set(_pdb_flag "")
endif()

execute_process(
	COMMAND "${DEPLOYQT_EXE}"
		${_config_flag}
		${_pdb_flag}
		--verbose 0
		--no-compiler-runtime
		--dir "${OUTPUT_DIR}"
		"${EXECUTABLE}"
	RESULT_VARIABLE _result
)

# _result holds an exit code, or an error string if the tool could not be
# launched; EQUAL 0 catches both. FATAL_ERROR ends the process, which releases
# the lock, so a failure here cannot deadlock a parallel deploy.
if(NOT _result EQUAL 0)
	message(FATAL_ERROR "deployqt: ${DEPLOYQT_EXE} failed (${_result}) on ${EXECUTABLE}")
endif()
