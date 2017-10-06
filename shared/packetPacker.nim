import
    valuePacker,
    typetraits

type 
    RequestType* = enum    
        ADD_NEW_CLASS,                      # Add new class
        ADD_NEW_INSTANCE,                   # Add new instance
        ADD_NEW_FIELD,                      # Add new class field        
        GET_ALL_CLASSES,                    # Get iterate all classes
        GET_ALL_INSTANCES,                  # Get iterate all instances
        UPDATE_CLASS,                       # Update class data
        UPDATE_INSTANCE,                    # Update instance data
        UPDATE_FIELD,                       # Update field data
        REMOVE_CLASS,                       # Remove class
        REMOVE_INSTANCE,                    # Remove instance
        REMOVE_FIELD,                       # Remove field
        GET_FIELD_VALUE,                    # Get field value        
        GET_LIST_FIELD_COUNT                # Get list field count        
        GET_LIST_FIELD_VALUE                # Get list field value        
        SET_FIELD_VALUE,                    # Set field value        
        ADD_LIST_FIELD_VALUE,               # Add list field value        
        SET_LIST_FIELD_VALUE,               # Set list field value        
        REMOVE_LIST_FIELD_VALUE,            # Remove list field value        
        CLEAR_LIST_FIELD_VALUE              # Clear list field value        

    ResponseType* = enum
        INTERNAL_ERROR_RESPONSE,
        ADD_NEW_CLASS_RESPONSE,
        ADD_NEW_INSTANCE_RESPONSE,
        ADD_NEW_FIELD_RESPONSE,
        GET_ALL_CLASSES_RESPONSE,
        GET_ALL_INSTANCES_RESPONSE

    ResponseCode* = enum
        OK_CODE,
        ERROR_CODE

#############################################################################################
# Process errors

type ErrorType* = enum
    INTERNAL_ERROR,
    CLASS_NOT_FOUND,                        # Class not found in storage    
    INSTANCE_NOT_FOUND,                     # Instance not found in storage
    FIELD_NOT_FOUND,                        # Field not found in storage
    VALUE_NOT_FOUND                         # Value not found in storage

#############################################################################################
# Process errors text
const CLASS_NOT_FOUND_TEXT* = "Class not found"

import
    streamProducer,
    valuePacker

type
    # Base packet
    RequestPacket* = ref object of RootObj
        id* : RequestType

    # Add class request
    AddClassRequest* = ref object of RequestPacket
        name* : string
        parentId* : uint64

    # Add class request
    AddInstanceRequest* = ref object of RequestPacket
        name* : string
        classId* : uint64

    # Add field request
    AddFieldRequest* = ref object of RequestPacket
        name* : string
        classId* : uint64
        isClassField* : bool
        valueType* : uint8
    
    # Iterate all classes
    GetAllClassRequest* = ref object of RequestPacket

    # Iterate all instances
    GetAllInstanceRequest* = ref object of RequestPacket        

    # Get field value request
    GetFieldValueRequest* = ref object of RequestPacket
        fieldId* : uint64
        case isClassField* : bool
        of false:
            instanceId* : uint64
        else:
            discard


type 
    # Base response
    ResponsePacket* = ref object of RootObj
        id* : ResponseType                      # Id of packet
        code* : ResponseCode                    # Response code

    # Error response
    ErrorResponse* = ref object of ResponsePacket
        errorCode* : ErrorType                  # Error code

    # Add new class response
    OkResponse* = ref object of ResponsePacket

    # Add class response
    AddClassResponse* = ref object of ResponsePacket
        classId* : uint64

    # Add class response
    AddInstanceResponse* = ref object of ResponsePacket
        instanceId* : uint64

    # Add class response
    AddFieldResponse* = ref object of ResponsePacket
        fieldId* : uint64

    GetAllEntityResponse* = ref object of OkResponse
        isEnd* : bool                   # End of data
        classId* : uint64               # Class id
        name* : string                  # Class name

    # Iterate all classes response
    GetAllClassResponse* = ref object of GetAllEntityResponse
        parentId* : uint64              # Parent class id
        # classFields* : 
        # instanceFields* :
        # classMethods* :
        # instanceMethods* :

    # Iterate all instance response
    GetAllInstanceResponse* = ref object of GetAllEntityResponse

    GetFieldValueResponse* = ref object of OkResponse
        value* : Value

#############################################################################################
# RequestPacket

proc packBaseRequest(stream : LimitedStream, packet : RequestPacket) : void =
    # Pack base request
    stream.addUint8(uint8 packet.id)

#############################################################################################
# AddClassRequest

proc newAddClass*(name : string, parentId : BiggestUInt) : AddClassRequest =
    # Create add class request
    result = AddClassRequest(
        id : ADD_NEW_CLASS,
        name : name,
        parentId : parentId
    )

proc packRequest*(stream : LimitedStream, packet : AddClassRequest) : void =
    # Pack AddClassRequest
    packBaseRequest(stream, packet)
    stream.addStringWithLen(packet.name)
    stream.addUint64(packet.parentId)

