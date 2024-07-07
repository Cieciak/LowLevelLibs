# Cieciak's x86 libs

## Overview

This is a collection of my low-level x86 assembly libraries. Originally created for my OS, and developed for past two years.

## Requirements

* NASM Assembler
* x86 CPU running in Real Mode

## Usage

### 1. Include file

```nasm
    ...
    %include "libs/TextIO.asm"
    ...
```

> [!IMPORTANT]  
> You may need to add `-I` flag to your compiler

### 2. Use subroutines

```nasm
    ...
    call LIBNAME_LABEL
    ...
```

> [!CAUTION]  
> Libraries ARE NOT meant to be compiled to object files, it doesn't export antything.  
> They heavily rely on Real Mode functionality, running them in other modes may result in `Halt And Catch On Fire`.

## Example

```nasm
    %include "TextIO.asm"

    call TextIO_PRIMM
    db "Hello World", 0x00
    jmp $
```

> [!NOTE]  
> For this to work you have to load it into RAM
