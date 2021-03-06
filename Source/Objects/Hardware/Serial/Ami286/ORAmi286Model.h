//--------------------------------------------------------
// ORAmi286Model
// Created by Mark  A. Howe on Fri Sept 14, 2007
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2005 CENPA, University of Washington. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of 
//Washington at the Center for Experimental Nuclear Physics and 
//Astrophysics (CENPA) sponsored in part by the United States 
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020. 
//The University has certain rights in the program pursuant to 
//the contract and the program should not be copied or distributed 
//outside your organization.  The DOE and the University of 
//Washington reserve all rights in the program. Neither the authors,
//University of Washington, or U.S. Government make any warranty, 
//express or implied, or assume any liability or responsibility 
//for the use of this software.
//-------------------------------------------------------------

#pragma mark •••Imported Files

#import "ORAdcProcessing.h"

@class ORSerialPort;
@class ORTimeRate;
@class ORAlarm;


@interface ORAmi286Model : OrcaObject <ORAdcProcessing>
{
@private
    NSString*       portName;
    BOOL            portWasOpen;
    ORSerialPort*   serialPort;
    unsigned long	dataId;
    NSString*		lastRequest;
    NSMutableArray* cmdQueue;
    int				pollTime;
    NSMutableString* buffer;
    BOOL			shipLevels;
    ORTimeRate*		timeRates[4];
    float		    level[4];
    int				fillStatus[4];
    int				fillState[4];
    float		    hiAlarmLevel[4];
    float		    lowAlarmLevel[4];
    float		    hiFillPoint[4];
    float		    lowFillPoint[4];
    unsigned long	timeMeasured[4];
    int				alarmStatus[4];
    NSDate*         lastChange[4];
    NSTimer*		expiredTimer[4];
    unsigned char	enabledMask;
    BOOL			unitsSet;
    ORAlarm*		hiAlarm[4];
    ORAlarm*		lowAlarm[4];
    ORAlarm*		expiredAlarm[4];
    NSMutableArray* eMailList;
    BOOL			emailEnabled;
    BOOL			eMailThreadRunning;
    NSLock*			eMailLock;
    BOOL			sendOnValveChange;
    BOOL			sendOnExpired;
    long			expiredTime;
    BOOL			sendOnAlarm;
    BOOL			ignoreSend;
    BOOL			sendIsScheduled;
    NSMutableArray* eMailReasons;
    BOOL            readOnce;
    BOOL            isValid;
}

#pragma mark •••Initialization
- (id)   init;
- (void) dealloc;

- (void) registerNotificationObservers;
- (void) dataReceived:(NSNotification*)note;

#pragma mark •••Accessors
- (BOOL) sendOnAlarm;
- (void) setSendOnAlarm:(BOOL)aSendOnAlarm;
- (long) expiredTime;
- (void) setExpiredTime:(long)aExpiredTime;
- (BOOL) sendOnExpired;
- (void) setSendOnExpired:(BOOL)aSendOnExpired;
- (BOOL) sendOnValveChange;
- (void) setSendOnValveChange:(BOOL)aSendOnValveChange;
- (void) addEMail;
- (void) removeEMail:(unsigned) anIndex;
- (NSString*) addressAtIndex:(unsigned)anIndex;
- (BOOL) emailEnabled;
- (void) setEmailEnabled:(BOOL)aEmailEnabled;
- (NSMutableArray*) eMailList;
- (void) setEMailList:(NSMutableArray*)aEMailList;
- (unsigned char) enabledMask;
- (void) setEnabledMask:(unsigned char)aEnableMask;
- (ORTimeRate*)timeRate:(int)index;
- (BOOL) shipLevels;
- (void) setShipLevels:(BOOL)aShipLevels;
- (int)  pollTime;
- (void) setPollTime:(int)aPollTime;
- (ORSerialPort*) serialPort;
- (void) setSerialPort:(ORSerialPort*)aSerialPort;
- (BOOL) portWasOpen;
- (void) setPortWasOpen:(BOOL)aPortWasOpen;
- (NSString*) portName;
- (void) setPortName:(NSString*)aPortName;
- (NSString*) lastRequest;
- (void) setLastRequest:(NSString*)aRequest;
- (void) openPort:(BOOL)state;
- (unsigned long) timeMeasured:(int)index;
- (void) setLevel:(int)index value:(float)aValue;
- (float) level:(int)index;
- (void) setFillStatus:(int)index value:(int)aValue;
- (int) fillStatus:(int)index;
- (void) setAlarmStatus:(int)index value:(int)aValue;
- (int) alarmStatus:(int)index;
- (void) setLastChange:(int)index;
- (NSDate*) lastChange:(int)index;

- (void)  setFillState:(int)index value:(int)aValue;
- (int)   fillState:(int)index;
- (void)  setLowAlarmLevel:(int)index value:(float)aValue;
- (float) lowAlarmLevel:(int)index;
- (void)  setHiAlarmLevel:(int)index value:(float)aValue;
- (float) hiAlarmLevel:(int)index;

- (void)  setLowFillPoint:(int)index value:(float)aValue;
- (float) lowFillPoint:(int)index;
- (void)  setHiFillPoint:(int)index value:(float)aValue;
- (float) hiFillPoint:(int)index;

- (NSString*) fillStatusName:(int)i;
- (NSString*) fillStateName:(int)i;

#pragma mark •••Data Records
- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo;
- (NSDictionary*) dataRecordDescription;
- (unsigned long) dataId;
- (void) setDataId: (unsigned long) DataId;
- (void) setDataIds:(id)assigner;
- (void) syncDataIdsWith:(id)anotherAmi286;

- (void) shipLevelValues;

#pragma mark •••Commands
- (void) loadHardware;
- (void) loadFillState;
- (void) addCmdToQueue:(NSString*)aCmd;
- (void) readLevels:(BOOL)ship;
- (void) readLevels;
- (void) setLowAlarm:(int)chan withValue:(float)aValue;
- (void) setHighAlarm:(int)chan withValue:(float)aValue;
- (void) setLowFillPoint:(int)chan withValue:(float)aValue;
- (void) setHighFillPoint:(int)chan withValue:(float)aValue;
- (void) loadAlarmsToHardware;
- (void) loadFillPointsToHardware;

- (id)   initWithCoder:(NSCoder*)decoder;
- (void) encodeWithCoder:(NSCoder*)encoder;
@end

extern NSString* ORAmi286ModelSendOnAlarmChanged;
extern NSString* ORAmi286ModelExpiredTimeChanged;
extern NSString* ORAmi286ModelSendOnExpiredChanged;
extern NSString* ORAmi286ModelSendOnValveChangeChanged;
extern NSString* ORAmi286EMailEnabledChanged;
extern NSString* ORAmi286EMailAddressesChanged;
extern NSString* ORAmi286FillStateChanged;
extern NSString* ORAmi286ModelEnabledMaskChanged;
extern NSString* ORAmi286ModelShipLevelsChanged;
extern NSString* ORAmi286ModelPollTimeChanged;
extern NSString* ORAmi286ModelSerialPortChanged;
extern NSString* ORAmi286Lock;
extern NSString* ORAmi286ModelPortNameChanged;
extern NSString* ORAmi286ModelPortStateChanged;
extern NSString* ORAmi286AlarmLevelChanged;
extern NSString* ORAmi286Update;
extern NSString* ORAmi286LastChange;
extern NSString* ORAmi286FillPointChanged;

