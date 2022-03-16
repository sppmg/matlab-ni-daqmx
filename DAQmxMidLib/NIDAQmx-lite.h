/*============================================================================*/
/*                 National Instruments / Data Acquisition                    */
/*----------------------------------------------------------------------------*/
/*    Copyright (c) National Instruments 2003-2013.  All Rights Reserved.     */
/*----------------------------------------------------------------------------*/
/*                                                                            */
/* Title:       NIDAQmx.h                                                     */
/* Purpose:     Include file for NI-DAQmx  library support.                */
/*                                                                            */
/*============================================================================*/

#ifndef ___nidaqmx_h___
#define ___nidaqmx_h___

#ifdef __cplusplus
	extern "C" {
#endif

#if defined(__linux__) || defined(__APPLE__)
#define __CFUNC
#define __CFUNC_C
#define __CFUNCPTRVAR
#define CVICDECL
#define CVICALLBACK     CVICDECL
#else
#define __CFUNC         __stdcall
#define __CFUNC_C       __cdecl
#define __CFUNCPTRVAR   __cdecl
#define CVICDECL        __cdecl
#define CVICALLBACK     CVICDECL
#endif


#if defined(_CVI_) && !defined(__TPC__)
#pragma EnableLibraryRuntimeChecking
#endif


// NI-DAQmx Typedefs
#ifndef _NI_int8_DEFINED_
#define _NI_int8_DEFINED_
	typedef signed char        int8;
#endif
#ifndef _NI_uInt8_DEFINED_
#define _NI_uInt8_DEFINED_
	typedef unsigned char      uInt8;
#endif
#ifndef _NI_int16_DEFINED_
#define _NI_int16_DEFINED_
	typedef signed short       int16;
#endif
#ifndef _NI_uInt16_DEFINED_
#define _NI_uInt16_DEFINED_
	typedef unsigned short     uInt16;
#endif
#ifndef _NI_int32_DEFINED_
#define _NI_int32_DEFINED_
	typedef signed long        int32;
#endif
#ifndef _NI_uInt32_DEFINED_
#define _NI_uInt32_DEFINED_
	typedef unsigned long      uInt32;
#endif
#ifndef _NI_float32_DEFINED_
#define _NI_float32_DEFINED_
	typedef float              float32;
#endif
#ifndef _NI_float64_DEFINED_
#define _NI_float64_DEFINED_
	typedef double             float64;
#endif
#ifndef _NI_int64_DEFINED_
#define _NI_int64_DEFINED_
#if defined(__linux__) || defined(__APPLE__)
	typedef long long int      int64;
#else
	typedef __int64            int64;
#endif
#endif
#ifndef _NI_uInt64_DEFINED_
#define _NI_uInt64_DEFINED_
#if defined(__linux__) || defined(__APPLE__)
	typedef unsigned long long uInt64;
#else
	typedef unsigned __int64   uInt64;
#endif
#endif

typedef uInt32             bool32;

typedef void*              TaskHandle;
//typedef uInt32              TaskHandle;
typedef uInt32             CalHandle;

#ifndef TRUE
 #define TRUE            (1L)
#endif
#ifndef FALSE
 #define FALSE           (0L)
#endif
#ifndef NULL
 #define NULL            (0L)
#endif

/******************************************************************************
 *** NI-DAQmx Function Declarations *******************************************
 ******************************************************************************/

/******************************************************/
/***         Task Configuration/Control             ***/
/******************************************************/


int32 __CFUNC     DAQmxLoadTask                  (const char taskName[], TaskHandle *taskHandle);
int32 __CFUNC     DAQmxCreateTask                (const char taskName[], TaskHandle *taskHandle);
// Channel Names must be valid channels already available in MAX. They are not created.
int32 __CFUNC     DAQmxAddGlobalChansToTask      (TaskHandle taskHandle, const char channelNames[]);

int32 __CFUNC     DAQmxStartTask                 (TaskHandle taskHandle);
int32 __CFUNC     DAQmxStopTask                  (TaskHandle taskHandle);

int32 __CFUNC     DAQmxClearTask                 (TaskHandle taskHandle);

int32 __CFUNC     DAQmxWaitUntilTaskDone         (TaskHandle taskHandle, float64 timeToWait);
int32 __CFUNC     DAQmxIsTaskDone                (TaskHandle taskHandle, bool32 *isTaskDone);

int32 __CFUNC     DAQmxTaskControl               (TaskHandle taskHandle, int32 action);

/******************************************************/
/***        Channel Configuration/Creation          ***/
/******************************************************/


int32 __CFUNC     DAQmxCreateAIVoltageChan       (TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], int32 terminalConfig, float64 minVal, float64 maxVal, int32 units, const char customScaleName[]);
int32 __CFUNC     DAQmxCreateAICurrentChan       (TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], int32 terminalConfig, float64 minVal, float64 maxVal, int32 units, int32 shuntResistorLoc, float64 extShuntResistorVal, const char customScaleName[]);
int32 __CFUNC     DAQmxCreateAIVoltageRMSChan    (TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], int32 terminalConfig, float64 minVal, float64 maxVal, int32 units, const char customScaleName[]);
int32 __CFUNC     DAQmxCreateAICurrentRMSChan    (TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], int32 terminalConfig, float64 minVal, float64 maxVal, int32 units, int32 shuntResistorLoc, float64 extShuntResistorVal, const char customScaleName[]);

