       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCENGN.
       AUTHOR. LEGACY-TEAM.
      *********************************************************
      * CALCULATOR COMPUTATION ENGINE - BACKEND              *
      * Description: Core calculation logic                  *
      * Performs arithmetic operations                       *
      *********************************************************
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.
       
       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-TEMP-RESULT          PIC S9(10)V99.
       01  WS-DIVISION-REMAINDER   PIC 9(10)V99.
       
       01  WS-VALIDATION-FLAGS.
           05 WS-VALID-OPERATOR    PIC X VALUE 'N'.
           05 WS-DIVISION-BY-ZERO  PIC X VALUE 'N'.
           05 WS-OVERFLOW          PIC X VALUE 'N'.
       
       01  WS-MAX-VALUE            PIC 9(10)V99 VALUE 9999999999.99.
       01  WS-MIN-VALUE            PIC S9(10)V99 VALUE -9999999999.99.
       
       LINKAGE SECTION.
       01  LS-CALC-PARAMS.
           05 LS-OPERAND1          PIC 9(8)V99.
           05 LS-OPERATOR          PIC X.
           05 LS-OPERAND2          PIC 9(8)V99.
           05 LS-RESULT            PIC S9(10)V99.
           05 LS-ERROR-CODE        PIC XX.
       
       PROCEDURE DIVISION USING LS-CALC-PARAMS.
       MAIN-LOGIC.
           PERFORM INITIALIZE-ENGINE
           PERFORM VALIDATE-OPERATOR
           IF WS-VALID-OPERATOR = 'Y'
              PERFORM EXECUTE-CALCULATION
              PERFORM CHECK-OVERFLOW
              PERFORM SET-RESULT
           ELSE
              MOVE '02' TO LS-ERROR-CODE
           END-IF
           GOBACK.
       
       INITIALIZE-ENGINE.
           MOVE ZEROS TO LS-RESULT
           MOVE '00' TO LS-ERROR-CODE
           MOVE 'N' TO WS-VALID-OPERATOR
           MOVE 'N' TO WS-DIVISION-BY-ZERO
           MOVE 'N' TO WS-OVERFLOW.
       
       VALIDATE-OPERATOR.
           EVALUATE LS-OPERATOR
              WHEN '+'
                 MOVE 'Y' TO WS-VALID-OPERATOR
              WHEN '-'
                 MOVE 'Y' TO WS-VALID-OPERATOR
              WHEN '*'
                 MOVE 'Y' TO WS-VALID-OPERATOR
              WHEN '/'
                 MOVE 'Y' TO WS-VALID-OPERATOR
                 IF LS-OPERAND2 = ZERO
                    MOVE 'Y' TO WS-DIVISION-BY-ZERO
                    MOVE '01' TO LS-ERROR-CODE
                 END-IF
              WHEN OTHER
                 MOVE 'N' TO WS-VALID-OPERATOR
           END-EVALUATE.
       
       EXECUTE-CALCULATION.
           IF WS-DIVISION-BY-ZERO = 'N'
              EVALUATE LS-OPERATOR
                 WHEN '+'
                    PERFORM PERFORM-ADDITION
                 WHEN '-'
                    PERFORM PERFORM-SUBTRACTION
                 WHEN '*'
                    PERFORM PERFORM-MULTIPLICATION
                 WHEN '/'
                    PERFORM PERFORM-DIVISION
              END-EVALUATE
           END-IF.
       
       PERFORM-ADDITION.
           COMPUTE WS-TEMP-RESULT = LS-OPERAND1 + LS-OPERAND2
           ON SIZE ERROR
              MOVE 'Y' TO WS-OVERFLOW
              MOVE '03' TO LS-ERROR-CODE
           END-COMPUTE.
       
       PERFORM-SUBTRACTION.
           COMPUTE WS-TEMP-RESULT = LS-OPERAND1 - LS-OPERAND2
           ON SIZE ERROR
              MOVE 'Y' TO WS-OVERFLOW
              MOVE '03' TO LS-ERROR-CODE
           END-COMPUTE.
       
       PERFORM-MULTIPLICATION.
           COMPUTE WS-TEMP-RESULT = LS-OPERAND1 * LS-OPERAND2
           ON SIZE ERROR
              MOVE 'Y' TO WS-OVERFLOW
              MOVE '03' TO LS-ERROR-CODE
           END-COMPUTE.
       
       PERFORM-DIVISION.
           IF LS-OPERAND2 NOT = ZERO
              COMPUTE WS-TEMP-RESULT = LS-OPERAND1 / LS-OPERAND2
              ON SIZE ERROR
                 MOVE 'Y' TO WS-OVERFLOW
                 MOVE '03' TO LS-ERROR-CODE
              END-COMPUTE
           END-IF.
       
       CHECK-OVERFLOW.
           IF WS-OVERFLOW = 'N'
              IF WS-TEMP-RESULT > WS-MAX-VALUE OR
                 WS-TEMP-RESULT < WS-MIN-VALUE
                 MOVE 'Y' TO WS-OVERFLOW
                 MOVE '03' TO LS-ERROR-CODE
              END-IF
           END-IF.
       
       SET-RESULT.
           IF LS-ERROR-CODE = '00'
              MOVE WS-TEMP-RESULT TO LS-RESULT
           ELSE
              MOVE ZEROS TO LS-RESULT
           END-IF.
       
       END PROGRAM CALCENGN.
