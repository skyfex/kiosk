# See USB-CCID: http://www.usb.org/developers/devclass_docs/DWG_Smart-Card_CCID_Rev110.pdf
# ACR122 API: http://www.acs.com.hk/action.downloads.php?page=manual&id=419&type=API-ACR122U-2.02.pdf
import
  strutils,
  libusb,
  os,
  unsigned

type
  CCIDMessageKind*{.size: 1.} = enum            
    RDR_to_PC_NotifySlotChange              = 0x50  # Interrupt 
    RDR_to_PC_HardwareError                 = 0x51  # Interrupt

    PC_to_RDR_SetParameters                 = 0x61  
    PC_to_RDR_IccPowerOn                    = 0x62
    PC_to_RDR_IccPowerOff                   = 0x63
    PC_to_RDR_GetSlotStatus                 = 0x65
    PC_to_RDR_Secure                        = 0x69
    PC_to_RDR_T0APDU                        = 0x6A
    PC_to_RDR_Escape                        = 0x6B
    PC_to_RDR_GetParameters                 = 0x6C
    PC_to_RDR_ResetParameters               = 0x6D
    PC_to_RDR_IccClock                      = 0x6E
    PC_to_RDR_XfrBlock                      = 0x6F
    PC_to_RDR_Mechanical                    = 0x71
    PC_to_RDR_Abort                         = 0x72
    PC_to_RDR_SetDataRateAndClockFrequency  = 0x73

    RDR_to_PC_DataBlock                     = 0x80
    RDR_to_PC_SlotStatus                    = 0x81
    RDR_to_PC_Parameters                    = 0x82
    RDR_to_PC_Escape                        = 0x83
    RDR_to_PC_DataRateAndClockFrequency     = 0x84

  CCIDErrorKind*{.size: 1.} = enum
    ERROR_CMD_NOT_SUPPORTED          = 0x00 # Command not supported
    ERROR_CMD_SLOT_BUSY              = 0xE0 # A second command was sent to a slot which was ERROR_already processing a command.
    ERROR_PIN_CANCELLED              = 0xEF #
    ERROR_PIN_TIMEOUT                = 0xF0 #
    ERROR_BUSY_WITH_AUTO_SEQUENCE    = 0xF2 # Automatic Sequence Ongoing
    ERROR_DEACTIVATED_PROTOCOL       = 0xF3 #
    ERROR_PROCEDURE_BYTE_CONFLICT    = 0xF4 #
    ERROR_ICC_CLASS_NOT_SUPPORTED    = 0xF5 #
    ERROR_ICC_PROTOCOL_NOT_SUPPORTED = 0xF6 #
    ERROR_BAD_ATR_TCK                = 0xF7 #
    ERROR_BAD_ATR_TS                 = 0xF8 #
    ERROR_HW_ERROR                   = 0xFB # An all inclusive hardware error occurred
    ERROR_XFR_OVERRUN                = 0xFC # Overrun error while talking to the ICC
    ERROR_XFR_PARITY_ERROR           = 0xFD # Parity error while talking to the ICC
    ERROR_ICC_MUTE                   = 0xFE # CCID timed out while talking to the ICC
    ERROR_CMD_ABORTED                = 0xFF # Host aborted the current activity

  # TODO: The fields are actually uint
  TPC_to_RDR_IccPowerOn {.packed.} = object
    kind: CCIDMessageKind
    length: int32
    slot: int8
    seqNum: int8
    powerSelect: int8 # Voltage that is applied to the ICC 
                      # 0x00 – Automatic Voltage Selection 
                      # 0x01 – 5.0 volts 
                      # 0x02 – 3.0 volts 
                      # 0x03 – 1.8 volts
    abRFU: array[2, char] # Reserved for Future Use

  TPC_to_RDR_IccPowerOff {.packed.} = object
    kind: CCIDMessageKind
    length: int32
    slot: int8
    seqNum: int8
    abRFU: array[3, char]  # Reserved for Future Use

  TPC_to_RDR_GetSlotStatus {.packed.} = object
    kind: CCIDMessageKind
    length: int32
    slot: int8
    seqNum: int8
    abRFU: array[3, char] # Reserved for Future Use

  TPC_to_RDR_XfrBlock{.packed.}[T: static[int]] = object
    kind: CCIDMessageKind
    length: int32
    slot: int8
    seqNum: int8
    bwi: int8         # Used to extend the CCIDs Block Waiting Timeout 
                      # for this current transfer. Timeout after
                      # "this number multiplied by the Block Waiting Time"
    levelParam: int16 # Use changes depending on the exchange level reported 
                      # by the class descriptor in dwFeatures field: 
    abData: array[T, int8]

  # -- Read Commands --
  # TODO: Status field is bit-field

  TRDR_to_PC_DataBlock {.packed.} = object
    kind: CCIDMessageKind
    length: int32
    slot: int8
    seqNum: int8
    status: int8
    error: CCIDErrorKind
    chainParam: int8
    abData: array[32, int8]

  TRDR_to_PC_SlotStatus {.packed.} = object
    kind: CCIDMessageKind
    length: int32
    slot: int8
    seqNum: int8
    status: int8
    error: CCIDErrorKind
    clockStatus: int8

