# Intern Error-Corrector

**Course:** CS271 – Computer Architecture & Assembly Language
**Language:** x86 Assembly (MASM, Irvine32 library)

---

## Overview

This program corrects poorly formated data collection by lab interns. Said interns have collected temperature readings, but recoreded them in reverse order. This program will open the file, read it, convert the temperatures from ASCII to integers, and will print them in their correct order (reversing the order the intern entered). It will also handle multi-line files with certain parameters.

---

## Features

- **File I/O:** Prompts the user for a filename and reads a comma-delimited ASCII text file of temperature values.
- **ASCII-to-Integer Conversion:** Parses positive and negative integer strings (e.g., `-42`, `200`) from raw ASCII bytes into 32-bit signed integers.
- **Reversal:** Prints the temperature values in the corrected (reversed) order.
- **Multi-line Support:** Handles input files with multiple lines of temperatures. Each line is reversed and printed independently. The file must be formatted such that each line contains the same number of temps.
- **Error Handling:** Displays a descriptive error message if the specified file cannot be opened.

---

## Configuration

The program behavior is controlled by constants defined at the top of the source file. Adjust these before assembling to match your input file:

| Constant | Default | Description |
|---|---|---|
| `TEMPS_PER_DAY` | `24` | Number of temperature values per line |
| `NUM_DAYS` | `1` | Number of lines in the input file |
| `BUFFER_SIZE` | `5000` | Read buffer size in bytes — increase for files over 5KB |
| `MAX_FILENAME_SIZE` | `100` | Maximum characters allowed in the entered filename |
| `DELIMITER` | `,` | Character separating values (avoid `+` or `-`) |

---

## Input File Format

- Plain ASCII text file
- Values separated by the configured delimiter (default: `,`)
- Each line must contain exactly `TEMPS_PER_DAY` values
- File must contain exactly `NUM_DAYS` lines
- Temperature values must be in the range **-100 to 200**
- A trailing delimiter after the last value on each line is expected

**Example (`temps.txt`, 1 line, 24 values):**
```
-3,-2,0,3,7,10,15,20,25,30,35,40,45,42,38,34,30,25,20,15,10,5,2,-1,
```

---

## Implementation Details

### Macros

- **`mGetString`** — Prompts the user and reads a string (filename) from stdin.
- **`mDisplayString`** — Prints a null-terminated string.
- **`mDisplayChar`** — Prints a single ASCII character.

### Procedures

- **`ParseTempFromString`** — Iterates through the file buffer byte-by-byte, converting ASCII digit sequences to signed 32-bit integers using an accumulator and a sign flag, storing results in `tempArray`.
- **`WriteTempsReverse`** — Traverses `tempArray` from the last element of each line backward to the first, printing each value followed by the delimiter.

---

## What I Learned

- Register level string parsing and signed integer representation
- Designing, implementing, and calling low-level I/O procedures with the Irvine32 Library 
- Implementing and using macros alongside procedures
- Stack frame management
- Code style in x86 Assembly

---

## Files

-  `TempParser.asm` - Full program source 
-  `TestTemps.txt` - Collection of test input cases 
