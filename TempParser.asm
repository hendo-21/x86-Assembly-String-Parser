TITLE Intern Error-Corrector     (Proj6_henderia.asm)

; Author: Ian Henderson
; Last Modified: 12/08/24
; OSU email address: henderia@oregonstate.edu
; Course number/section: 400  CS271 Section 400
; Project Number: 6                Due Date: 12/08/24
; Description: This program corrects some troublesome data collection by lab interns. Said interns have collected temperature readings, but recoreded them in reverse order.
;		This program will open the file, read it, convert the temperatures from their ASCII format to integers, and finally will print them in their correct order (reversing the order the intern entered).
;		It will also handle multi-line files with certain parameters. The file must be formatted such that each line contains the same number of temps. Constants must be adjusted to configure the program
;			according to the input file as well, where number of temps is accounted for, as well as number of lines in the file.
;		An error message will print and the program will end if the entered file name cannot be opened.
;		The temperatures in the input file will each be separated by a delimiting character, which is configurable as a constant. The range of temps in the input file should also be -100 to 200.

INCLUDE Irvine32.inc

;-----------
;  MACROS 
;-----------
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Name: mGetString
;
;	Prompts the user to enter a string that is the file name for the file to be read, and store.  
;
; Preconditions: MAX_FILENAME_SIZE must be large enough for input file name
;
; Postconditions: None. All used registeres are restored
;
; Receives:
;		strOffset		= reference, string to print
;		strDestOffset	= reference, variable to store the entered string
;
; Returns: 
;		None
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
mGetString MACRO strOffset:REQ, strDestOffset:REQ
	; Preserve used registers
	PUSH	EAX
	PUSH	ECX
	PUSH	EDX

	; Print the user prompt
	MOV		EDX, strOffset
	Call	WriteString

	; Read the string into the buffer
	MOV		ECX, MAX_FILENAME_SIZE
	DEC		ECX						; dec 1 to leave a space for the null terminator
	MOV		EDX, strDestOffset
	CALL	ReadString

	; Restore registers
	POP		EDX
	POP		ECX
	POP		EAX

ENDM

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Name: mDisplayString
;
;	Prints a string. 
;
; Preconditions: Passed parameter must be a null-terminated string.
;
; Postconditions: None. All used registeres are restored
;
; Receives:
;		strOffset = reference, string to print
;
; Returns: 
;		None
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
mDisplayString MACRO strOffset:REQ
	; Preserve all used registers
	PUSH	EDX

	MOV		EDX, strOffset
	CALL	WriteString

	; Restore all used registers
	POP		EDX
ENDM

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Name: mDisplayChar
;
;	Prints an ASCII-formatted character.
;
; Preconditions: Character to print must be ASII-formatted.
;
; Postconditions: None. All used registeres are restored
;
; Receives:
;		asciiChar = CONSTANT, character literal to print
;
; Returns: 
;		None
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
mDisplayChar MACRO asciiChar:REQ
	; Preserve register
	PUSH	EAX

	; Print the character
	MOV		AL, asciiChar
	CALL	WriteChar

	; Restore register
	POP		EAX

ENDM



;-----------
; CONSTANTS 
;-----------

TEMPS_PER_DAY		= 24		; Set to number of temps per line.
NUM_DAYS			= 1			; For multi-line files. Must equal number of lines in the file. Set to 1 for one line test file
BUFFER_SIZE			= 5000		; For multi-line files. Increase if input file is greater than 5KB.
MAX_FILENAME_SIZE	= 100		; Increase for larger filename if needed
DELIMITER			EQU <','>	; Adjust for different delimiter. '+' or '-' should not be used.

.data

;-----------
; VARIABLES 
;-----------
fileBuffer		BYTE	BUFFER_SIZE DUP(?)			
fileHandle		DWORD	?
tempArray		SDWORD	TEMPS_PER_DAY * NUM_DAYS DUP(?)
intro1			BYTE	"						Intern Error-Corrector by Ian Henderson",13,10,0	
intro2			BYTE	"Welcome to the intern error-corrector! ",
						"I'll read a '",DELIMITER, "'-delimited file storing a series of temperature values. The file must be ASCII-formatted.",13,10,
						"I'll then reverse the ordering and provide the corrected temperature ordering as a printout.",13,10,13,10,0
ec_title		BYTE	"**EC: This program will handle multiple-line files depending on CONSTANT(s). The NUM_DAYS constant must equal the number of lines in the input file,",13,10,
						"and each line must contain the same number of temperatures. Adjust BUFFER_SIZE if file size exceeds 5KB.",13,10,13,10,0
userPrompt1		BYTE	"Enter the name of the file to be read: ",0
fileName		BYTE	MAX_FILENAME_SIZE DUP(?)
printTitle		BYTE	"Here's the corrected temperature order:",13,10,0
filenameError	BYTE	"Could not open the file. Please double-check your file name.",13,10,0




.code
main PROC

;-------------------------------------------------------------------------------------------------
; Introduce the program
;-------------------------------------------------------------------------------------------------
	; Print the program title
	mDisplayString	OFFSET intro1
	CALL			CrLf

	; Print the program description
	mDisplayString	OFFSET intro2

	; Print EC description
	mDisplayString	OFFSET ec_title

