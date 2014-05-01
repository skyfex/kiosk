when defined(macosx): 
  const 
    lib = "libusb.dylib"
else:
  const
    lib = "libusb.so"

type
  # TODO: Precise definitons
  ssize_t = int 
  cint = int
  cuchar = uint8

  libusb_class_code*{.size: 1.} = enum
    LIBUSB_CLASS_PER_INTERFACE       = 0,   # In the context of a libusb_device_descriptor "device descriptor",
                                            # this bDeviceClass value indicates that each interface specifies its
                                            # own class information and all interfaces operate independently.
    LIBUSB_CLASS_AUDIO               = 1,
    LIBUSB_CLASS_COMM                = 2,
    LIBUSB_CLASS_HID                 = 3,
    LIBUSB_CLASS_PHYSICAL            = 5,
    LIBUSB_CLASS_IMAGE               = 6,
    LIBUSB_CLASS_PRINTER             = 7,
    LIBUSB_CLASS_MASS_STORAGE        = 8,
    LIBUSB_CLASS_HUB                 = 9,
    LIBUSB_CLASS_DATA                = 10,
    LIBUSB_CLASS_SMART_CARD          = 0x0b,
    LIBUSB_CLASS_CONTENT_SECURITY    = 0x0d,
    LIBUSB_CLASS_VIDEO               = 0x0e,
    LIBUSB_CLASS_PERSONAL_HEALTHCARE = 0x0f,
    LIBUSB_CLASS_DIAGNOSTIC_DEVICE   = 0xdc,
    LIBUSB_CLASS_WIRELESS            = 0xe0,
    LIBUSB_CLASS_APPLICATION         = 0xfe,
    LIBUSB_CLASS_VENDOR_SPEC         = 0xff

  libusb_descriptor_type*{.size: 1.} = enum     
    LIBUSB_DT_DEVICE                = 0x01, # Device descriptor. See libusb_device_descriptor.
    LIBUSB_DT_CONFIG                = 0x02, # Configuration descriptor. See libusb_config_descriptor.
    LIBUSB_DT_STRING                = 0x03, # String descriptor
    LIBUSB_DT_INTERFACE             = 0x04, # Interface descriptor. See libusb_interface_descriptor.
    LIBUSB_DT_ENDPOINT              = 0x05, # Endpoint descriptor. See libusb_endpoint_descriptor.
    LIBUSB_DT_BOS                   = 0x0f, # BOS descriptor
    LIBUSB_DT_DEVICE_CAPABILITY     = 0x10, # Device Capability descriptor
    LIBUSB_DT_HID                   = 0x21, # HID descriptor
    LIBUSB_DT_REPORT                = 0x22, # HID report descriptor
    LIBUSB_DT_PHYSICAL              = 0x23, # Physical descriptor
    LIBUSB_DT_HUB                   = 0x29, # Hub descriptor
    LIBUSB_DT_SUPERSPEED_HUB        = 0x2a  # SuperSpeed Hub descriptor
    LIBUSB_DT_SS_ENDPOINT_COMPANION = 0x30

  libusb_endpoint_direction*{.size: 1.} = enum
    LIBUSB_ENDPOINT_OUT = 0x00  # Host-to-device
    LIBUSB_ENDPOINT_IN = 0x80,  # Device-to-host

  libusb_transfer_type*{.size: 1.} = enum
    LIBUSB_TRANSFER_TYPE_CONTROL     = 0, # Control endpoint
    LIBUSB_TRANSFER_TYPE_ISOCHRONOUS = 1, # Isochronous endpoint
    LIBUSB_TRANSFER_TYPE_BULK        = 2, # Bulk endpoint
    LIBUSB_TRANSFER_TYPE_INTERRUPT   = 3  # Interrupt endpoint

  libusb_standard_request*{.size: 4.} = enum                 
    LIBUSB_REQUEST_GET_STATUS        = 0x00000000, # Request status of the specific recipient
    LIBUSB_REQUEST_CLEAR_FEATURE     = 0x00000001, # Clear or disable a specific feature
                                                   # 0x02 is reserved
    LIBUSB_REQUEST_SET_FEATURE       = 0x00000003, # Set or enable a specific feature
                                                   # 0x04 is reserved
    LIBUSB_REQUEST_SET_ADDRESS       = 0x00000005, # Set device address for all future accesses
    LIBUSB_REQUEST_GET_DESCRIPTOR    = 0x00000006, # Get the specified descriptor
    LIBUSB_REQUEST_SET_DESCRIPTOR    = 0x00000007, # Used to update existing descriptors or add new descriptors
    LIBUSB_REQUEST_GET_CONFIGURATION = 0x00000008, # Get the current device configuration value
    LIBUSB_REQUEST_SET_CONFIGURATION = 0x00000009, # Set device configuration
    LIBUSB_REQUEST_GET_INTERFACE     = 0x0000000A, # Return the selected alternate setting for the specified interface
    LIBUSB_REQUEST_SET_INTERFACE     = 0x0000000B, # Select an alternate interface for the specified interface
    LIBUSB_REQUEST_SYNCH_FRAME       = 0x0000000C, # Set then report an endpoint's synchronization frame
    LIBUSB_REQUEST_SET_SEL           = 0x00000030, # Sets both the U1 and U2 Exit Latency                                                  
    LIBUSB_SET_ISOCH_DELAY           = 0x00000031  # Delay from the time a host transmits a packet to the time it is
                                                   # received by the device.


  libusb_endpoint_descriptor* {.pure, final.} = object 
    bLength*: uint8            # Size of this descriptor (in bytes) 
    bDescriptorType*: uint8    # Will be DT_ENDPOINT LIBUSB_DT_ENDPOINT in this context
    bEndpointAddress*: uint8   # The address of the endpoint described by this descriptor. Bits 0:3 are 
                               #   the endpoint number. Bits 4:6 are reserved. Bit 7 indicates direction, 
                               #   see libusb_endpoint_direction.  
    bmAttributes*: uint8       # Attributes which apply to the endpoint when it is configured using
                               #   the bConfigurationValue. Bits 0:1 determine the transfer type and
                               #   correspond to libusb_transfer_type. Bits 2:3 are only used for
                               #   isochronous endpoints and correspond to libusb_iso_sync_type.
                               #   Bits 4:5 are also only used for isochronous endpoints and correspond to
                               #   libusb_iso_usage_type. Bits 6:7 are reserved.
    wMaxPacketSize*: uint16    # Maximum packet size this endpoint is capable of sending/receiving. 
    bInterval*: uint8          # Interval for polling endpoint for data transfers. 
    bRefresh*: uint8           # For audio devices only: the rate at which synchronization feedback    
                               #  is provided. 
    bSynchAddress*: uint8      # For audio devices only: the address if the synch endpoint 
    extra*: ptr cuchar         # Extra descriptors. If libusb encounters unknown endpoint descriptors,
                               #   it will store them here, should you wish to parse them. 
    extra_length*: cint        # Length of the extra descriptors, in bytes. 


  libusb_interface_descriptor* {.pure, final.} = object 
    bLength*: uint8            # Size of this descriptor (in bytes) 
    bDescriptorType*: uint8    # Will be DT_INTERFACE LIBUSB_DT_INTERFACE in this context
    bInterfaceNumber*: uint8   # Number of this interface  
    bAlternateSetting*: uint8  # Value used to select this alternate setting for this interface  
    bNumEndpoints*: uint8      # Number of endpoints used by this interface (excluding the control
                               #  endpoint). 
    bInterfaceClass*: libusb_class_code    # USB-IF class code for this interface. See libusb_class_code. 
    bInterfaceSubClass*: libusb_class_code # USB-IF subclass code for this interface, qualified by the
                                           #  bInterfaceClass value 
    bInterfaceProtocol*: uint8 # USB-IF protocol code for this interface, qualified by the
                               #  bInterfaceClass and bInterfaceSubClass values 
    iInterface*: uint8         # Index of string descriptor describing this interface                         
    endpoint*: ptr libusb_endpoint_descriptor # Array of endpoint descriptors. This length of this array is determined
                                              #  by the bNumEndpoints field. 
    extra*: ptr cuchar    # Extra descriptors. If libusb encounters unknown interface descriptors,
                          #  it will store them here, should you wish to parse them.   
    extra_length*: cint   # Length of the extra descriptors, in bytes. 

  libusb_interface* {.pure, final.} = object 
    altsetting*: ptr libusb_interface_descriptor # Array of interface descriptors. The length of this array is determined
                                                 #  by the num_altsetting field. 
    num_altsetting*: cint # The number of alternate settings that belong to this interface 

  libusb_device_descriptor* {.pure, final.} = object 
    bLength*: uint8            # Size of this descriptor (in bytes)                           
    bDescriptorType*: uint8    # Will be DT_DEVICE LIBUSB_DT_DEVICE in this context. 
    bcdUSB*: uint16            # USB specification release number in binary-coded decimal. A value of
                               #   0x0200 indicates USB 2.0, 0x0110 indicates USB 1.1, etc. 
    bDeviceClass*: libusb_class_code   # USB-IF class code for the device. See libusb_class_code  
    bDeviceSubClass*: libusb_class_code# USB-IF subclass code for the device, qualified by the bDeviceClass
                                       #   value 
    bDeviceProtocol*: uint8    # USB-IF protocol code for the device, qualified by the bDeviceClass and
                               #   bDeviceSubClass values 
    bMaxPacketSize0*: uint8    # Maximum packet size for endpoint 0 
    idVendor*: uint16          # USB-IF vendor ID     
    idProduct*: uint16         # USB-IF product ID 
    bcdDevice*: uint16         # Device release number in binary-coded decimal 
    iManufacturer*: uint8      # Index of string descriptor describing manufacturer 
    iProduct*: uint8           # Index of string descriptor describing product 
    iSerialNumber*: uint8      # Index of string descriptor containing device serial number 
    bNumConfigurations*: uint8 # Number of possible configurations 

  libusb_config_descriptor* {.pure, final.} = object 
    bLength*: uint8             # Size of this descriptor (in bytes) 
    bDescriptorType*: uint8     # Will be DT_CONFIG LIBUSB_DT_CONFIG in this context
    wTotalLength*: uint16       # Total length of data returned for this configuration 
    bNumInterfaces*: uint8      # Number of interfaces supported by this configuration 
    bConfigurationValue*: uint8 # Identifier value for this configuration 
    iConfiguration*: uint8      # Index of string descriptor describing this configuration 
    bmAttributes*: uint8        # Configuration characteristics 
    MaxPower*: uint8            # Maximum power consumption of the USB device from this bus in this
                                # configuration when the device is fully opreation. Expressed in units   
                                # of 2 mA.    
    intf*: ptr libusb_interface # Array of interfaces supported by this configuration. The length of
                                # this array is determined by the bNumInterfaces field. 
    extra*: ptr cuchar          # Extra descriptors. If libusb encounters unknown configuration
                                #   descriptors, it will store them here, should you wish to parse them. 
    extra_length*: cint         # Length of the extra descriptors, in bytes. 

  libusb_context* {.pure, final.} = object 
  libusb_device* {.pure, final.} = object 
  libusb_device_handle* {.pure, final.} = object 
  libusb_hotplug_callback* {.pure, final.} = object 

  libusb_version* {.pure, final.} = object 
    major*: uint16        # Library major version.      
    minor*: uint16        # Library minor version. 
    micro*: uint16        # Library micro version. 
    nano*: uint16         # Library nano version. 
    rc*: cstring          # Library release candidate suffix string, e.g. "-rc4". 
    describe*: cstring    # For ABI compatibility only. 


  # TODO: Not sure about size here
  libusb_error*{.size: 4.}  = enum
    LIBUSB_ERROR_OTHER         = -99  # Other error
    LIBUSB_ERROR_NOT_SUPPORTED = -12, # Operation not supported or unimplemented on this platform
    LIBUSB_ERROR_NO_MEM        = -11, # Insufficient memory
    LIBUSB_ERROR_INTERRUPTED   = -10, # System call interrupted (perhaps due to signal)
    LIBUSB_ERROR_PIPE          =  -9,  # Pipe error
    LIBUSB_ERROR_OVERFLOW      =  -8,  # Overflow
    LIBUSB_ERROR_TIMEOUT       =  -7,  # Operation timed out
    LIBUSB_ERROR_BUSY          =  -6,  # Resource busy
    LIBUSB_ERROR_NOT_FOUND     =  -5,  # Entity not found
    LIBUSB_ERROR_NO_DEVICE     =  -4,  # No such device (it may have been disconnected)
    LIBUSB_ERROR_ACCESS        =  -3,  # Access denied (insufficient permissions)
    LIBUSB_ERROR_INVALID_PARAM =  -2,  # Invalid parameter
    LIBUSB_ERROR_IO            =  -1,  # Input/output error
    LIBUSB_SUCCESS             =   0,   # Success (no error)