proc unpackAddClass(stream : LimitedStream) : AddClassRequest =
    # Unpack to AddClassRequest
    result = AddClassRequest(
        name: stream.readStringWithLen(),
        parentId: stream.readUint64()
    )

#############################################################################################
# AddInstanceRequest

proc newAddInstance*(name : string, classId : BiggestUInt) : AddInstanceRequest =
    # Create add instance request
    result = AddInstanceRequest(
        id : ADD_NEW_INSTANCE,
        name : name,
        classId : classId
    )

proc packRequest*(stream : LimitedStream, packet : AddInstanceRequest) : void =
    # Pack AddInstanceRequest
    packBaseRequest(stream, packet)
    stream.addStringWithLen(packet.name)
    stream.addUint64(packet.classId)

proc unpackAddInstance(stream : LimitedStream) : AddInstanceRequest =
    # Unpack to AddInstanceRequest
    result = newAddInstance(
        name = stream.readStringWithLen(),
        classId = stream.readUint64()
    )

#############################################################################################
# AddFieldRequest

proc unpackAddField(data : LimitedStream) : AddFieldRequest =
    # Unpack AddFieldRequest
    result = AddFieldRequest(
        name: data.readStringWithLen(),
        classId: data.readUint64(),
        isClassField: bool data.readUint8(),
        valueType: data.readUint8()
    )

proc packRequest*(stream : LimitedStream, packet : AddFieldRequest) : void =
    # Pack AddFieldRequest
    packBaseRequest(stream, packet)
    stream.addStringWithLen(packet.name)
    stream.addUint64(packet.classId)
    stream.addUint8(uint8 packet.isClassField)
    stream.addUint8(packet.valueType)

#############################################################################################
# GetAllClassRequest

proc newGetAllClass*() : GetAllClassRequest =
    # Create get all classes
    result = GetAllClassRequest(
        id : GET_ALL_CLASSES
    )

proc packRequest*(stream : LimitedStream, packet : GetAllClassRequest) : void =
    # Pack GetAllClassRequest
    packBaseRequest(stream, packet)

proc unpackGetAllClass(stream : LimitedStream) : GetAllClassRequest =
    # Unpack GetAllClassRequest
    result = newGetAllClass()

#############################################################################################
# GetAllInstanceRequest

proc newGetAllInstance*() : GetAllInstanceRequest =
    # Create get all instances
    result = GetAllInstanceRequest(
        id : GET_ALL_INSTANCES        
    )

proc unpackGetAllInstance(data : LimitedStream) : GetAllInstanceRequest =
    # Unpack GetAllInstanceRequest
    result = GetAllInstanceRequest()

#############################################################################################
# ResponsePacket

proc packBaseResponse(stream : LimitedStream, packet : ResponsePacket) : void =
    # Pack base response
    stream.addUint8(uint8 packet.id)
    stream.addUint8(uint8 packet.code)

#############################################################################################
# OkResponse

proc newOkResponse*(packetId : ResponseType) : OkResponse =
    # Create new Ok response
    result = OkResponse(
        id : packetId,
        code : OK_CODE
    )

proc packResponse*(stream : LimitedStream, packet : OkResponse) : void =
    # Pack ok response
    packBaseResponse(stream, packet)

#############################################################################################
# ErrorResponse

proc newErrorResponse*(packetId : ResponseType, errorCode : ErrorType) : ErrorResponse =
    # Create new Ok response
    result = ErrorResponse(
        id : packetId,
        code : ERROR_CODE,
        errorCode : errorCode
    )

proc newInternalErrorResponse*() : ErrorResponse =
    result = ErrorResponse(
        id : INTERNAL_ERROR_RESPONSE,
        code : ERROR_CODE,
        errorCode : INTERNAL_ERROR
    )

proc packResponse*(stream : LimitedStream, packet : ErrorResponse) : void =
    # Pack error response
    packBaseResponse(stream, packet)
    stream.addUint8(uint8 packet.errorCode)

#############################################################################################
# AddClassResponse

proc newAddClassResponse*(classId : uint64) : AddClassResponse =
    # Add class response
    result = AddClassResponse(
        id : ADD_NEW_CLASS_RESPONSE,
        code : OK_CODE,
        classId : classId
    )

proc packResponse*(stream : LimitedStream, packet : AddClassResponse) : void =
    # Pack AddClassResponse
    packBaseResponse(stream, packet)
    stream.addUint64(packet.classId)

proc unpackAddClassResponse(stream : LimitedStream) : AddClassResponse =
    # Unpack add class response
    result = newAddClassResponse(
        classId = stream.readUint64()
    )

#############################################################################################
# AddInstanceResponse

proc newAddInstanceResponse*(instanceId : uint64) : AddInstanceResponse =
    # Add instance response
    result = AddInstanceResponse(
        id : ADD_NEW_INSTANCE_RESPONSE,
        code : OK_CODE,
        instanceId : instanceId
    )

proc packResponse*(stream : LimitedStream, packet : AddInstanceResponse) : void =
    # Pack AddClassResponse
    packBaseResponse(stream, packet)
    stream.addUint64(packet.instanceId)