int32 __CFUNC     DAQmxCreateAOVoltageChan       (TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], float64 minVal, float64 maxVal, int32 units, const char customScaleName[]);
int32 __CFUNC     DAQmxCreateAOCurrentChan       (TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], float64 minVal, float64 maxVal, int32 units, const char customScaleName[]);
int32 __CFUNC     DAQmxCreateAOFuncGenChan       (TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], int32 type, float64 freq, float64 amplitude, float64 offset);

int32 __CFUNC     DAQmxCreateDOChan              (TaskHandle taskHandle, const char lines[], const char nameToAssignToLines[], int32 lineGrouping);


int32 __CFUNC     DAQmxCreateCOPulseChanFreq     (TaskHandle taskHandle, const char counter[], const char nameToAssignToChannel[], int32 units, int32 idleState, float64 initialDelay, float64 freq, float64 dutyCycle);
int32 __CFUNC     DAQmxCreateCOPulseChanTime     (TaskHandle taskHandle, const char counter[], const char nameToAssignToChannel[], int32 units, int32 idleState, float64 initialDelay, float64 lowTime, float64 highTime);

int32 __CFUNC_C   DAQmxGetChanAttribute          (TaskHandle taskHandle, const char channel[], int32 attribute, void *value, ...);
int32 __CFUNC_C   DAQmxSetChanAttribute          (TaskHandle taskHandle, const char channel[], int32 attribute, ...);
int32 __CFUNC     DAQmxResetChanAttribute        (TaskHandle taskHandle, const char channel[], int32 attribute);

/******************************************************/
/***                    Timing                      ***/
/******************************************************/


// (Analog/Counter Timing)
int32 __CFUNC     DAQmxCfgSampClkTiming          (TaskHandle taskHandle, const char source[], float64 rate, int32 activeEdge, int32 sampleMode, uInt64 sampsPerChan);
// (Counter Timing)
int32 __CFUNC     DAQmxCfgImplicitTiming         (TaskHandle taskHandle, int32 sampleMode, uInt64 sampsPerChan);

/******************************************************/
/***                 Read Data                      ***/
/******************************************************/


int32 __CFUNC     DAQmxReadAnalogF64             (TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, bool32 fillMode, float64 readArray[], uInt32 arraySizeInSamps, int32 *sampsPerChanRead, bool32 *reserved);
int32 __CFUNC     DAQmxReadAnalogScalarF64       (TaskHandle taskHandle, float64 timeout, float64 *value, bool32 *reserved);

int32 __CFUNC_C   DAQmxGetReadAttribute          (TaskHandle taskHandle, int32 attribute, void *value, ...);
int32 __CFUNC_C   DAQmxSetReadAttribute          (TaskHandle taskHandle, int32 attribute, ...);
int32 __CFUNC     DAQmxResetReadAttribute        (TaskHandle taskHandle, int32 attribute);

/******************************************************/
/***                 Write Data                     ***/
/******************************************************/


int32 __CFUNC     DAQmxWriteAnalogF64            (TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, const float64 writeArray[], int32 *sampsPerChanWritten, bool32 *reserved);
int32 __CFUNC     DAQmxWriteAnalogScalarF64      (TaskHandle taskHandle, bool32 autoStart, float64 timeout, float64 value, bool32 *reserved);

int32 __CFUNC     DAQmxWriteDigitalLines         (TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, const uInt8 writeArray[], int32 *sampsPerChanWritten, bool32 *reserved);

int32 __CFUNC     DAQmxWriteCtrFreq              (TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, const float64 frequency[], const float64 dutyCycle[], int32 *numSampsPerChanWritten, bool32 *reserved);
int32 __CFUNC     DAQmxWriteCtrFreqScalar        (TaskHandle taskHandle, bool32 autoStart, float64 timeout, float64 frequency, float64 dutyCycle, bool32 *reserved);
int32 __CFUNC     DAQmxWriteCtrTimeScalar        (TaskHandle taskHandle, bool32 autoStart, float64 timeout, float64 highTime, float64 lowTime, bool32 *reserved);