# LIBUSB_SUCCESS             = 0,    # Input/output error
# LIBUSB_ERROR_OTHER         = 0xFFFFFF9D   # Other error
# LIBUSB_ERROR_NOT_SUPPORTED = 0xFFFFFFF4,                                       
# LIBUSB_ERROR_NO_MEM        = 0xFFFFFFF5,  # Operation not supported or unimplemented on this platform
# LIBUSB_ERROR_INTERRUPTED   = 0xFFFFFFF6,  # Insufficient memory
# LIBUSB_ERROR_PIPE          = 0xFFFFFFF7,  # System call interrupted (perhaps due to signal)
# LIBUSB_ERROR_OVERFLOW      = 0xFFFFFFF8,  # Pipe error
# LIBUSB_ERROR_TIMEOUT       = 0xFFFFFFF9,  # Overflow
# LIBUSB_ERROR_BUSY          = 0xFFFFFFFA,  # Operation timed out
# LIBUSB_ERROR_NOT_FOUND     = 0xFFFFFFFB,  # Resource busy
# LIBUSB_ERROR_NO_DEVICE     = 0xFFFFFFFC,  # Entity not found
# LIBUSB_ERROR_ACCESS        = 0xFFFFFFFD,  # No such device (it may have been disconnected)
# LIBUSB_ERROR_INVALID_PARAM = 0xFFFFFFFE,  # Access denied (insufficient permissions)
# LIBUSB_ERROR_IO            = 0xFFFFFFFF,  # Invalid parameter
# LIBUSB_SUCCESS             =   0,    # Input/output error
# LIBUSB_ERROR_IO            =  -1,  # Invalid parameter
# LIBUSB_ERROR_INVALID_PARAM =  -2,  # Access denied (insufficient permissions)
# LIBUSB_ERROR_ACCESS        =  -3,  # No such device (it may have been disconnected)
# LIBUSB_ERROR_NO_DEVICE     =  -4,  # Entity not found
# LIBUSB_ERROR_NOT_FOUND     =  -5,  # Resource busy
# LIBUSB_ERROR_BUSY          =  -6,  # Operation timed out
# LIBUSB_ERROR_TIMEOUT       =  -7,  # Overflow
# LIBUSB_ERROR_OVERFLOW      =  -8,  # Pipe error
# LIBUSB_ERROR_PIPE          =  -9,  # System call interrupted (perhaps due to signal)
# LIBUSB_ERROR_INTERRUPTED   = -10,  # Insufficient memory
# LIBUSB_ERROR_NO_MEM        = -11,  # Operation not supported or unimplemented on this platform
# LIBUSB_ERROR_NOT_SUPPORTED = -12,                                       
# LIBUSB_ERROR_OTHER         = -99   # Other error


