import wiringpi, os

type
  ButtonEventKind* = enum
    beDown,
    beUp

  ButtonEvent* = object
    kind*: ButtonEventKind
    button*: int

var
  buttonsChan*: TChannel[ButtonEvent]
  buttonsThread: TThread[void]

const
  ledIds = [5,6,7,10,11]

proc buttonsHandler*() {.thread.} =
    var states = [1,1,1,1,1]
    var ledStates = [100,100,100,100,100]
    while true:
        for i in 0..4:
            if ledStates[i] > 0:
                ledStates[i] -= 7
            if ledStates[i] < 0:
                ledStates[i] = 0
            softPwmWrite(ledIds[i], ledStates[i])
        for i in 0..4:
            var st = digitalRead(i)
            if st == 0:
                ledStates[i] = 100 
            if st != states[i]:
                var evt: ButtonEvent
                if st==1:
                    evt = ButtonEvent(kind: beUp, button: 4-i)
                else:
                    evt = ButtonEvent(kind: beDown, button: 4-i)
                buttonsChan.send(evt)
            states[i] = st
        sleep(50)


proc initButtons*() =
    wiringPiSetup()
    for i in 0..4:
        pinMode(i, ord(pmInput))
        pullUpDnControl(i, ord(pudUp))   
    for i in ledIds:
        pinMode(i, ord(pmOutput))
        softPwmCreate(i, 0)
    open(buttonsChan)   
    createThread[void](buttonsThread, buttonsHandler)

