; Image Compression with Run-Length Encoding (RLE) Algorithm
; Computer Organization & Assembly Language (COAL) [EE-229] Fall 2020 Semester Project
; Developed by Ali Raza, Muhammad Hammad and Abdul Ali Khan
TITLE Image Compression with Run-Length Encoding Algorithm
INCLUDE irvine32.inc
.data
	BUFSIZE = 5000
	maxNoOfChars = 80
	buffer BYTE BUFSIZE DUP(?)
	outputBuffer BYTE BUFSIZE DUP(?)
	backupOfBuffer BYTE BUFSIZE DUP(?)
	defaultFileName BYTE "default.txt", 0
	fileName BYTE maxNoOfChars DUP(?)
	compressedfileName BYTE maxNoOfChars DUP(?)
	decompressedFileName BYTE maxNoOfChars DUP(?)
	fileHandle HANDLE ?
	imageWidth DWORD ?
	imageHeight DWORD ?
	totalNoOfBytes DWORD ?
	bytesWritten DWORD ?
	bytesRead DWORD ?
	choicePrompt BYTE "Enter choice (1-7): ", 0
	prompt1 BYTE "Enter image width: ", 0
	prompt2 BYTE "Enter image height: ", 0
	prompt3 BYTE "Enter the name of the compressed file: ", 0
	prompt4 BYTE "Enter the name of the uncompressed file: ", 0
	prompt5 BYTE "Enter the name of the file to compress: ", 0
	prompt6 BYTE "Enter the name of the file to store the compressed grid: ", 0
	flattenPrompt BYTE "Enter the range of RGB Values to flatten: ", 0
	flattenRange BYTE ?
	text1 BYTE "Compression Ratio: ", 0
	text2 BYTE "The compression was unsuccessful.", 0
	text3 BYTE "Size of original image (in bytes): ", 0
	text4 BYTE "Size of compressed image (in bytes): ", 0
	text5 BYTE "Percentage loss in quality: ", 0
	decompressSuccess BYTE "The image has been successfully decompressed. The result has been stored to ", 0
	generationSuccess BYTE "The generated RGB grid has been successfully stored to ", 0
	invalidInputError BYTE "Invalid choice. Please try again.", 0
	projTitle BYTE "Image Compression with Run Length Encoding Algorithm", 0
	neon BYTE "########  ##       ########", 0
	rowSize = $ - neon
		 BYTE "##     ## ##       ##      ", 0
		 BYTE "##     ## ##       ##      ", 0
		 BYTE "########  ##       ######  ", 0
		 BYTE "##   ##   ##       ##      ", 0
		 BYTE "##    ##  ##       ##      ", 0
		 BYTE "##     ## ######## ########", 0

	menuTextArray BYTE "1. Generate a pseudo-random RGB Grid              ", 0
	menuRowSize = $ - menuTextArray
				  BYTE "2. View a Compressed Image                        ", 0
				  BYTE "3. View an Uncompressed Image                     ", 0
				  BYTE "4. Compress an Image with LOSSLESS RLE Compression", 0
				  BYTE "5. Compress an Image with LOSSY RLE Compression   ", 0
				  BYTE "6. Decompress an Image                            ", 0
				  BYTE "7. Exit				                              ", 0
.code
viewImageFromBuffer PROTO, bufferPtr: PTR BYTE
decompressImage PROTO, compressedFileNameArg: PTR BYTE
displayCompressedImage PROTO, compressedFileNameArg: PTR BYTE
main PROC
	call displayMenu
	;call generateRGBGrid
	;call viewImageFromBuffer
	;call displayGrid
	;call losslessCompression
	;call displayCompressedImage
	;call lossyCompression
	;call decompressImage
	exit