proc unpackAddInstanceResponse(stream : LimitedStream) : AddInstanceResponse =
    # Unpack add instance response
    result = newAddInstanceResponse(
        instanceId = stream.readUint64()
    )

#############################################################################################
# GetAllClassResponse

proc newGetAllClassesResponse*(isEnd : bool, classId : uint64 = 0, parentId : uint64 = 0, name : string = "") : GetAllClassResponse =
    # Create new get all class response
    result = GetAllClassResponse(
        id : GET_ALL_CLASSES_RESPONSE,
        code : OK_CODE,
        isEnd : isEnd,
        classId : classId,
        parentId : parentId,
        name : name
    )

proc packResponse*(stream : LimitedStream, packet : GetAllClassResponse) : void =
    # Pack ok response
    packBaseResponse(stream, packet)
    if not packet.isEnd:
        stream.addBool(packet.isEnd)
        stream.addUint64(packet.classId)
        stream.addUint64(packet.parentId)
        stream.addStringWithLen(packet.name)
    else:
        stream.addBool(packet.isEnd)

proc unpackGetAllClassesResponse(stream : LimitedStream) : GetAllClassResponse =
    # Unpack all classes response
    let isEnd = stream.readBool()
    if not isEnd:
        result = newGetAllClassesResponse(
            isEnd = isEnd,
            classId = stream.readUint64(),
            parentId = stream.readUint64(),
            name = stream.readStringWithLen(),
        )
    else:
        result = newGetAllClassesResponse(
            isEnd = isEnd
        )        

#############################################################################################
# GetAllInstanceRequest

proc packRequest*(stream : LimitedStream, packet : GetAllInstanceRequest) : void =
    # Pack GetAllInstanceRequest
    packBaseRequest(stream, packet)

#############################################################################################
# GetFieldValueResponse

# proc newGetFieldValueResponse*(packetId : ResponseType, value : Value) : GetFieldValueResponse =
#     # Create new GetFieldValueResponse
#     result = GetFieldValueResponse(
#         id : packetId,
#         code : OK_CODE,
#         value : value
#     )

# proc packGetFieldValueResponse(stream : LimitedStream, packet : GetFieldValueResponse) : void =
#     # Pack GetFieldValueResponse
#     if packet.value of VInt:
#         let v = packet.value.getInt()
#         stream.addInt32(v)
#     elif packet.value of VFloat:
#         let v = packet.value.getFloat()
#         stream.addFloat64(v)
#     elif packet.value of VString:
#         let v = packet.value.getString()
#         stream.addStringWithLen(v)
#     elif packet.value of VRef:
#         let v = packet.value.getRef()
#         stream.addUint64(v)
#     elif packet.value of VIntArray:
#         let v = packet.value.getIntArray()
#         for it in v:
#             stream.addInt32(it)
#     elif packet.value of VFloatArray:
#         let v = packet.value.getFloatArray()
#         for it in v:
#             stream.addFloat64(it)
#     elif packet.value of VStringArray:
#         let v = packet.value.getStringArray()
#         for it in v:
#             stream.addStringWithLen(it)
#     elif packet.value of VRefArray:
#         let v = packet.value.getRefArray()
#         for it in v:
#             stream.addUint64(it)

#############################################################################################
# Packager api

proc unpackRequest*(data : LimitedStream) : RequestPacket =
    # Unpack request    
    let id = RequestType(data.readUint8())
    case id
    of ADD_NEW_CLASS: result = unpackAddClass(data)
    of ADD_NEW_INSTANCE: result = unpackAddInstance(data)
    of ADD_NEW_FIELD: result = unpackAddField(data)
    of GET_ALL_CLASSES: result = unpackGetAllClass(data)
    of GET_ALL_INSTANCES: result = unpackGetAllInstance(data)
    else:
        raise newException(Exception, "Unknown request packet")

proc unpackResponse(id : ResponseType, code : ResponseCode, data : LimitedStream) : ResponsePacket =
    # Unpack response with some data or not
    case id
    of GET_ALL_CLASSES_RESPONSE: result = unpackGetAllClassesResponse(data)
    of ADD_NEW_CLASS_RESPONSE: result = unpackAddClassResponse(data)
    of ADD_NEW_INSTANCE_RESPONSE: result = unpackAddInstanceResponse(data)
    else:
        result = OkResponse()
    result.id = id
    result.code = code

proc unpackResponse*(data : LimitedStream) : ResponsePacket =
    # Unpack response
    let id = ResponseType(data.readUint8())
    let code = ResponseCode(data.readUint8())
    case code
    of OK_CODE: result = unpackResponse(id, code, data)
    of ERROR_CODE:
        result = ErrorResponse(
            id : id,
            code : code,
            errorCode : ErrorType(data.readUint8())
        )
    else:
        raise newException(Exception, "Unknown responce code")

proc unpackResponse*(data : string) : ResponsePacket =
    # Unpack response
    var stream = newLimitedStream()
    stream.setData(data)
    result = unpackResponse(stream)