proc libusb_init*(ctx: ptr ptr libusb_context): libusb_error  {.cdecl, dynlib: lib, importc: "libusb_init".}
proc libusb_exit*(ctx: ptr libusb_context)           {.cdecl, dynlib: lib, importc: "libusb_exit".}

proc libusb_get_device_list*(ctx: ptr libusb_context; 
                             list: ptr ptr ptr libusb_device): ssize_t           {.cdecl, dynlib: lib, importc: "libusb_get_device_list".}
proc libusb_free_device_list*(list: ptr ptr libusb_device; 
                              unref_devices: cint)  {.cdecl, dynlib: lib, importc: "libusb_free_device_list".}
proc libusb_ref_device*(dev: ptr libusb_device): ptr libusb_device  {.cdecl, dynlib: lib, importc: "libusb_ref_device".}
proc libusb_unref_device*(dev: ptr libusb_device)                   {.cdecl, dynlib: lib, importc: "libusb_unref_device".}
proc libusb_get_configuration*(dev: ptr libusb_device_handle; 
                               config: ptr cint): cint {.cdecl, dynlib: lib, importc: "libusb_get_configuration".}
proc libusb_get_device_descriptor*(dev: ptr libusb_device; 
                                   desc: ptr libusb_device_descriptor): libusb_error {.cdecl, dynlib: lib, importc: "libusb_get_device_descriptor".}
