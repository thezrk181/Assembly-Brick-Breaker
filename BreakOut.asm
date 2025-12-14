org 0x0100
jmp start

title1: db '  ###  #####  ###  ####  #####',0
title2: db ' #   #   #   #   # #   #   #  ',0
title3: db ' #####   #   ##### ####    #  ',0
title4: db ' #   #   #   #   # #  #    #  ',0
title5: db ' #   #   #   #   # #   # #####',0

title6: db '###  ####  ####  ###  #  #  ###  #  # #####',0
title7: db '#  # #  #  #    #   # # #  #   # #  #   #  ',0
title8: db '###  ####  ###  ##### ##   #   # #  #   #  ',0
title9: db '#  # #  #  #    #   # # #  #   # #  #   #  ',0
title10: db '###  #  #  #### #   # #  #  ###   ##    #  ',0

option1: db '1. Play Game',0
option2: db '2. Instructions',0
option3: db '3. Exit',0

instTitle: db '===== INSTRUCTIONS =====',0
instLine1: db 'Level 1: 4 Rows (No Drops)',0
instLine2: db 'Level 2: 5 Rows (PATTERN DROPS)',0
instLine3: db '  Catch $ (Green) = +20 PTS',0
instLine4: db '  Catch # (Red)    = LOSE LIFE',0
instLine5: db 'Control: Mouse/Trackpad',0
instLine6: db '  * Edges = Sharp Angle Turn',0
instLine7: db 'You have 3 lives!',0
instBack: db 'Press ESC to return to menu',0

currentScreen: db 0
score: dw 0
lives: db 3
level: db 1

ballX: db 40
ballY: db 20
ballDX: db 1
ballDY: db -1
paddleX: db 35
paddleSize: db 10
gameOver: db 0

bricks: times 60 db 0  

oldBallX: db 40
oldBallY: db 20
oldPaddleX: db 35

ballTimer: db 0
ballThreshold: db 24
dropTimer: db 0      

scoreText: db 'Score: ',0
livesText: db 'Lives: ',0
levelText: db 'Level: ',0
gameOverText: db 'GAME OVER! Final Score: ',0
winText: db 'YOU WIN! Final Score: ',0
pressEsc: db 'Press ESC to return to menu',0

dropX: times 5 db 0
dropY: times 5 db 0
dropActive: times 5 db 0
dropOldY: times 5 db 0
dropType: times 5 db 0      

brickColors: 
    db 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C, 0x0C
    db 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E, 0x0E
    db 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A
    db 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09, 0x09
    db 0x0D, 0x0D, 0x0D, 0x0D, 0x0D, 0x0D, 0x0D, 0x0D, 0x0D, 0x0D, 0x0D, 0x0D

level2DropMap:
    db 0,0,0,0,0,0, 0,0,0,0,0,0
    db 0,0,2,0,2,1, 0,0,2,0,2,1
    db 0,1,0,1,0,0, 0,1,0,1,0,0
    db 0,0,0,1,1,0, 0,0,0,1,1,0
    db 2,0,2,0,2,0, 2,0,2,0,2,0

sndBrick:
    pusha
    mov bx, 0x0300      
    mov cx, 0x200        
    call playSound
    popa
    ret

sndPaddle:
    pusha
    mov bx, 0x0600      
    mov cx, 0x300        
    call playSound
    popa
    ret

sndDie:
    pusha
    mov bx, 0x1800      
    mov cx, 0xFFFF      
    call playSound
    popa
    ret

playSound:
    mov al, 0xB6
    out 0x43, al
    
    mov ax, bx
    out 0x42, al        
    mov al, ah
    out 0x42, al        
    
    in al, 0x61
    or al, 0x03
    out 0x61, al
    
soundDelay:
    push cx
    mov cx, 0x050        
inDelay:
    loop inDelay
    pop cx
    loop soundDelay
    
    in al, 0x61
    and al, 0xFC
    out 0x61, al
    ret

clearScreen:
    mov ax, 0xB800
    mov es, ax
    xor di, di
    mov cx, 2000
    mov ax, 0x0020
    rep stosw
    ret

printString:
    push bx
    mov bl, ah
    mov ax, 0xB800
    mov es, ax