;-------------------------------------------------------------------------------------------------
; Get a file name from the user for the file to open
;-------------------------------------------------------------------------------------------------
	mGetString		OFFSET userPrompt1, OFFSET fileName

;-------------------------------------------------------------------------------------------------
; Read the file into the file buffer. Print an error message if the file could not be opened.
;-------------------------------------------------------------------------------------------------
	; Open the file. OpenInputFile preconditions: EDX = address of filename
	MOV				EDX, OFFSET fileName
	CALL			OpenInputFile				; file handle in EAX
	CMP				EAX, INVALID_HANDLE_VALUE
	JE				_fileOpenError
	MOV				fileHandle, EAX				; postconditions: EAX = file handle, INVALID_HANDLE_VALUE if failed to open file

	; Read the file to the buffer. ReadFromFile preconditions: EAX = file handle, ECX = buffer size, EDX = address of buffer
	MOV				ECX, BUFFER_SIZE		
	MOV				EDX, OFFSET fileBuffer
	CALL			ReadFromFile				; postconditions: CF = 1 if error occured, EAX contains num bytes read
	
	; Close the file. CloseFile preconditions: EAX must contain file handle
	MOV				EAX, fileHandle
	CALL			CloseFile
	JMP				_parseString

_fileOpenError:
	; Print the program description
	CALL			CrLf
	mDisplayString	OFFSET filenameError
	JMP				_end

;-------------------------------------------------------------------------------------------------
; Convert the string of ascii-formatted numbers from input file to their numeric values and store 
;		temps in an temperature array
;-------------------------------------------------------------------------------------------------
_parseString:
	; ParseTempFromString: 
	PUSH			OFFSET fileBuffer	;input
	PUSH			OFFSET tempArray	;output
	CALL			ParseTempFromString

;-------------------------------------------------------------------------------------------------
; Print the temperature array in reverse orders, with values separated by the delimiter character.
;-------------------------------------------------------------------------------------------------
	; Print the title for the user
	CALL			CrLf
	mDisplayString	OFFSET printTitle
	
	; Print the reversed array
	PUSH			LENGTHOF tempArray
	PUSH			OFFSET tempArray
	CALL			WriteTempsReverse

_end:
	Invoke ExitProcess,0	; exit to operating system
main ENDP


;------------
; PROCEDURES 
;------------
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Name: ParseTempFromString
;
;	Converts a string of ASCII-formatted numbers separated by a delimiter to their integer values and adds them to a SDWORD array.
;
; Preconditions: tempArray must be of type SDWORD, and input file must have been read into fileBuffer
;
; Postconditions: None all used registers restored.
;
; Receives:
;		[EBP + 12]	= reference, start of fileBuffer, the start of the string of ASCII-formatted numbers read from input file
;		[EBP + 8]	= reference, start of SDWORD array that will hold the converted numbers
;
; Returns: 
;		tempArray contains the converted numbers
;
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ParseTempFromString	PROC
		PUSH	EBP
		MOV		EBP, ESP

		PUSH	EAX
		PUSH	EBX
		PUSH	ECX
		PUSH	EDX
		PUSH	ESI
		PUSH	EDI

		; Cheat sheet
		; [EBP + 12]	= fileBuffer
		; [EBP + 8]		= tempArray
		; [EBP + 4]		= return to main
		; [EBP]			= old ebp

		; Setup registers
		MOV		ESI, [EBP + 12]
		MOV		EDI, [EBP + 8]
		MOV		AH, 0					; accumulator for current total
		MOV		BL, 10					; multiplier
		MOV		BH,0					; accumulator representing the sign of the number. 1 if negative, 0 if positive
		MOV		ECX, NUM_DAYS			; counter for number of lines to read. Global used, but OK because constant.
		PUSH	ECX
		MOV		ECX, TEMPS_PER_DAY		; counter for number of temps to read per day. Global used but OK because constant.
		CLD								; clear to move forward through string

;--------------------------------------------------------------------------------------
; Checks a character and determines whether to add current total to the array, update the sign 
;		accumulator, or make the current total negative if required. 
;		If the read character is the delimiter, check if it must be converted from positive
;			to negative. From there it will be added to the array.
;		If the read character is a minus sign, update the sign accumulator accordingly
;		EC: If the read character is the carriage return or line feed, read the next character
;--------------------------------------------------------------------------------------
	_checkChar:
		LODSB								

		CMP		AL, DELIMITER			; Global used but ok because constant
		JE		_makeNegativeIfNegative
		CMP		AL, '-'					
		JE		_saveNegSign
		CMP		AL, 13					
		JE		_checkChar
		CMP		AL, 10					
		JE		_checkChar

;--------------------------------------------------------------------------------------
; Converts the ASCII string number to an integer. Converts from ascii to the number 
;		it represents, then adds it to 10 * current total in the accumulator AH.
;--------------------------------------------------------------------------------------
	_parseInt:
		SUB		AL, '0'					; convert ascii value
		PUSH	AX						; move the current digit to add onto the stack
		MOV		AL, AH					; move accumulator for current total into AL for use with MUL
		MUL		BL
		POP		DX						
		ADD		AL, DL					; add the current digit to 10 * current total
		MOV		AH, AL					; update current total
		JMP		_checkChar