proc libusb_get_active_config_descriptor*(dev: ptr libusb_device; 
                                          config: ptr ptr libusb_config_descriptor): cint {.cdecl, dynlib: lib, importc: "libusb_get_active_config_descriptor".}
proc libusb_get_config_descriptor*(dev: ptr libusb_device; 
                                   config_index: uint8; 
                                   config: ptr ptr libusb_config_descriptor): cint {.cdecl, dynlib: lib, importc: "libusb_get_config_descriptor".}
proc libusb_free_config_descriptor*(config: ptr libusb_config_descriptor)  {.cdecl, dynlib: lib, importc: "libusb_free_config_descriptor".}


proc libusb_open*(dev: ptr libusb_device; handle: ptr ptr libusb_device_handle): libusb_error {.cdecl, dynlib: lib, importc: "libusb_open".}
proc libusb_close*(dev_handle: ptr libusb_device_handle) {.cdecl, dynlib: lib, importc: "libusb_close".}
proc libusb_get_device*(dev_handle: ptr libusb_device_handle): ptr libusb_device {.cdecl, dynlib: lib, importc: "libusb_get_device".}

proc libusb_set_configuration*(dev: ptr libusb_device_handle; 
                               configuration: cint): cint {.cdecl, dynlib: lib, importc: "libusb_set_configuration".}