printLoop:
    lodsb
    cmp al, 0
    je endPrint
    mov ah, bl
    stosw
    jmp printLoop
endPrint:
    pop bx
    ret

drawMainMenu:
    call clearScreen
    mov ah, 0x0C 
    mov si, title1
    mov di, 524
    call printString
    mov si, title2
    mov di, 684
    call printString
    mov si, title3
    mov di, 844
    call printString
    mov si, title4
    mov di, 1004
    call printString
    mov si, title5
    mov di, 1164
    call printString
    
    mov ah, 0x0E
    mov si, title6
    mov di, 1474
    call printString
    mov si, title7
    mov di, 1634
    call printString
    mov si, title8
    mov di, 1794
    call printString
    mov si, title9
    mov di, 1954
    call printString
    mov si, title10
    mov di, 2114
    call printString

    mov ah, 0x0F
    mov si, option1
    mov di, 2788
    call printString
    mov si, option2
    mov di, 2948
    call printString
    mov si, option3
    mov di, 3108
    call printString
    ret

drawInstructions:
    call clearScreen
    mov si, instTitle
    mov di, 868
    mov ah, 0x0E
    call printString
    mov si, instLine1
    mov di, 1348
    mov ah, 0x0F
    call printString
    mov si, instLine2
    mov di, 1508
    call printString
    mov si, instLine3
    mov di, 1668
    call printString
    mov si, instLine4
    mov di, 1828
    mov ah, 0x04     
    call printString
    mov si, instLine5
    mov di, 1988
    mov ah, 0x0F
    call printString
    mov si, instLine6
    mov di, 2148
    call printString
    mov si, instLine7
    mov di, 2308
    call printString
    mov si, instBack
    mov di, 3028
    mov ah, 0x0A
    call printString
    ret

initGame:
    push ds
    pop es
    
    cmp byte [level], 1
    jne keepScore
    mov word [score], 0
keepScore:
    mov byte [lives], 3
    mov byte [ballX], 40
    mov byte [ballY], 18
    mov byte [ballDX], 1
    mov byte [ballDY], -1
    mov byte [paddleX], 35
    mov byte [gameOver], 0
    
    mov cx, 5
    mov di, dropActive
    xor al, al
    rep stosb
    
    mov cx, 60
    mov di, bricks
    xor al, al
    rep stosb
    
    mov di, bricks
    
    mov cx, 12
    mov al, 2
    rep stosb
    
    mov cx, 36
    mov al, 1
    rep stosb
    
    cmp byte [level], 2
    jne doneInit
    mov cx, 12
    mov al, 1
    rep stosb

doneInit:
    ret

drawBorder:
    mov ax, 0xB800
    mov es, ax
    mov di, 160
    mov cx, 80
    mov ax, 0x7FDB
topBorder:
    stosw
    loop topBorder
    mov di, 3840
    mov cx, 80
bottomBorder:
    stosw
    loop bottomBorder
    mov cx, 22
    mov di, 320
sideBorders:
    mov word [es:di], 0x7FDB
    mov word [es:di+158], 0x7FDB
    add di, 160
    loop sideBorders
    ret

drawBricks:
    mov ax, 0xB800
    mov es, ax
    mov si, bricks
    mov bx, brickColors 
    
    mov di, 500        
    mov cx, 12           
    call drawBrickRow
    
    mov di, 660        
    mov cx, 12
    call drawBrickRow
    
    mov di, 820        
    mov cx, 12
    call drawBrickRow
    
    mov di, 980        
    mov cx, 12
    call drawBrickRow
    
    cmp byte [level], 2
    jne endDrawBricks
    
    mov di, 1140       
    mov cx, 12
    call drawBrickRow
    
endDrawBricks:
    ret

drawBrickRow:
    push cx
drawBrickLoop:
    lodsb             
    mov ah, [bx]      
    inc bx
    cmp al, 0         
    je skipBrick
    
    mov al, 0xDB
    mov [es:di], ax
    mov [es:di+2], ax
    mov [es:di+4], ax
    mov [es:di+6], ax
    mov [es:di+8], ax
    
skipBrick:
    add di, 10
    loop drawBrickLoop
    pop cx
    ret