int32 __CFUNC_C   DAQmxGetWriteAttribute         (TaskHandle taskHandle, int32 attribute, void *value, ...);
int32 __CFUNC_C   DAQmxSetWriteAttribute         (TaskHandle taskHandle, int32 attribute, ...);
int32 __CFUNC     DAQmxResetWriteAttribute       (TaskHandle taskHandle, int32 attribute);


/******************************************************/
/***             Buffer Configurations              ***/
/******************************************************/


int32 __CFUNC     DAQmxCfgInputBuffer            (TaskHandle taskHandle, uInt32 numSampsPerChan);
int32 __CFUNC     DAQmxCfgOutputBuffer           (TaskHandle taskHandle, uInt32 numSampsPerChan);

int32 __CFUNC_C   DAQmxGetBufferAttribute        (TaskHandle taskHandle, int32 attribute, void *value);
int32 __CFUNC_C   DAQmxSetBufferAttribute        (TaskHandle taskHandle, int32 attribute, ...);
int32 __CFUNC     DAQmxResetBufferAttribute      (TaskHandle taskHandle, int32 attribute);

int32 __CFUNC     DAQmxGetBufOutputBufSize       (TaskHandle taskHandle, uInt32 *data);

/******************************************************/
/***                Device Control                  ***/
/******************************************************/


int32 __CFUNC     DAQmxResetDevice               (const char deviceName[]);

int32 __CFUNC     DAQmxSelfTestDevice            (const char deviceName[]);

int32 __CFUNC_C   DAQmxGetDeviceAttribute        (const char deviceName[], int32 attribute, void *value, ...);

/******************************************************/
/***                  Real-Time                     ***/
/******************************************************/

int32 __CFUNC     DAQmxWaitForNextSampleClock(TaskHandle taskHandle, float64 timeout, bool32 *isLate);

/******************************************************/
/***                 Error Handling                 ***/
/******************************************************/


int32 __CFUNC     DAQmxGetErrorString            (int32 errorCode, char errorString[], uInt32 bufferSize);
int32 __CFUNC     DAQmxGetExtendedErrorInfo      (char errorString[], uInt32 bufferSize);


/******************************************************************************
 *** NI-DAQmx Specific Attribute Get/Set/Reset Function Declarations **********
 ******************************************************************************/

//********** Buffer **********

//********** Read **********

//*** Set/Get functions for DAQmx_Read_OverWrite ***
// Uses value set OverwriteMode1
int32 __CFUNC DAQmxGetReadOverWrite(TaskHandle taskHandle, int32 *data);
int32 __CFUNC DAQmxSetReadOverWrite(TaskHandle taskHandle, int32 data);
int32 __CFUNC DAQmxResetReadOverWrite(TaskHandle taskHandle);

//********** Write **********

//*** Set/Get functions for DAQmx_Write_RegenMode ***
// Uses value set RegenerationMode1
int32 __CFUNC DAQmxGetWriteRegenMode(TaskHandle taskHandle, int32 *data);
int32 __CFUNC DAQmxSetWriteRegenMode(TaskHandle taskHandle, int32 data);
int32 __CFUNC DAQmxResetWriteRegenMode(TaskHandle taskHandle);

// ************* other **************
int32 __CFUNC DAQmxGetSampTimingType(TaskHandle taskHandle, int32 *data);
int32 __CFUNC DAQmxSetSampTimingType(TaskHandle taskHandle, int32 data);
int32 __CFUNC DAQmxResetSampTimingType(TaskHandle taskHandle);


// ************* New ****************

// #define DAQmx_AI_Lowpass_Enable                                          0x1802 // Specifies whether to enable the lowpass filter of the channel.
// #define DAQmx_AI_Lowpass_CutoffFreq                                      0x1803 // Specifies the frequency in Hertz that corresponds to the -3dB cutoff of the filter.

//*** Set/Get functions for DAQmx_AI_Lowpass_Enable ***
int32 __CFUNC DAQmxGetAILowpassEnable(TaskHandle taskHandle, const char channel[], bool32 *data);
int32 __CFUNC DAQmxSetAILowpassEnable(TaskHandle taskHandle, const char channel[], bool32 data);
int32 __CFUNC DAQmxResetAILowpassEnable(TaskHandle taskHandle, const char channel[]);
//*** Set/Get functions for DAQmx_AI_Lowpass_CutoffFreq ***
int32 __CFUNC DAQmxGetAILowpassCutoffFreq(TaskHandle taskHandle, const char channel[], float64 *data);
int32 __CFUNC DAQmxSetAILowpassCutoffFreq(TaskHandle taskHandle, const char channel[], float64 data);
int32 __CFUNC DAQmxResetAILowpassCutoffFreq(TaskHandle taskHandle, const char channel[]);




#ifdef __cplusplus
	}
#endif

#endif // __nidaqmx_h__