proc libusb_claim_interface*(dev: ptr libusb_device_handle; 
                             interface_number: cint): libusb_error {.cdecl, dynlib: lib, importc: "libusb_claim_interface".}
proc libusb_release_interface*(dev: ptr libusb_device_handle; 
                               interface_number: cint): cint {.cdecl, dynlib: lib, importc: "libusb_release_interface".}
proc libusb_open_device_with_vid_pid*(ctx: ptr libusb_context; 
                                      vendor_id: uint16; 
                                      product_id: uint16): ptr libusb_device_handle {.cdecl, dynlib: lib, importc: "libusb_open_device_with_vid_pid".}


# sync I/O 
proc libusb_control_transfer*(dev_handle: ptr libusb_device_handle; 
                              request_type: uint8; bRequest: uint8; 
                              wValue: uint16; wIndex: uint16; 
                              data: ptr cuchar; wLength: uint16; 
                              timeout: cuint): libusb_error {.cdecl, dynlib: lib, importc: "libusb_control_transfer".}
proc libusb_bulk_transfer*(dev_handle: ptr libusb_device_handle; 
                           endpoint: cuchar; data: ptr cuchar; length: cint; 
                           actual_length: ptr cint; timeout: cuint): libusb_error {.cdecl, dynlib: lib, importc: "libusb_bulk_transfer".}
proc libusb_interrupt_transfer*(dev_handle: ptr libusb_device_handle; 
                                endpoint: cuchar; data: ptr cuchar; 
                                length: cint; actual_length: ptr cint; 
                                timeout: cuint): libusb_error {.cdecl, dynlib: lib, importc: "libusb_interrupt_transfer".}



proc libusb_get_string_descriptor*(dev: ptr libusb_device_handle; 
                                   desc_index: uint8; langid: uint16; 
                                   data: ptr cuchar; length: cint): libusb_error {.inline.} = 
  return libusb_control_transfer(dev, 
                                 ord(LIBUSB_ENDPOINT_IN), 
                                 ord(LIBUSB_REQUEST_GET_DESCRIPTOR), 
                                 (uint16)((ord(LIBUSB_DT_STRING) shl 8) or int(desc_index)), 
                                 langid, 
                                 data, 
                                 cast[uint16](length), 
                                 1000)

proc libusb_get_string_descriptor_ascii*(dev: ptr libusb_device_handle; 
    desc_index: uint8; data: ptr cuchar; length: cint): cint {.cdecl, dynlib: lib, importc: "libusb_get_string_descriptor_ascii".}