eraseBrick:
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov ax, bx
    mov bl, 12        
    div bl            
    mov dl, al
    mov dh, ah

    xor ah, ah
    mov al, dl
    add al, 3
    mov bl, 80
    mul bl
    add ax, 10        
    push ax

    mov al, dh
    mov bl, 5         
    mul bl
    pop bx
    add ax, bx
    shl ax, 1
    mov di, ax

    mov ax, 0xB800
    mov es, ax
    mov ax, 0x0020
    mov cx, 5
    rep stosw

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

updatePaddleMouse:
    mov ax, 3         
    int 0x33        
    shr cx, 3       
    
    cmp cl, 2
    jge checkRightBound
    mov cl, 2
    jmp updatePadVar
checkRightBound:
    mov al, 78
    sub al, [paddleSize]
    cmp cl, al
    jle updatePadVar
    mov cl, al
updatePadVar:
    mov [paddleX], cl
    ret

drawPaddle:
    mov ax, 0xB800
    mov es, ax
    mov di, 3680
    xor ax, ax
    mov al, [oldPaddleX]
    shl ax, 1
    add di, ax
    mov ah, 0x00
    mov al, ' '
    mov cl, [paddleSize]
    xor ch, ch
erasePad:
    mov [es:di], ax
    add di, 2
    loop erasePad

    mov di, 3680
    xor ax, ax
    mov al, [paddleX]
    shl ax, 1
    add di, ax
    mov ah, 0x09
    mov al, 0xDB
    mov cl, [paddleSize]
    xor ch, ch
drawPad:
    mov [es:di], ax
    add di, 2
    loop drawPad
    
    mov al, [paddleX]
    mov [oldPaddleX], al
    ret

drawBall:
    mov ax, 0xB800
    mov es, ax
    xor ax, ax
    mov al, [oldBallY]
    mov bx, 160
    mul bx
    mov di, ax
    xor ax, ax
    mov al, [oldBallX]
    shl ax, 1
    add di, ax
    mov word [es:di], 0x0020

    xor ax, ax
    mov al, [ballY]
    mov bx, 160
    mul bx
    mov di, ax
    xor ax, ax
    mov al, [ballX]
    shl ax, 1
    add di, ax
    mov ah, 0x0F
    mov al, 'O'
    mov [es:di], ax
    
    mov al, [ballX]
    mov [oldBallX], al
    mov al, [ballY]
    mov [oldBallY], al
    ret

spawnDrop:
    push ax
    
    mov cx, 5
    mov si, 0
findSlot:
    cmp byte [dropActive + si], 0
    je foundSlot
    inc si
    loop findSlot
    pop ax
    ret 
foundSlot:
    pop ax 
    mov byte [dropActive + si], 1
    mov byte [dropType + si], al  
    
    push ax
    mov al, [ballX]
    mov byte [dropX + si], al
    mov al, [ballY]
    mov byte [dropY + si], al
    mov byte [dropOldY + si], al
    pop ax
    ret

updateDrops:
    mov cx, 5
    mov si, 0
dropLoop:
    cmp byte [dropActive + si], 1
    jne near nextDrop
    
    mov ax, 0xB800
    mov es, ax
    xor ax, ax
    mov al, [dropOldY + si]
    mov bx, 160
    mul bx
    mov di, ax
    xor ax, ax
    mov al, [dropX + si]
    shl ax, 1
    add di, ax
    mov word [es:di], 0x0020
    
    inc byte [dropY + si]
    mov al, [dropY + si]
    mov [dropOldY + si], al
    
    cmp al, 23       
    jne checkBottom
    
    mov bl, [dropX + si]
    mov bh, [paddleX]
    cmp bl, bh
    jl checkBottom 
    
    mov al, bh
    add al, [paddleSize]
    cmp bl, al
    jg checkBottom 
    
    mov byte [dropActive + si], 0
    
    cmp byte [dropType + si], 1
    je caughtBomb
    
    add word [score], 20
    jmp nextDrop
    
caughtBomb:
    dec byte [lives]
    cmp byte [lives], 0
    je triggerGameOver
    jmp nextDrop

triggerGameOver:
    mov byte [gameOver], 1
    jmp nextDrop

checkBottom:
    cmp byte [dropY + si], 24
    jl drawDrop
    mov byte [dropActive + si], 0 
    jmp nextDrop
    
