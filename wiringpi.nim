import os

type
  EPinMode* = enum
    pmInput = 0,
    pmOutput = 1,
    pmPWM = 2,
    pmClock = 3

  EPullUpDown* = enum
    pudOff = 0
    pudDown = 1,
    pudUp = 2,

proc wiringPiSetup*() {.cdecl, importc: "wiringPiSetup".}

proc pinMode*(pin: int, mode: int) {.cdecl, importc: "pinMode".}
proc digitalWrite*(pin: int, value: int) {.cdecl, importc: "digitalWrite".}
proc digitalWriteByte*(value: int) {.cdecl, importc: "digitalWriteByte".}
proc pwmWrite*(pin, value: int) {.cdecl, importc: "pwmWrite".}
proc digitalRead*(pin: int): int {.cdecl, importc: "digitalRead".}
proc pullUpDnControl*(pin, pud: int) {.cdecl, importc: "pullUpDnControl".}

proc softPwmCreate*(pin, initialValue, pwmRange: int=100) {.cdecl, importc: "softPwmCreate".}
proc softPwmWrite*(pin, value: int) {.cdecl, importc: "softPwmWrite".}