# -- Nimrod-friendly interface --
type
  ELibUSB* = object of E_Base
  ELibUSBTimeout* = object of E_LibUSB

  ClassCode* = libusb_class_code
  DescriptorType* = libusb_descriptor_type
  EndpointDirection* = libusb_endpoint_direction
  TransferType* = libusb_transfer_type
  #TEndpoint = uint8

  Context* = ref ptr libusb_context
  Device* = ref ptr libusb_device

  DeviceHandle* = ref ptr libusb_device_handle

  DeviceDescriptor* {.pure, final.} = object 
    bLength*: uint8            # Size of this descriptor (in bytes)                           
    bDescriptorType*: DescriptorType    # Will be DT_DEVICE LIBUSB_DT_DEVICE in this context. 
    bcdUSB*: uint16            # USB specification release number in binary-coded decimal. A value of
                               #   0x0200 indicates USB 2.0, 0x0110 indicates USB 1.1, etc. 
    bDeviceClass*: ClassCode   # USB-IF class code for the device. See ClassCode  
    bDeviceSubClass*: ClassCode# USB-IF subclass code for the device, qualified by the bDeviceClass
                               #   value 
    bDeviceProtocol*: uint8    # USB-IF protocol code for the device, qualified by the bDeviceClass and
                               #   bDeviceSubClass values 
    bMaxPacketSize0*: uint8    # Maximum packet size for endpoint 0 
    idVendor*: uint16          # USB-IF vendor ID     
    idProduct*: uint16         # USB-IF product ID 
    bcdDevice*: uint16         # Device release number in binary-coded decimal 
    iManufacturer*: uint8      # Index of string descriptor describing manufacturer 
    iProduct*: uint8           # Index of string descriptor describing product 
    iSerialNumber*: uint8      # Index of string descriptor containing device serial number 
    bNumConfigurations*: uint8 # Number of possible configurations 

  TConfigDescriptor* {.pure, final.} = object 
    bLength: uint8              # Size of this descriptor (in bytes) 
    bDescriptorType*: DescriptorType     # Will be DT_CONFIG LIBUSB_DT_CONFIG in this context
    wTotalLength: uint16        # Total length of data returned for this configuration 
    bNumInterfaces*: uint8      # Number of interfaces supported by this configuration 
    bConfigurationValue*: uint8 # Identifier value for this configuration 
    iConfiguration*: uint8      # Index of string descriptor describing this configuration 
    bmAttributes*: uint8        # Configuration characteristics 
    MaxPower*: uint8            # Maximum power consumption of the USB device from this bus in this
                                # configuration when the device is fully opreation. Expressed in units   
                                # of 2 mA.    
    intf: ptr libusb_interface  # Array of interfaces supported by this configuration. The length of
                                # this array is determined by the bNumInterfaces field. 
    extra: ptr cuchar           # Extra descriptors. If libusb encounters unknown configuration
                                #   descriptors, it will store them here, should you wish to parse them. 
    extra_length: cint          # Length of the extra descriptors, in bytes. 

  ConfigDescriptor = ref ptr TConfigDescriptor

  EndpointDescriptor* {.pure, final.} = object 
    bLength*: uint8            # Size of this descriptor (in bytes) 
    bDescriptorType*: uint8    # Will be DT_ENDPOINT LIBUSB_DT_ENDPOINT in this context
    bEndpointAddress*: uint8   # The address of the endpoint described by this descriptor. Bits 0:3 are 
                               #   the endpoint number. Bits 4:6 are reserved. Bit 7 indicates direction, 
                               #   see libusb_endpoint_direction.  
    bmAttributes*: uint8       # Attributes which apply to the endpoint when it is configured using
                               #   the bConfigurationValue. Bits 0:1 determine the transfer type and
                               #   correspond to libusb_transfer_type. Bits 2:3 are only used for
                               #   isochronous endpoints and correspond to libusb_iso_sync_type.
                               #   Bits 4:5 are also only used for isochronous endpoints and correspond to
                               #   libusb_iso_usage_type. Bits 6:7 are reserved.
    wMaxPacketSize*: uint16    # Maximum packet size this endpoint is capable of sending/receiving. 
    bInterval*: uint8          # Interval for polling endpoint for data transfers. 
    bRefresh*: uint8           # For audio devices only: the rate at which synchronization feedback    
                               #  is provided. 
    bSynchAddress*: uint8      # For audio devices only: the address if the synch endpoint 
    extra: ptr cuchar          # Extra descriptors. If libusb encounters unknown endpoint descriptors,
                               #   it will store them here, should you wish to parse them. 
    extra_length: cint         # Length of the extra descriptors, in bytes. 


  TInterfaceDescriptor* {.pure, final.} = object 
    bLength*: uint8            # Size of this descriptor (in bytes) 
    bDescriptorType*: uint8    # Will be DT_INTERFACE LIBUSB_DT_INTERFACE in this context
    bInterfaceNumber*: uint8   # Number of this interface  
    bAlternateSetting*: uint8  # Value used to select this alternate setting for this interface  
    bNumEndpoints*: uint8      # Number of endpoints used by this interface (excluding the control
                               #  endpoint). 
    bInterfaceClass*: ClassCode    # USB-IF class code for this interface. See libusb_class_code. 
    bInterfaceSubClass*: ClassCode # USB-IF subclass code for this interface, qualified by the
                                   #  bInterfaceClass value 
    bInterfaceProtocol*: uint8 # USB-IF protocol code for this interface, qualified by the
                               #  bInterfaceClass and bInterfaceSubClass values 
    iInterface*: uint8         # Index of string descriptor describing this interface                         
    endpoint: ptr libusb_endpoint_descriptor  # Array of endpoint descriptors. This length of this array is determined
                                              #  by the bNumEndpoints field. 
    extra: ptr cuchar    # Extra descriptors. If libusb encounters unknown interface descriptors,
                         #  it will store them here, should you wish to parse them.   
    extra_length: cint   # Length of the extra descriptors, in bytes. 

  InterfaceDescriptor = ptr TInterfaceDescriptor

  Intf = ptr libusb_interface