main ENDP

	displayHeader PROC
		call clrscr ; clear the screen
		; Display "RLE" Neon Text
		mov ecx, 7
		mov edx, OFFSET neon
		L1:
			call WriteString
			call crlf
			add edx, rowSize
		LOOP L1
		call crlf
		; Display Project Title
		mov edx, OFFSET projTitle
		call WriteString
		call crlf
		call crlf
		RET
	displayHeader ENDP

	displayMenu PROC
		LOCAL choice: DWORD
		; Display "RLE" and the project title on top
		call displayHeader
		; Display a list of choices
		mov ecx, 7
		mov edx, OFFSET menuTextArray
		L2:
			call WriteString
			call crlf
			add edx, menuRowSize
		LOOP L2
		call crlf

		; ask the user to enter a choice between 1 and 7
		takeInput:
		mov edx, OFFSET choicePrompt
		call WriteString
		call ReadInt
		mov choice, eax
		; check if the entered number is between 1 and 7
		cmp choice, 7
		ja invalidInput
		cmp choice, 1
		jb invalidInput
		; input is valid
		cmp choice, 1
		je option1
		cmp choice, 2
		je option2
		cmp choice, 3
		je option3
		cmp choice, 4
		je option4
		cmp choice, 5
		je option5
		cmp choice, 6
		je option6
		jmp quit
		option1:
			; copy the default file name (default.txt) to the fileName variable
			cld ; direction = forward
			mov esi, OFFSET defaultFileName
			mov edi, OFFSET fileName
			mov ecx, LENGTHOF defaultFileName
			rep movsb
			call displayHeader
			call generateRGBGrid
			invoke viewImageFromBuffer, addr buffer
			call WaitMsg
			call displayMenu ; go back to the main menu
			jmp quit
		option2:
			call displayHeader
			; copy the default file name (default.txt) to the decompressedFileName variable
			; we need to do this to store the decompressed file
			cld ; direction = forward
			mov esi, OFFSET defaultFileName
			mov edi, OFFSET decompressedFileName
			mov ecx, LENGTHOF defaultFileName
			; ask the user to enter the name of the compressed file
			mov edx, OFFSET prompt3 ; Enter the name of the compressed file prompt
			call WriteString
			mov ecx, maxNoOfChars
			mov edx, OFFSET fileName
			call ReadString
			invoke displayCompressedImage, ADDR fileName
			invoke decompressImage, ADDR fileName
			invoke viewImageFromBuffer, addr outputBuffer
			call WaitMsg
			call displayMenu ; go back to the main menu
			jmp quit
		option3:
			call displayHeader
			; ask the user to enter the name of the file to view
			mov edx, OFFSET prompt4 ; Enter the name of the uncompressed file prompt
			call WriteString
			mov ecx, maxNoOfChars
			mov edx, OFFSET fileName
			call ReadString
			call displayGrid
			invoke viewImageFromBuffer, addr buffer
			call WaitMsg
			call displayMenu ; go back to the main menu
			jmp quit
		option4:
			call displayHeader
			; ask the user to enter the name of the file to compress
			mov edx, OFFSET prompt5 ; Enter the name of the file to compress prompt
			call WriteString
			mov ecx, maxNoOfChars
			mov edx, OFFSET fileName
			call ReadString
			; ask the user to enter the name of the file where the result should be stored
			mov edx, OFFSET prompt6 ; Enter the name of the file to store the result prompt
			call WriteString
			mov ecx, maxNoOfChars
			mov edx, OFFSET compressedFileName
			call ReadString
			call losslessCompression
			call WaitMsg
			call displayMenu ; go back to the main menu
			jmp quit
		option5:
			call displayHeader
			; ask the user to enter the name of the file to compress
			mov edx, OFFSET prompt5 ; Enter the name of the file to compress prompt
			call WriteString
			mov ecx, maxNoOfChars
			mov edx, OFFSET fileName
			call ReadString
			; ask the user to enter the name of the file where the result should be stored
			mov edx, OFFSET prompt6 ; Enter the name of the file to store the result prompt
			call WriteString
			mov ecx, maxNoOfChars
			mov edx, OFFSET compressedFileName
			call ReadString
			call lossyCompression
			call WaitMsg
			call displayMenu ; go back to the main menu
			jmp quit
		option6:
			call displayHeader
			; ask the user to enter the name of the file to decompress
			mov edx, OFFSET prompt3 ; Enter the name of the compressed file prompt
			call WriteString
			mov ecx, maxNoOfChars
			mov edx, OFFSET fileName
			call ReadString
			; ask the user to enter the name of the file where the result should be stored
			mov edx, OFFSET prompt4 ; Enter the name of the uncompressed file prompt
			call WriteString
			mov ecx, maxNoOfChars
			mov edx, OFFSET decompressedFileName
			call ReadString
			invoke decompressImage, ADDR fileName
			call WaitMsg
			call displayMenu ; go back to the main menu
		jmp quit
		invalidInput:
			mov edx, OFFSET invalidInputError
			call WriteString
			call crlf
			jmp takeInput ; ask the user to enter another number
		quit:
		RET
	displayMenu ENDP

	generateRGBGrid PROC
		mov edx, OFFSET prompt1
		call WriteString
		call ReadInt
		mov imageWidth, eax
		mov edx, OFFSET prompt2
		call WriteString
		call ReadInt
		mov imageHeight, eax
		; Generate an RGB Grid
		; the first two bytes of the file will contain
		; the width and height of the image respectively
		mov esi, OFFSET buffer
		mov al, BYTE PTR imageWidth
		mov BYTE PTR [esi], al
		inc esi
		mov al, BYTE PTR imageHeight
		mov BYTE PTR [esi], al
		inc esi
		mov eax, imageWidth
		mul imageHeight
		mov ecx, eax
		mov totalNoOfBytes, eax
		add totalNoOfBytes, 2
		; re-seed the random number generator with the current time in hundredths of seconds
		call Randomize
		L1:
			mov eax, 256 ; get a random number between 0 to 255
			call RandomRange
			mov BYTE PTR [esi], al
			inc esi
		LOOP L1

		mov edx, OFFSET fileName
		call CreateOutputFile
		mov filehandle, EAX
		mov eax, fileHandle
		mov edx, OFFSET buffer
		mov ecx, totalNoOfBytes
		call WriteToFile
		jc show_error_message
		; the generated grid has been stored in a file
		; tell the user the file name
		mov edx, OFFSET generationSuccess
		call WriteString
		mov edx, OFFSET fileName
		call WriteString
		call crlf
		mov bytesWritten, eax
		mov eax, fileHandle
		jmp quit
		show_error_message:
			; EAX contains a system error code
			call WriteWindowsMsg
		quit:
			mov eax, fileHandle
			call CloseFile
			RET
	generateRGBGrid ENDP

	displayGrid PROC
		LOCAL count: BYTE
		mov count, 0
		; try to open the file
		mov EDX, OFFSET fileName
		call OpenInputFile
		mov fileHandle, EAX
		mov eax, fileHandle
		mov edx, OFFSET buffer
		mov ecx, BUFSIZE
		call ReadFromFile
		; if CF = 1, the file couldn't be read
		jc show_error_message
		; if CF = 0, the file was read successfully
		; EAX contains the number of bytes read
		; the file's contents go to the BUFFER variable
		; mov bytesRead, eax
		mov esi, OFFSET buffer
		mov ecx, 0
		; store the image width in BL
		mov bl, BYTE PTR [esi]
		inc esi
		; store the image height in CL
		mov cl, BYTE PTR [esi]
		inc esi
		; the outer loop runs <image height times>
		L1:
			mov count, cl
			mov cl, bl
			; the inner loop runs <image width> times
			L2:
				; It is necessary to make eax = 0 here,
				; so that the data in EAX apart from that in the AL portion
				; doesn't affect the output
				mov eax, 0
				mov al, BYTE PTR [esi]
				call WriteDec
				mov al, 32
				call WriteChar
				inc esi
			LOOP L2
			call crlf
			mov cl, count
		LOOP L1
		call crlf
		jmp quit
		show_error_message:
			; EAX contains a system error code
			call WriteWindowsMsg
		quit:
			mov eax, fileHandle
			call CloseFile
			RET
	displayGrid ENDP

	losslessCompression PROC
		LOCAL count: BYTE, RGBVal: BYTE, bytesInOutputFile: DWORD
		; try to open the file to compress
		mov EDX, OFFSET fileName
		call OpenInputFile
		mov fileHandle, EAX
		mov eax, fileHandle
		mov edx, OFFSET buffer
		mov ecx, BUFSIZE
		call ReadFromFile
		; if CF = 1, the file couldn't be read
		jc show_error_message
		mov bytesRead, eax
		mov eax, fileHandle
		call CloseFile

		mov count, 1
		mov esi, OFFSET buffer
		mov edi, OFFSET outputBuffer
		; reserve the first two bytes as the imageWidth and imageHeight respectively
		mov bytesInOutputFile, 2
		mov bl, BYTE PTR [esi]
		mov [edi], bl
		mov al, bl
		mov bl, BYTE PTR [esi+1]
		mov [edi+1], bl
		add esi, 2
		add edi, 2
		mul bl
		movzx ecx, ax
		; the last comparison should be done with the
		; second last and last RGB value, so run the loop
		; till noOfRGBValues-1
		dec ecx
		L1:
			mov bl, BYTE PTR [esi]
			cmp bl, BYTE PTR [esi+1]
			je identicalRGB
			jmp nonIdenticalRGB
			identicalRGB:
				inc count
				mov RGBVal, bl
				jmp next
			nonIdenticalRGB:
				mov bl, BYTE PTR [esi]
				mov al, count
				mov [edi], al
				inc bytesInOutputFile
				inc edi
				mov [edi], bl
				inc bytesInOutputFile
				inc edi
				mov count, 1
			next:
				inc esi
		LOOP L1
		; for the last pixel
		mov al, count
		mov [edi], al
		inc bytesInOutputFile
		inc edi
		mov [edi], bl
		inc bytesInOutputFile
		mov edx, OFFSET compressedFileName
		call CreateOutputFile
		mov filehandle, EAX
		mov  eax,fileHandle
		mov  edx,OFFSET outputBuffer
		mov  ecx, bytesInOutputFile
		call WriteToFile
		jc  show_error_message
		; Show the size of the compressed image & original image
		mov edx, OFFSET text3
		call WriteString
		mov eax, bytesRead
		call WriteDec
		call crlf
		mov edx, OFFSET text4
		call WriteString
		mov eax, bytesInOutputFile
		call WriteDec
		call crlf

		; Check if the compressed image is actually smaller than the original image
		mov eax, bytesRead ; eax = original size in bytes
		cmp eax, bytesInOutputFile
		; if original size > compressed size, display compression ratio
		ja displayCompressionRatio
		jmp compressionFailed
		displayCompressionRatio:
		; Calculate and display the compression ratio
		; Compression Ratio = (Original Size (in Bytes) - New Size (in Bytes))/(Original Size (in Bytes))
		mov edx, OFFSET text1
		call WriteString
		mov eax, bytesRead ; eax = original size in bytes
		sub eax, bytesInOutputFile ; eax = original size in bytes - new size in bytes
		mov ebx, 100
		mul ebx
		mov edx, 0
		div bytesRead
		call WriteDec
		mov eax, '.'
		call WriteChar
		; EDX contains the remainder
		; Using this, we can obtain the fractional part (remainder*10000)/bytesRead
		mov eax, edx
		mov ebx, 10000
		mul ebx
		div bytesRead
		call WriteDec
		mov eax, '%'
		call WriteChar
		call crlf
		jmp quit
		compressionFailed:
			mov edx, OFFSET text2
			call WriteString
			call crlf
			jmp quit
		show_error_message:
			; EAX contains a system error code
			call WriteWindowsMsg
		quit:
			mov eax, fileHandle
			call CloseFile
			RET
	losslessCompression ENDP

	displayCompressedImage PROC, compressedFileNameArg: PTR BYTE
		LOCAL rowCount: DWORD, totalRGBVals: WORD, imgWidth: BYTE, imgHeight: BYTE
		mov rowCount, 0
		; try to open the file
		mov EDX, compressedFileNameArg
		call OpenInputFile
		mov fileHandle, EAX
		mov eax, fileHandle
		mov edx, OFFSET buffer
		mov ecx, BUFSIZE
		call ReadFromFile
		; if CF = 1, the file couldn't be read
		jc show_error_message
		; if CF = 0, the file was read successfully
		; the file's contents go to the BUFFER variable
		call crlf
		mov esi, OFFSET buffer
		mov ecx, 0
		; get the image width from the file
		mov bl, BYTE PTR [esi]
		mov imgWidth, bl
		; get the image height from the file
		mov bl, BYTE PTR [esi+1]
		mov imgHeight, bl
		mov al, imgWidth
		mul bl
		mov totalRGBVals, ax
		add esi, 2
		L1:
			; get the run
			mov cl, BYTE PTR [esi]
			inc esi
			L2:
				; It is necessary to make eax = 0 here,
				; so that the data in EAX apart from that in the AL portion
				; doesn't affect the output
				mov eax, 0
				mov al, BYTE PTR [esi]
				call WriteDec
				inc rowCount
				movzx eax, imgWidth
				; if the row count has reached the width of the image,
				; print a new line and reset the row count
				cmp rowCount, eax
				jne printSpace
				call crlf
				mov rowCount, 0
				jmp next
				printSpace:
					mov al, 32
					call WriteChar
				next:
					dec totalRGBVals
					cmp totalRGBVals, 0
					je imageComplete
			LOOP L2
			inc esi
			jmp L1
		imageComplete:
		call crlf
		jmp quit
		show_error_message:
			; EAX contains a system error code
			call WriteWindowsMsg
		quit:
			mov eax, fileHandle
			call CloseFile
		RET
	displayCompressedImage ENDP

	lossyCompression PROC
		LOCAL count: BYTE, RGBVal: BYTE, bytesInOutputFile: DWORD, noOfRGBVals: DWORD, temp: DWORD
		; Ask the user to enter the range of flattening
		mov edx, OFFSET flattenPrompt
		call WriteString
		call ReadInt
		mov flattenRange, al
		; try to open the file to compress
		mov EDX, OFFSET fileName
		call OpenInputFile
		mov fileHandle, EAX
		mov eax, fileHandle
		mov edx, OFFSET buffer
		mov ecx, BUFSIZE
		call ReadFromFile
		; if CF = 1, the file couldn't be read
		jc show_error_message
		mov bytesRead, eax
		mov eax, fileHandle
		call CloseFile

		; Before flattening the grid, backup the original grid
		; so that we can later determine the loss in quality
		mov esi, OFFSET buffer
		mov edi, OFFSET backupOfBuffer
		mov eax, 0
		mov ebx, 0
		mov al, BYTE PTR [esi]
		mov imageWidth, eax
		mov bl, BYTE PTR [esi+1]
		mov imageHeight, ebx
		add esi, 2
		add edi, 2
		mul bl
		movzx ecx, ax
		mov noOfRGBVals, ecx
		L0:
			mov bl, BYTE PTR [esi]
			mov BYTE PTR [backupOfBuffer], bl
			inc esi
			inc edi
		LOOP L0
		; Flatten the current RGB grid (in the buffer array)
		mov esi, OFFSET buffer
		mov al, BYTE PTR [esi]
		mov bl, BYTE PTR [esi+1]
		add esi, 2
		mul bl
		movzx ecx, ax
		; the last comparison should be done with the
		; second last and last RGB value, so run the loop
		; till noOfRGBValues-1
		dec ecx
		L1:
			; we need the absolute difference between the two RGB values
			mov bl, BYTE PTR [esi]
			mov bh, BYTE PTR [esi+1]
			cmp bl, bh
			ja diff1 ; [esi] > [esi+1]
			; [esi] <= [esi+1]
			sub bh, bl
			cmp bh, flattenRange
			jmp checkFlatten
			diff1:
				sub bl, bh
				; acceptable range for flattening = flattenRange
				cmp bl, flattenRange
			checkFlatten:
			jbe flatten
			jmp next
			flatten:
				mov bl, [esi]
				mov [esi+1], bl
			next:
				inc esi
		LOOP L1
		mov count, 1
		mov esi, OFFSET buffer
		mov edi, OFFSET outputBuffer
		; reserve the first two bytes as the imageWidth and imageHeight respectively
		mov bytesInOutputFile, 2
		mov bl, BYTE PTR [esi]
		mov [edi], bl
		mov al, bl
		mov bl, BYTE PTR [esi+1]
		mov [edi+1], bl
		add esi, 2
		add edi, 2
		mul bl
		movzx ecx, ax
		; the last comparison should be done with the
		; second last and last RGB value, so run the loop
		; till noOfRGBValues-1
		dec ecx
		L2:
			mov bl, BYTE PTR [esi]
			cmp bl, BYTE PTR [esi+1]
			je identicalRGB
			jmp nonIdenticalRGB
			identicalRGB:
				inc count
				mov RGBVal, bl
				jmp next2
			nonIdenticalRGB:
				mov bl, BYTE PTR [esi]
				mov al, count
				mov [edi], al
				inc bytesInOutputFile
				inc edi
				mov [edi], bl
				inc bytesInOutputFile
				inc edi
				mov count, 1
			next2:
				inc esi
		LOOP L2
		; for the last row
		mov al, count
		mov [edi], al
		inc bytesInOutputFile
		inc edi
		mov [edi], bl
		inc bytesInOutputFile
		mov edx, OFFSET compressedFileName
		call CreateOutputFile
		mov filehandle, EAX
		mov  eax,fileHandle
		mov  edx,OFFSET outputBuffer
		mov  ecx, bytesInOutputFile
		call WriteToFile
		mov eax, fileHandle
		call CloseFile
		jc  show_error_message
		; Show the size of the compressed image & original image
		mov edx, OFFSET text3
		call WriteString
		mov eax, bytesRead
		call WriteDec
		call crlf
		mov edx, OFFSET text4
		call WriteString
		mov eax, bytesInOutputFile
		call WriteDec
		call crlf
		; Check if the compressed image is actually smaller than the original image
		mov eax, bytesRead ; eax = original size in bytes
		cmp eax, bytesInOutputFile
		; if original size > compressed size, display compression ratio
		ja displayCompressionRatio
		jmp compressionFailed
		displayCompressionRatio:
		; Calculate and display the compression ratio
		; Compression Ratio = (Original Size (in Bytes) - New Size (in Bytes))/(Original Size (in Bytes))
		mov edx, OFFSET text1
		call WriteString
		mov eax, bytesRead ; eax = original size in bytes
		sub eax, bytesInOutputFile ; eax = original size in bytes - new size in bytes
		mov ebx, 100
		mul ebx
		mov edx, 0
		div bytesRead
		call WriteDec
		mov eax, '.'
		call WriteChar
		; EDX contains the remainder
		; Using this, we can obtain the fractional part (remainder*10000)/bytesRead
		mov eax, edx
		mov ebx, 10000
		mul ebx
		div bytesRead
		call WriteDec
		mov eax, '%'
		call WriteChar
		call crlf
		jmp calcDisplayLossOfQuality
		compressionFailed:
			mov edx, OFFSET text2
			call WriteString
			call crlf

		; Calculate & Display the Loss of Quality
		calcDisplayLossOfQuality:
		mov ecx, noOfRGBVals
		mov esi, 2
		mov eax, 0
		mov ebx, 0
		L3:
			mov bl, backupOfBuffer[esi]
			cmp bl, buffer[esi]
			JC L31
			sub bl, buffer[esi]
			jmp L32
			L31:
				mov bl, buffer[esi]
				sub bl, backupOfBuffer[esi]
			L32:
				add al, bl
				inc esi
		Loop L3

		; Display the string "Percentage loss in quality: "
		mov edx, OFFSET text5
		call WriteString
		; multiply sum of differences by 100 to aid in percentage calculation
		mov temp, 100
		mul temp
		; backup sum of differences to ebx
		mov ebx, eax
		; dividing sum of differences by 255*imageWidth*imageHeight
		mov eax, imageWidth
		mul imageHeight
		mov temp, 255
		mul temp
		mov temp, eax
		mov eax, ebx ; EAX = sum of differences
		mov edx, 0
		div temp ; EAX = EAX/255*imageWidth*imageHeight
		call WriteDec
		mov eax, '.'
		call WriteChar ; display a decimal point
		; To get the fractional part, divide the remainder (EDX) by the divisor (temp)
		mov eax, edx ; EAX = remainder
		mov ebx, 10000 ; multiply the remainder by 10000 to get the fractional part upto the 4th place
		mul ebx
		div temp
		call WriteDec
		mov eax, '%'
		call WriteChar ; display the percentage symbol
		call crlf

		jmp quit
		show_error_message:
			; EAX contains a system error code
			call WriteWindowsMsg
		quit:
			RET
	lossyCompression ENDP

	; The following procedure uses the RGB grid in the buffer array
	; to display a colored image on the console
	viewImageFromBuffer PROC, bufferPtr: PTR BYTE
		LOCAL count: DWORD
		; AL  = Bits 0-3 = foreground color
		;       Bits 4-7 = background color
		mov esi, bufferPtr
		movzx ecx, BYTE PTR [esi+1] ; ECX = image height
		movzx ebx, BYTE PTR [esi] ; EBX = image width
		add esi, 2
		L1:
			mov count, ecx
			mov cl, bl
			L2:
				mov al, BYTE PTR [esi]
				mov ah, 0h
				call SetTextColor
				inc esi
				mov eax, ' '
				call WriteChar
			LOOP L2
			mov al, 0h
			mov ah, 0h
			call crlf
			mov ecx, count
		LOOP L1
		mov eax, green+(black*16)
		call SetTextColor
		call crlf
		RET
	viewImageFromBuffer ENDP

	decompressImage PROC, compressedFileNameArg: PTR BYTE
		LOCAL totalRGBVals: WORD, imgWidth: BYTE, imgHeight: BYTE
		; try to open the file
		mov EDX, compressedFileNameArg
		call OpenInputFile
		mov fileHandle, eax
		mov edx, OFFSET buffer
		mov ecx, BUFSIZE
		call ReadFromFile
		mov eax, fileHandle
		call CloseFile
		; if CF = 1, the file couldn't be read
		jc show_error_message
		; if CF = 0, the file was read successfully
		; the file's contents go to the BUFFER variable
		call crlf
		mov esi, OFFSET buffer
		mov edi, OFFSET outputBuffer
		mov ecx, 0
		; get the image width from the file
		mov bl, BYTE PTR [esi]
		mov imgWidth, bl
		mov BYTE PTR [edi], bl
		; get the image height from the file
		mov bl, BYTE PTR [esi+1]
		mov imgHeight, bl
		mov BYTE PTR [edi+1], bl
		mov al, imgWidth
		mul bl
		mov totalRGBVals, ax
		mov totalNoOfBytes, 2
		add esi, 2
		add edi, 2
		L1:
			; get the run
			mov cl, BYTE PTR [esi]
			inc esi
			L2:
				mov al, BYTE PTR [esi]
				mov BYTE PTR [edi], al
				inc totalNoOfBytes
				dec totalRGBVals
				cmp totalRGBVals, 0
				je imageComplete
				inc edi
			LOOP L2
			inc esi
			jmp L1
		imageComplete:
		; Save the decompressed RGB grid to a file
		mov edx, OFFSET decompressedFileName
		call CreateOutputFile
		mov fileHandle, eax
		mov edx, OFFSET outputBuffer
		mov ecx, totalNoOfBytes
		call WriteToFile
		jc show_error_message
		; Decompression successful - inform user
		mov edx, OFFSET decompressSuccess
		call WriteString
		mov edx, OFFSET decompressedFileName
		call WriteString
		call crlf
		mov bytesWritten, eax
		mov eax, fileHandle
		jmp quit
		show_error_message:
			; EAX contains a system error code
			call WriteWindowsMsg
		quit:
			mov eax, fileHandle
			call CloseFile
		RET
	decompressImage ENDP
END main