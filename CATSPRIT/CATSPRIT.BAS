OPTION EXPLICIT
DEFINT A-Z

CONST HEADER_SIZE = &H300

DECLARE FUNCTION GetByteCount (HeightWidth)
DECLARE FUNCTION GetSprite$ (Path$, Offset, HeightWidth)
DECLARE FUNCTION ParseHex (Hexadecimal$)
DECLARE SUB DrawSprite (Sprite$, xy, HeightWidth)
DECLARE SUB ShowSprites ()

 SCREEN 1
 CLS

 ShowSprites

SUB DrawSprite (Sprite$, xy, HeightWidth)
DIM Columns
DIM Index
DIM Rows

 Columns = HeightWidth AND &HFF
 Rows = HeightWidth \ &H100

 IF Columns > 0 AND Rows > 0 THEN
  DEF SEG = &HB800
  DO
   FOR Index = &H1 TO Columns
    POKE xy, ASC(LEFT$(Sprite$, &H1))
    Sprite$ = MID$(Sprite$, &H2)
    POKE xy + &H1, ASC(LEFT$(Sprite$, &H1))
    Sprite$ = MID$(Sprite$, &H2)
    xy = xy + &H2
   NEXT Index
 
   xy = xy - (Columns * &H2) XOR &H2000
   IF (xy AND &H2000) = &H0 THEN
    xy = xy + &H50
   END IF

   Rows = Rows - &H1
  LOOP UNTIL Rows = &H0
 END IF
END SUB

FUNCTION GetByteCount (HeightWidth)
DIM Columns
DIM Rows

 Columns = HeightWidth AND &HFF
 Rows = HeightWidth \ &H100

 GetByteCount = (Columns * Rows * &H2)
END FUNCTION

FUNCTION GetSprite$ (Path$, Offset, HeightWidth)
DIM FileH
DIM Sprite$

 IF DIR$(Path$) = "" THEN
  PRINT "ERROR: Can't find "; Path$
 ELSE
  FileH = FREEFILE
  OPEN Path$ FOR BINARY LOCK READ WRITE AS FileH
   SEEK #FileH, &H1 + HEADER_SIZE + Offset
   Sprite$ = INPUT$(GetByteCount(HeightWidth), FileH)
  CLOSE FileH
 END IF

 GetSprite$ = Sprite$
END FUNCTION

FUNCTION ParseHex (Hexadecimal$)
 ParseHex = VAL("&H" + MID$(Hexadecimal$, 3))
END FUNCTION

SUB ShowSprites ()
DIM FileH
DIM HeightWidth
DIM HeightWidthHex$
DIM KeyStroke$
DIM Offset
DIM OffsetHex$
DIM SpriteName$

 FileH = FREEFILE
 OPEN "SPRITES.TXT" FOR INPUT LOCK READ AS FileH
  DO UNTIL EOF(FileH) OR KeyStroke$ = CHR$(27)
   INPUT #FileH, SpriteName$, OffsetHex$, HeightWidthHex$
   Offset = ParseHex(OffsetHex$)
   HeightWidth = ParseHex(HeightWidthHex$)

   LOCATE 3, 3: PRINT SpriteName$; " - "; OffsetHex$
   
   DrawSprite GetSprite$("CAT.EXE", Offset, HeightWidth), 1205, HeightWidth

   KeyStroke$ = INPUT$(1)

   CLS
  LOOP
 CLOSE FileH
END SUB