proc exit*(ctx: Context) =
  if ctx[] == nil:
    return
  libusb_exit(ctx[])
  ctx[] = nil
  # TODO: When accessing context, check if it's nil
  # maybe.. unless we support the "default context"

proc init*: Context =
  new(result, exit)
  var r = libusb_init(addr(result[]))
  if r != LIBUSB_SUCCESS:
    # TODO
    raise newException(ELibUSB, "libusb_init failed") 

proc freeDevice(d: Device) = 
  libusb_unref_device(d[])

proc deviceList*(ctx: Context): seq[Device] = 
  result = newSeq[Device]()
  var pointer: ptr ptr libusb_device
  var size = libusb_get_device_list(ctx[], addr(pointer))
  # TODO: Replace improvized pointer arithmetic
  var devlist_ptr = cast[int](pointer) 
  for i in 0..size-1:
    var d: Device
    new(d, freeDevice)
    var tmp = cast[ptr ptr libusb_device](devlist_ptr + i*sizeof(int))
    d[] = tmp[]
    result.add(d)
  libusb_free_device_list(pointer, 0)

proc `$`*(dev: Device): string =
  "USB Device"

proc descriptor*(dev: Device): DeviceDescriptor =
  var r = libusb_get_device_descriptor(dev[], cast[ptr libusb_device_descriptor](addr(result)))
  if r != LIBUSB_SUCCESS:
    # TODO
    raise newException(ELibUSB, "libusb_get_device_descriptor failed") 

proc freeConfigDescriptor(desc: ConfigDescriptor) =
  libusb_free_config_descriptor(cast[ptr libusb_config_descriptor](desc[]))

proc activeConfigDescriptor*(dev: Device): ConfigDescriptor =
  new(result, freeConfigDescriptor)
  var r = libusb_get_active_config_descriptor(dev[], cast[ptr ptr libusb_config_descriptor](addr(result[])))
  if r != 0:
    # TODO
    raise newException(ELibUSB, "libusb_get_active_config_descriptor failed") 

iterator interfaces*(cfgDesc: ConfigDescriptor): Intf = 
  # TODO: Replace improvized pointer arithmetic
  var intflist_ptr = cast[int](cfgDesc.intf) 
  for i in 0..cast[int](cfgDesc.bNumInterfaces)-1:
    var tmp = cast[ptr libusb_interface](intflist_ptr + i*sizeof(libusb_interface))
    yield tmp

proc first*(anIntf: Intf): InterfaceDescriptor =
  if anIntf.num_altsetting==0:
    raise newException(ELibUSB, "Zero alternate settings for this interface!")
  result = cast[InterfaceDescriptor](anIntf.altsetting)

template numAltsetting*(anIntf: Intf): int = 
  result = anIntf.num_altsetting


#TODO: iterator altSettings

proc open*(dev: Device): DeviceHandle =
  new(result)
  var r = libusb_open(dev[], addr(result[]))
  if r != LIBUSB_SUCCESS:
    # TODO
    raise newException(ELibUSB, "libusb_open failed") 

proc close*(handle: DeviceHandle) =
  libusb_close(handle[])
  handle[] = nil # TODO: Check for nil in other procs