type
  NFCID* = int32

  TCardReaderAction* = enum
    crBlinkOK,
    crBlinkUnknown,
    crBlinkBad,
    crTerminate

  TCardReaderMsgKind* = enum
    crCardConnected,
    crCardDisconnected

  TCardReaderMsg* = object
    kind*: TCardReaderMsgKind
    cardID*: NFCID


proc `$`*(id: NFCID): string =
  toHex(id, 8)

# Global variables
var
  crTX*: TChannel[TCardReaderMsg]
  crRX*: TChannel[TCardReaderAction]
  crThread: TThread[void]

proc cardReader() {.thread.} =
  var
    vid = 0x072F'u16
    pid = 0x2200'u16
    intf = 0
    ep_intr = endpointIn(1)
    ep_bulk_i = endpointIn(2)
    ep_bulk_o = endpointOut(2)

  var
    lastCardID: NFCID


  var ctx = libusb.init()
  var handle = ctx.openWithVidPid(vid, pid)

  var lastSeqNum: int8 = 1

  proc getSlotStatus(slot: int8): int8 = 
    lastSeqNum += 1
    var msg = TPC_to_RDR_GetSlotStatus(
                kind: PC_to_RDR_GetSlotStatus,
                length: 0,
                slot: slot,
                seqNum: lastSeqNum
              )  
    var txCnt = bulkTransfer(handle, ep_bulk_o, msg, 2000)
    var res: TRDR_to_PC_SlotStatus
    var rxCnt = bulkTransfer(handle, ep_bulk_i, res, 2000)
    if res.kind == RDR_to_PC_SlotStatus:
      echo "Slot status: " & $res.status
    else:
      raise newException(E_Base, "Unexpected response " & $res.kind)

    result = 0

  proc powerOn(slot: int8) =
    lastSeqNum += 1
    var msg = TPC_to_RDR_IccPowerOn(
                kind: PC_to_RDR_IccPowerOn,
                length: 0,
                slot: slot,
                seqNum: lastSeqNum,
                powerSelect: 0x00  
              )  
    var txCnt = bulkTransfer(handle, ep_bulk_o, msg, 2000)
    var res: TRDR_to_PC_DataBlock
    var rxCnt = bulkTransfer(handle, ep_bulk_i, res, 2000)
    if res.kind == RDR_to_PC_DataBlock:
      echo res.status
    else:
      raise newException(E_Base, "Unexpected response " & $res.kind)

  proc readCardID(slot: int8): NFCID = 
    # ACR122U Specific Protocol!

    var data = [0xFF'i8, 0xCA'i8, 0x00'i8, 0x00'i8, 0x04'i8]
    lastSeqNum += 1
    var msg = TPC_to_RDR_XfrBlock[5]( 
                kind: PC_to_RDR_XfrBlock,
                length: cast[int32](sizeof(data)),
                slot: slot,
                seqNum: lastSeqNum,
                bwi: 0,
                levelParam: 0,
                abData: data
              )
    var txCnt = bulkTransfer(handle, ep_bulk_o, msg, 2000)
    var res: TRDR_to_PC_DataBlock
    var rxCnt = bulkTransfer(handle, ep_bulk_i, res, 2000)
   
    if res.kind != RDR_to_PC_DataBlock:
      raise newException(E_Base, "Unexpected response " & $res.kind)

    var
      sw1 = cast[uint8](res.abData[res.length-2])
      sw2 = cast[uint8](res.abData[res.length-1])

    if sw1==0x63 and sw2==0x00:
      raise newException(E_Base, "readCardID operation failed")    
    elif sw1==0x6A and sw2==0x81:
      raise newException(E_Base, "Function not supported")        
    elif not (sw1==0x90 and sw2==0x00):
      raise newException(E_Base, "readCardID operation not successful")        

    if res.length != 6:
      raise newException(E_Base, "Unexpected length " & $res.length)

    result = cast[ptr NFCID](res.abData[0].addr)[]


  proc readFirmwareVersion() = 
    # ACR122U Specific Protocol!

    var data = [0xFF'i8, 0x00'i8, 0x48'i8, 0x00'i8, 0x00'i8]
    lastSeqNum += 1
    var msg = TPC_to_RDR_XfrBlock[5]( 
                kind: PC_to_RDR_XfrBlock,
                length: cast[int32](sizeof(data)),
                slot: 0,
                seqNum: lastSeqNum,
                bwi: 0,
                levelParam: 0,
                abData: data
              )
    var txCnt = bulkTransfer(handle, ep_bulk_o, msg, 2000)
    var res: TRDR_to_PC_DataBlock
    var rxCnt = bulkTransfer(handle, ep_bulk_i, res, 2000)
    if res.length != 10:
        raise newException(E_Base, "Unexpected length " & $res.length)
   
    if res.kind != RDR_to_PC_DataBlock:
      raise newException(E_Base, "Unexpected response " & $res.kind)

    for x in res.abData:
      echo toHex(x, 2)

  proc setBuzzer(on: bool) =
    let pollBuzzStatus = if on: 0xFF'i8
                         else:  0x00'i8
    var data = [0xFF'i8, 0x00'i8, 0x52'i8, pollBuzzStatus, 0x00'i8]
    lastSeqNum += 1
    var msg = TPC_to_RDR_XfrBlock[5]( 
                kind: PC_to_RDR_XfrBlock,
                length: cast[int32](sizeof(data)),
                slot: 0,
                seqNum: lastSeqNum,
                bwi: 0,
                levelParam: 0,
                abData: data
              )
    var txCnt = bulkTransfer(handle, ep_bulk_o, msg, 2000)
    var res: TRDR_to_PC_DataBlock
    var rxCnt = bulkTransfer(handle, ep_bulk_i, res, 2000)
    if res.length != 2:
        raise newException(E_Base, "Unexpected length " & $res.length)
    if res.kind != RDR_to_PC_DataBlock:
      raise newException(E_Base, "Unexpected response " & $res.kind)
    var
      sw1 = cast[uint8](res.abData[res.length-2])
      sw2 = cast[uint8](res.abData[res.length-1])
    if not (sw1==0x90 and sw2==0x00):
      raise newException(E_Base, "setBuzzer operation not successful")        

  proc blinkLED(stateCtrl, t1, t2, rep, buzz: int8) =

    var data = [0xFF'i8, 0x00'i8, 0x40'i8,
                stateCtrl, 0x04'i8,
                t1, t2, rep, buzz]
    lastSeqNum += 1
    var msg = TPC_to_RDR_XfrBlock[9]( 
                kind: PC_to_RDR_XfrBlock,
                length: cast[int32](sizeof(data)),
                slot: 0,
                seqNum: lastSeqNum,
                bwi: 0,
                levelParam: 0,
                abData: data
              )
    var txCnt = bulkTransfer(handle, ep_bulk_o, msg, 2000)
    var res: TRDR_to_PC_DataBlock
    var rxCnt = bulkTransfer(handle, ep_bulk_i, res, 2000)
    if res.length != 2:
        raise newException(E_Base, "Unexpected length " & $res.length)
    if res.kind != RDR_to_PC_DataBlock:
      raise newException(E_Base, "Unexpected response " & $res.kind)
    var
      sw1 = cast[uint8](res.abData[res.length-2])
      sw2 = cast[uint8](res.abData[res.length-1])
    if not (sw1==0x90):
      raise newException(E_Base, "setLED operation not successful")        


  echo handle.manufacturerName &" "& handle.productName
  handle.claimInterface(0)

  # readFirmwareVersion()
  powerOn(0)
  setBuzzer(false)

  while true:

    if crRX.peek > 0:
      var action = crRX.recv
      case action
      of crBlinkOK:
        blinkLED(0b10101010'i8, 1'i8, 1'i8, 8'i8, 0'i8)
      of crBlinkUnknown:
        blinkLED(0b11111111'i8, 1'i8, 1'i8, 8'i8, 0'i8)
      of crBlinkBad:
        blinkLED(0b01010101'i8, 1'i8, 1'i8, 8'i8, 0'i8)
      of crTerminate:
        break

    var intrData: tuple[typ: CCIDMessageKind, data: int8]
    var readCnt: int
    try:
      readCnt = handle.interruptTransfer(ep_intr, intrData)
    except ELibUSBTimeout:
      continue

    case intrData.typ
    of RDRtoPC_NotifySlotChange:
      # echo "NotifySlotChange: " & $intrData.data
      if (intrData.data and 0b0001) == 1:
        try:
          lastCardID = readCardID(0)
          var msg = TCardReaderMsg(kind: crCardConnected, 
                                   cardID: lastCardID)
          crTX.send(msg)
          blinkLED(0b10101010'i8, 1'i8, 1'i8, 8'i8, 0'i8)
        except E_Base:
          let msg = getCurrentExceptionMsg()
          echo "Read Card ID failed"
          echo msg


      else:  
        if lastCardID != 0:
          # setLED()
          var msg = TCardReaderMsg(kind: crCardDisconnected, 
                                   cardID: lastCardID)
          crTX.send(msg)

    of RDRtoPC_HardwareError:
      raise newException(E_Base, "Hardware Error interrupt")

    else:
      raise newException(E_Base, "Unknown interrupt type")

  # TODO: finally    
  handle.close()
  ctx.exit()

proc startCardReader*() =
  open(crRX)
  open(crTX)
  createThread[void](crThread, cardReader)

proc stopCardReader*() =
  crRX.send(crTerminate) 
  joinThread(crThread)
  close(crRX)
  close(crTX)

# GC_fullCollect()

