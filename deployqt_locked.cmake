# Wrapper script to serialize windeployqt calls via file lock.
# Prevents parallel write conflicts when multiple targets deploy to the same directory (Ninja).
#
# Expected -D variables:
#   DEPLOYQT_EXE    — path to windeployqt/macdeployqt
#   CONFIG          — build configuration (Debug, Release, ...)
#   OUTPUT_DIR      — destination directory for deployed files
#   EXECUTABLE      — the binary to scan for dependencies

file(LOCK "${LOCK_DIR}/deployqt.lock" TIMEOUT 30)

string(TOLOWER "${CONFIG}" _config_lower)
if(_config_lower STREQUAL "debug")
	set(_config_flag "--debug")
	set(_pdb_flag "--pdb")
elseif(_config_lower STREQUAL "release")
	set(_config_flag "--release")
	set(_pdb_flag "")
else()
	set(_config_flag "")
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

if(NOT _result EQUAL 0)
	message(WARNING "windeployqt returned exit code ${_result}")
endif()