proc getDevice*(handle: DeviceHandle): Device =
  new(result, freeDevice) 
  result[] = libusb_get_device(handle[])
  discard libusb_ref_device(result[])


proc openWithVidPid*(ctx: Context, vendorId: uint16, productId: uint16): DeviceHandle =
  new(result)
  var r = libusb_open_device_with_vid_pid(ctx[], vendorId, productId)
  if r==nil:
    raise newException(ELibUSB, "libusb_open_device_with_vid_pid failed") 
  result[] = r

proc claimInterface*(handle: DeviceHandle, intf_num: int) = 
  var r = libusb_claim_interface(handle[], intf_num)
  if r != LIBUSB_SUCCESS:
    raise newException(ELibUSB, "libusb_claim_interface failed: " & $r) 

proc productName*(handle: DeviceHandle): string =
  var buf: array[0..255, char]
  var desc = handle.getDevice.descriptor 
  var byteCnt = libusb_get_string_descriptor_ascii(handle[], desc.iProduct, cast[ptr cuchar](addr(buf)), 255)
  result = $buf

proc manufacturerName*(handle: DeviceHandle): string =
  var buf: array[0..255, char]
  var desc = handle.getDevice.descriptor 
  var byteCnt = libusb_get_string_descriptor_ascii(handle[], desc.iManufacturer, cast[ptr cuchar](addr(buf)), 255)
  result = $buf

template endpointIn*(endpoint_idx: uint8): uint8 =
  cast[uint8](cast[int](ord(LIBUSB_ENDPOINT_IN)) or cast[int](endpoint_idx))

template endpointOut*(endpoint_idx: uint8): uint8 =
  cast[uint8](cast[int](ord(LIBUSB_ENDPOINT_OUT)) or cast[int](endpoint_idx))


proc interruptTransfer*(handle: DeviceHandle; 
                        endpoint: uint8;
                        data: ptr char;
                        length: int;
                        timeout: int = 0): int =
  var r = libusb_interrupt_transfer(handle[], cast[cuchar](endpoint), 
                                    cast[ptr cuchar](data), 
                                    cast[cint](length), 
                                    cast[ptr cint](addr(result)), 
                                    cast[cuint](timeout))
  if r != LIBUSB_SUCCESS:
    case (r)
    of LIBUSB_ERROR_TIMEOUT:
      raise newException(ELibUSBTimeout, "Interrupt transfer timeout")
    else:
      raise newException(ELibUSB, "libusb_interrupt_transfer failed: " & $r) 


template interruptTransfer*(handle: DeviceHandle; 
                            endpoint: uint8;
                            data: var openarray[char];
                            timeout: int = 0): int =
  interruptTransfer(handle[], endpoint ,
                    cast[ptr cuchar](data), 
                    1+data.high-data.low, 
                    timeout)


template interruptTransfer*[T](handle: DeviceHandle; 
                               endpoint: uint8;
                               data: var T,
                               timeout: int = 0): int =
  interruptTransfer(handle, endpoint ,
                    cast[ptr char](addr(data)), 
                    sizeOf(data), 
                    timeout)

proc bulkTransfer*(handle: DeviceHandle; 
                   endpoint: uint8;
                   data: ptr char;
                   length: int;
                   timeout: int = 0): int =
  var r = libusb_bulk_transfer(handle[], cast[cuchar](endpoint), 
                                cast[ptr cuchar](data), 
                                cast[cint](length), 
                                cast[ptr cint](addr(result)), 
                                cast[cuint](timeout))
  if r != LIBUSB_SUCCESS:
    case (r)
    of LIBUSB_ERROR_TIMEOUT:
      raise newException(ELibUSBTimeout, "Bulk transfer timeout")
    else:
      raise newException(ELibUSB, "libusb_bulk_transfer failed: " & $r) 

template bulkTransfer*(handle: DeviceHandle; 
                        endpoint: uint8;
                        data: var openarray[char];
                        timeout: int = 0): int =
  bulkTransfer(handle[], endpoint ,
                cast[ptr cuchar](data), 
                1+data.high-data.low, 
                timeout)


template bulkTransfer*[T](handle: DeviceHandle; 
                           endpoint: uint8;
                           data: var T,
                           timeout: int = 0): int =
  bulkTransfer(handle, endpoint ,
                cast[ptr char](addr(data)), 
                sizeOf(data), 
                timeout)


