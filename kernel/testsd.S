    .align 4
    .section .data
    .global inittest
    .global sizeofinittest
inittest:
    .incbin "./xv6-user/inittest.bin"
codeend:

sizeofinittest:
    .long codeend-inittest