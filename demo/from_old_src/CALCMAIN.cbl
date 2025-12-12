       IDENTIFICATION DIVISION.
       PROGRAM-ID. CALCMAIN.
       AUTHOR. LEGACY-TEAM.
      *********************************************************
      * CALCULATOR MAIN PROGRAM - FRONTEND                   *
      * Description: Terminal-based calculator interface     *
      * Handles user input and displays results              *
      *********************************************************
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-370.
       OBJECT-COMPUTER. IBM-370.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT CALC-LOG ASSIGN TO CALCLOG
               ORGANIZATION IS LINE SEQUENTIAL
               ACCESS MODE IS SEQUENTIAL
               FILE STATUS IS WS-FILE-STATUS.
       
       DATA DIVISION.
       FILE SECTION.
       FD  CALC-LOG.
       01  CALC-LOG-RECORD.
           05 LOG-TIMESTAMP        PIC X(20).
           05 LOG-OPERATION        PIC X(50).
           05 LOG-RESULT           PIC X(20).
       
       WORKING-STORAGE SECTION.
       01  WS-FILE-STATUS          PIC XX.
       
       01  WS-SCREEN-HEADER.
           05 FILLER               PIC X(40) VALUE
              '======================================'.
           05 FILLER               PIC X(40) VALUE
              '======================================'.
       
       01  WS-TITLE.
           05 FILLER               PIC X(30) VALUE SPACES.
           05 FILLER               PIC X(20) VALUE 
              'LEGACY CALCULATOR'.
           05 FILLER               PIC X(30) VALUE SPACES.
       
       01  WS-USER-INPUT.
           05 WS-OPERAND1          PIC 9(8)V99.
           05 WS-OPERATOR          PIC X.
           05 WS-OPERAND2          PIC 9(8)V99.
       
       01  WS-RESULT               PIC S9(10)V99.
       01  WS-RESULT-DISPLAY       PIC -9(10).99.
       
       01  WS-MENU.
           05 FILLER               PIC X(50) VALUE
              'Operations: + (Add) - (Subtract) * (Multiply)'.
           05 FILLER               PIC X(50) VALUE
              '            / (Divide) Q (Quit)'.
       
       01  WS-PROMPTS.
           05 WS-PROMPT-OP1        PIC X(30) VALUE
              'Enter first number:    '.
           05 WS-PROMPT-OPER       PIC X(30) VALUE
              'Enter operator (+,-,*,/): '.
           05 WS-PROMPT-OP2        PIC X(30) VALUE
              'Enter second number:   '.
       
       01  WS-ERROR-MSG            PIC X(50).
       01  WS-CONTINUE-FLAG        PIC X VALUE 'Y'.
       01  WS-HISTORY-COUNT        PIC 99 VALUE 0.
       
       01  WS-HISTORY-TABLE.
           05 WS-HISTORY OCCURS 10 TIMES.
              10 WS-HIST-OPERATION PIC X(30).
              10 WS-HIST-RESULT    PIC X(15).
       
       LINKAGE SECTION.
       01  LS-CALC-PARAMS.
           05 LS-OPERAND1          PIC 9(8)V99.
           05 LS-OPERATOR          PIC X.
           05 LS-OPERAND2          PIC 9(8)V99.
           05 LS-RESULT            PIC S9(10)V99.
           05 LS-ERROR-CODE        PIC XX.
       
       PROCEDURE DIVISION.
       MAIN-LOGIC.
           PERFORM INITIALIZE-PROGRAM
           PERFORM DISPLAY-HEADER
           PERFORM PROCESS-CALCULATIONS 
               UNTIL WS-CONTINUE-FLAG = 'N'
           PERFORM DISPLAY-HISTORY
           PERFORM CLEANUP-PROGRAM
           STOP RUN.
       
       INITIALIZE-PROGRAM.
           OPEN OUTPUT CALC-LOG
           IF WS-FILE-STATUS NOT = '00'
              DISPLAY 'WARNING: Cannot open log file'
           END-IF
           MOVE ZEROS TO WS-HISTORY-COUNT.
       
       DISPLAY-HEADER.
           DISPLAY ' '.
           DISPLAY WS-SCREEN-HEADER.
           DISPLAY WS-TITLE.
           DISPLAY WS-SCREEN-HEADER.
           DISPLAY ' '.
           DISPLAY WS-MENU.
           DISPLAY ' '.
       
       PROCESS-CALCULATIONS.
           PERFORM GET-USER-INPUT
           IF WS-OPERATOR = 'Q' OR WS-OPERATOR = 'q'
              MOVE 'N' TO WS-CONTINUE-FLAG
           ELSE
              PERFORM CALL-CALCULATION-ENGINE
              PERFORM DISPLAY-RESULT
              PERFORM SAVE-TO-HISTORY
              PERFORM LOG-OPERATION
           END-IF.
       
       GET-USER-INPUT.
           DISPLAY ' '.
           DISPLAY WS-PROMPT-OP1 WITH NO ADVANCING
           ACCEPT WS-OPERAND1.
           
           DISPLAY WS-PROMPT-OPER WITH NO ADVANCING
           ACCEPT WS-OPERATOR.
           
           IF WS-OPERATOR NOT = 'Q' AND WS-OPERATOR NOT = 'q'
              DISPLAY WS-PROMPT-OP2 WITH NO ADVANCING
              ACCEPT WS-OPERAND2
           END-IF.
       
       CALL-CALCULATION-ENGINE.
           MOVE WS-OPERAND1 TO LS-OPERAND1
           MOVE WS-OPERATOR TO LS-OPERATOR
           MOVE WS-OPERAND2 TO LS-OPERAND2
           
           CALL 'CALCENGN' USING LS-CALC-PARAMS
           
           MOVE LS-RESULT TO WS-RESULT
           
           IF LS-ERROR-CODE NOT = '00'
              EVALUATE LS-ERROR-CODE
                 WHEN '01'
                    MOVE 'ERROR: Division by zero' TO WS-ERROR-MSG
                 WHEN '02'
                    MOVE 'ERROR: Invalid operator' TO WS-ERROR-MSG
                 WHEN '03'
                    MOVE 'ERROR: Overflow' TO WS-ERROR-MSG
                 WHEN OTHER
                    MOVE 'ERROR: Unknown error' TO WS-ERROR-MSG
              END-EVALUATE
              DISPLAY WS-ERROR-MSG
           END-IF.
       
       DISPLAY-RESULT.
           IF LS-ERROR-CODE = '00'
              MOVE WS-RESULT TO WS-RESULT-DISPLAY
              DISPLAY ' '
              DISPLAY '=========================================='
              DISPLAY 'RESULT: ' WS-RESULT-DISPLAY
              DISPLAY '=========================================='
              DISPLAY ' '
           END-IF.
       
       SAVE-TO-HISTORY.
           IF LS-ERROR-CODE = '00' AND WS-HISTORY-COUNT < 10
              ADD 1 TO WS-HISTORY-COUNT
              STRING WS-OPERAND1 DELIMITED BY SIZE
                     ' ' DELIMITED BY SIZE
                     WS-OPERATOR DELIMITED BY SIZE
                     ' ' DELIMITED BY SIZE
                     WS-OPERAND2 DELIMITED BY SIZE
                     INTO WS-HIST-OPERATION(WS-HISTORY-COUNT)
              MOVE WS-RESULT-DISPLAY TO 
                   WS-HIST-RESULT(WS-HISTORY-COUNT)
           END-IF.
       
       LOG-OPERATION.
           IF WS-FILE-STATUS = '00' AND LS-ERROR-CODE = '00'
              ACCEPT LOG-TIMESTAMP FROM DATE YYYYMMDD
              STRING WS-OPERAND1 DELIMITED BY SIZE
                     ' ' DELIMITED BY SIZE
                     WS-OPERATOR DELIMITED BY SIZE
                     ' ' DELIMITED BY SIZE
                     WS-OPERAND2 DELIMITED BY SIZE
                     INTO LOG-OPERATION
              MOVE WS-RESULT-DISPLAY TO LOG-RESULT
              WRITE CALC-LOG-RECORD
           END-IF.
       
       DISPLAY-HISTORY.
           IF WS-HISTORY-COUNT > 0
              DISPLAY ' '
              DISPLAY '=========================================='
              DISPLAY 'CALCULATION HISTORY:'
              DISPLAY '=========================================='
              PERFORM VARYING WS-HISTORY-COUNT FROM 1 BY 1
                 UNTIL WS-HISTORY-COUNT > 10
                 IF WS-HIST-OPERATION(WS-HISTORY-COUNT) NOT = SPACES
                    DISPLAY WS-HIST-OPERATION(WS-HISTORY-COUNT) 
                            ' = ' 
                            WS-HIST-RESULT(WS-HISTORY-COUNT)
                 END-IF
              END-PERFORM
              DISPLAY '=========================================='
           END-IF.
       
       CLEANUP-PROGRAM.
           CLOSE CALC-LOG
           DISPLAY ' '
           DISPLAY 'Thank you for using Legacy Calculator!'
           DISPLAY ' '.
       
       END PROGRAM CALCMAIN.