drawDrop:
    xor ax, ax
    mov al, [dropY + si]
    mov bx, 160
    mul bx
    mov di, ax
    xor ax, ax
    mov al, [dropX + si]
    shl ax, 1
    add di, ax
    
    cmp byte [dropType + si], 1
    je drawBadChar
    
    mov ah, 0x0A    
    mov al, '$'
    jmp putDrop
    
drawBadChar:
    mov ah, 0x04
    mov al, '#'
    
putDrop:
    mov [es:di], ax

nextDrop:
    inc si
    cmp si, 5
    jl dropLoop
    ret

checkWin:
    mov si, bricks
    mov cx, 48      
    cmp byte [level], 2
    jne countLoop
    mov cx, 60      
countLoop:
    lodsb
    cmp al, 0
    jg stillPlaying
    loop countLoop
    
    cmp byte [level], 1
    je nextLevel
    
    mov byte [gameOver], 2 
    ret

nextLevel:
    mov byte [level], 2
    call initGame
    call clearScreen
    call drawBorder
    mov cx, 0xFFFF
delayLvl: loop delayLvl
    ret

stillPlaying:
    ret

moveBall:
    mov al, [ballDX]
    add [ballX], al
    
    mov al, [ballDY]
    add [ballY], al
    
    cmp byte [ballX], 2
    jg checkRightWall
    mov byte [ballX], 2
    
    cmp byte [ballDX], 0
    jg checkY                
    neg byte [ballDX]        
    jmp checkY

checkRightWall:
    cmp byte [ballX], 77
    jl checkY
    mov byte [ballX], 77
    
    cmp byte [ballDX], 0
    jl checkY                
    neg byte [ballDX]        

checkY:
    cmp byte [ballY], 2
    jle reverseDY
    cmp byte [ballY], 23
    je checkPaddle
    cmp byte [ballY], 24
    jge lostLife
    jmp checkBricks
    
reverseDY:
    neg byte [ballDY]
    jmp checkBricks
    
checkPaddle:
    mov al, [ballX]
    mov bl, [paddleX]
    cmp al, bl
    jl near checkBricks        
    mov cl, bl
    add cl, [paddleSize]
    cmp al, cl
    jge checkBricks       

    call sndPaddle

    mov byte [ballDY], -1 

    sub al, bl            

    cmp al, 2
    jl bounceSharpLeft

    cmp al, 4
    jl bounceLeft

    cmp al, 6
    jl bounceStraight

    cmp al, 8
    jl bounceRight

    jmp bounceSharpRight

bounceSharpLeft:
    mov byte [ballDX], -2
    jmp checkBricks

bounceLeft:
    mov byte [ballDX], -1
    jmp checkBricks

bounceStraight:
    mov byte [ballDX], 0
    jmp checkBricks

bounceRight:
    mov byte [ballDX], 1
    jmp checkBricks
    
bounceSharpRight:
    mov byte [ballDX], 2
    jmp checkBricks
    
lostLife:
    call sndDie

    dec byte [lives]
    mov byte [ballX], 40
    mov byte [ballY], 18
    mov byte [ballDX], 1
    mov byte [ballDY], -1
    mov byte [oldBallX], 40
    mov byte [oldBallY], 18
    cmp byte [lives], 0
    jne checkBricks
    mov byte [gameOver], 1
    
checkBricks:
    mov al, [ballY]
    cmp al, 3
    jl doneBricks
    cmp al, 9        
    jge doneBricks
    
    mov al, [ballY]
    sub al, 3
    mov bl, al       

    cmp byte [level], 1
    je checkLvl1Row
    
    cmp bl, 5
    jae doneBricks
    jmp checkCol
    
checkLvl1Row:
    cmp bl, 4
    jae doneBricks
    
checkCol:
    mov al, [ballX]
    sub al, 10
    js doneBricks
    xor ah, ah
    mov cl, 5
    div cl
    mov bh, al      

    cmp bh, 12
    jae doneBricks

    mov al, bl
    xor ah, ah
    mov cl, 12
    mul cl
    xor ah, ah
    add al, bh
    xor ah, ah
    mov bx, ax      

    mov si, bricks
    add si, bx
    cmp byte [si], 0
    je doneBricks

    dec byte [si]
    
    call sndBrick
    
    jnz brickBounce

    push bx
    call eraseBrick
    pop bx
    add word [score], 10
    
    cmp byte [level], 2
    jne brickBounce
    
    mov si, level2DropMap
    add si, bx      
    lodsb           
    
    cmp al, 0        
    je brickBounce
    
    dec al           
    call spawnDrop