;--------------------------------------------------------------------------------------
; Updates the sign accumulator to 1 if the read character was a minus sign.
;--------------------------------------------------------------------------------------
	_saveNegSign:
		INC		BH
		JMP		_checkChar

;--------------------------------------------------------------------------------------
; Negates the current total in the accumulator if the number is negative.
;--------------------------------------------------------------------------------------
	_makeNegativeIfNegative:
		CMP		BH, 0
		JE		_addPosIntToArray		
		NEG		AH						; make the integer negative if ECX is not 1
		JMP		_addNegIntToArray
		
;--------------------------------------------------------------------------------------
; Adds the integers to the array. Negative values are sign extended for use with STOSD,
;		positive values are zero extended for use with STOSD.
;--------------------------------------------------------------------------------------
	_addPosIntToArray:
		MOVZX		EAX, AH
		STOSD
		JMP		_setupNextCharCheck

	_addNegIntToArray:
		MOVSX		EAX, AH
		STOSD

;--------------------------------------------------------------------------------------
; Updates the registers to check the next number string until each temp per day has been parsed.
;		Then loads TEMPS_PER_DAY back into the counter to parse the next line of temperatures.
;		Loops until each line has been parsed.
;--------------------------------------------------------------------------------------
	; Update registers to check the next number string
	_setupNextCharCheck:
		MOV		EAX, 0					; clear EAX for LODSB
		MOV		BH, 0					; reset integer sign
		LOOP	_checkChar

	; Check to see if all lines have been parsed and parse the first number in the next line if not. If so, jump to the end.
		POP		ECX
		DEC		ECX
		CMP		ECX, 0
		JE		_end
		PUSH	ECX
		MOV		ECX, TEMPS_PER_DAY
		JMP		_checkChar
		
	_end:
		POP		EDI
		POP		ESI
		POP		EDX
		POP		ECX
		POP		EBX
		POP		EAX
		POP		EBP
		RET		8

ParseTempFromString ENDP

;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Name: WriteTempsReverse
;
;	Prints the temperatures in reverse order from the input file.
;
; Preconditions: tempArray must be of type SDWORD and populated with integers converted from ASCII number strings.
;
; Postconditions: None. All used registers are restored.
;
; Receives:
;		[EBP + 12]	= length of tempArray
;		[EBP + 8]	= reference, start of tempArray
; Returns: 
;		None
;
;----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WriteTempsReverse	PROC
		PUSH	EBP
		MOV		EBP, ESP

		PUSH	EAX
		PUSH	EBX
		PUSH	ECX
		PUSH	EDX
		PUSH	EDI
		PUSH	ESI

		; Cheat sheet
		; [EBP + 12]	= LENGTHOF tempArray
		; [EBP + 8]		= tempArray

;--------------------------------------------------------------------------------------
; Sets up the registers for printing each line of input file in reverse order. ESI is
;		set to the position in the array that represents the last number of each line 
;		from the input file.
;--------------------------------------------------------------------------------------
		MOV		ECX, [EBP + 12]			
		MOV		ESI, [EBP + 8]
		MOV		EDX, 0					; used to count up to TEMPS_PER_DAY
		
		; Set ESI to point in array that represents last number of current line to print
	_setupSource:
		MOV		EAX, TEMPS_PER_DAY		; global used but OK because constant
		MOV		EBX, 4
		MUL		EBX
		SUB		EAX, 4
		ADD		ESI, EAX

;--------------------------------------------------------------------------------------
; Prints the integer followed by the delimiter character until all temperatures for that
;		day have been printed. 
;--------------------------------------------------------------------------------------
	_printInt:
 		CMP		EDX, TEMPS_PER_DAY		; global used but OK because constant
		JE		_printLineBreak
		MOV		EAX, [ESI]
		CALL	WriteInt

		; Print the delimiter
		mDisplayChar DELIMITER			; global used but OK because constant
		SUB		ESI, 4
		INC		EDX
		LOOP	_printInt

;--------------------------------------------------------------------------------------
; Prints a new line, then sets ESI to the position in the array that represents the last
;		number of the next line to print from the input file. Updates temps per day counter
;		to print each temp of next line.
;--------------------------------------------------------------------------------------
	_printLineBreak:
		CALL	CrLf
		MOV		EDX, 0
		CMP		ECX, 0
		JNE		_toNextRow
		JMP		_end
	_toNextRow:
		ADD		ESI, 4
		MOV		EAX, TEMPS_PER_DAY		; global, but OK because constant
		MOV		EBX, 4
		MUL		EBX
		ADD		ESI, EAX
		JMP		_setupSource

	_end:
		; Restore used registers and return
		POP		ESI
		POP		EDI
		POP		EDX
		POP		ECX
		POP		EBX
		POP		EAX
		POP		EBP
		RET		8
WriteTempsReverse	ENDP


END main
