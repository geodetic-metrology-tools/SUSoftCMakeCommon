set(NSI_FILE "${CMAKE_CURRENT_BINARY_DIR}../project.nsi")
set(NSI_FILE_PATCHED "${CMAKE_CURRENT_BINARY_DIR}../project_patched.nsi")

file(GLOB NSI_FILE_DIR "${CMAKE_CURRENT_BINARY_DIR}../")

message(STATUS "*\n*\n*\nListing dir contents")
foreach(item IN LISTS NSI_FILE_DIR)
    message(STATUS " - ${item}")
endforeach()

file(READ "${NSI_FILE}" NSI_FILE_CONTENT)

set(UNPATCHED_SCRIPT_SECTION_STRING
	"Section \"Scripts\" scripts"
	"	SectionIn 1"
	"	SetOutPath \"$INSTDIR\""
	"	File /r \"$INSTDIR\\scripts\\*.*\""
	"SectionEnd"
)

set(PATCHED_SCRIPT_SECTION_STRING
	"Section \"Scripts\" scripts"
	"	SectionIn 1"
	"	SetOutPath \"$INSTDIR\\scripts\\\""
	"	File /r \"D:\\gitlab-ci\\framework\\scripts\\*.*\""
	"SectionEnd"
)

string(REPLACE UNPATCHED_SCRIPT_SECTION_STRING PATCHED_SCRIPT_SECTION_STRING NSI_FILE_CONTENT "${NSI_FILE_CONTENT}")

file(WRITE "${NSI_FILE_PATCHED}" "${NSI_FILE_CONTENT}")