brickBounce:
    neg byte [ballDY]

doneBricks:
    ret

drawStatus:
    mov ax, 0xB800
    mov es, ax
    mov di, 164
    mov si, scoreText
    mov ah, 0x0F
    call printString
    mov ax, [score]
    call printNumber
    
    mov di, 280
    mov si, livesText
    mov ah, 0x0F
    call printString
    xor ax, ax
    mov al, [lives]
    call printNumber
    
    mov di, 380
    mov si, levelText
    mov ah, 0x0E
    call printString
    xor ax, ax
    mov al, [level]
    call printNumber
    ret

printNumber:
    push ax
    push bx
    push cx
    push dx
    mov bx, 10
    xor cx, cx
convertLoop:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz convertLoop
    mov ax, 0xB800
    mov es, ax
printDigits:
    pop ax
    add al, '0'
    mov ah, 0x0F
    stosw
    loop printDigits
    pop dx
    pop cx
    pop bx
    pop ax
    ret

playGame:
    call initGame
    call clearScreen
    call drawBorder
    
    mov ax, 0
    int 0x33
    mov ax, 2
    int 0x33
    
gameLoop:
    call updatePaddleMouse
    call drawBricks
    call drawStatus
    call drawPaddle
    call drawBall
    
    cmp byte [gameOver], 0
    jne endGameCheck
    call checkWin
    
endGameCheck:
    cmp byte [gameOver], 0
    jne showEndScreen
    
    inc byte [ballTimer]
    mov al, [ballThreshold]
    cmp byte [ballTimer], al
    jl checkDropTimer
    
    mov byte [ballTimer], 0
    call moveBall

checkDropTimer:
    inc byte [dropTimer]
    cmp byte [dropTimer], 16 
    jl skipPhysics
    mov byte [dropTimer], 0
    call updateDrops

skipPhysics:
    mov cx, 0x2000   
delayLoop:
    loop delayLoop
    
    mov ah, 0x01
    int 0x16
    jz gameLoop
    
    mov ah, 0x00
    int 0x16
    cmp ah, 0x01
    je exitGame
    jmp gameLoop

showEndScreen:
    call clearScreen
    mov di, 1600
    cmp byte [gameOver], 1
    je showGameOverMsg
    mov si, winText
    mov ah, 0x0E
    call printString
    jmp showFinalScore
showGameOverMsg:
    mov si, gameOverText
    mov ah, 0x0C
    call printString
showFinalScore:
    mov ax, [score]
    call printNumber
    mov di, 1920
    mov si, pressEsc
    mov ah, 0x0F
    call printString
waitEndKey:
    mov ah, 0x00
    int 0x16
    cmp ah, 0x01
    jne waitEndKey
exitGame:
    ret

start:
    mov ah, 0x01
    mov ch, 0x20
    mov cl, 0x00
    int 0x10
    mov byte [currentScreen], 0
    mov byte [level], 1 
    
mainLoop:
    cmp byte [currentScreen], 0
    je showMenu
    cmp byte [currentScreen], 1
    je showInst
    cmp byte [currentScreen], 2
    je startGame
showMenu:
    call drawMainMenu
    mov ah, 0x00
    int 0x16
    cmp al, '1'
    je selectGame
    cmp al, '2'
    je selectInst
    cmp al, '3'
    je exitProgram
    jmp mainLoop
selectGame:
    mov byte [currentScreen], 2
    jmp mainLoop
selectInst:
    mov byte [currentScreen], 1
    jmp mainLoop
showInst:
    call drawInstructions
waitInstKey:
    mov ah, 0x00
    int 0x16
    cmp ah, 0x01
    je backToMenu
    jmp waitInstKey
backToMenu:
    mov byte [currentScreen], 0
    jmp mainLoop
startGame:
    mov byte [level], 1 
    call playGame
    mov byte [currentScreen], 0
    jmp mainLoop
exitProgram:
    mov ax, 0x4C00
    int 0x21