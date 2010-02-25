//--------------------------------------------------------
// ORPacModel
// Created by Mark  A. Howe on Tue Jan 6, 2009
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

#import "ORPacModel.h"
#import "ORSerialPort.h"
#import "ORSerialPortAdditions.h"
#import "ORSerialPortList.h"
#import "ORDataTypeAssigner.h"
#import "ORDataPacket.h"
#import "ORDataSet.h"
#import "ORTimeRate.h"

#pragma mark •••External Strings
NSString* ORPacModelSetAllRDacsChanged  = @"ORPacModelSetAllRDacsChanged";
NSString* ORPacModelRdacChannelChanged  = @"ORPacModelRdacChannelChanged";
NSString* ORPacModelLcmEnabledChanged	= @"ORPacModelLcmEnabledChanged";
NSString* ORPacModelPreAmpChanged		= @"ORPacModelPreAmpChanged";
NSString* ORPacModelModuleChanged		= @"ORPacModelModuleChanged";
NSString* ORPacModelDacValueChanged		= @"ORPacModelDacValueChanged";
NSString* ORPacModelSerialPortChanged	= @"ORPacModelSerialPortChanged";
NSString* ORPacModelPortNameChanged		= @"ORPacModelPortNameChanged";
NSString* ORPacModelPortStateChanged	= @"ORPacModelPortStateChanged";
NSString* ORPacModelAdcChanged			= @"ORPacModelAdcChanged";
NSString* ORPacLock						= @"ORPacLock";
NSString* ORPacModelRDacsChanged		= @"ORPacModelRDacsChanged";
NSString* ORPacModelPollingStateChanged	= @"ORPacModelPollingStateChangedNotification";
NSString* ORPacModelMultiPlotsChanged	= @"ORPacModelMultiPlotsChanged";
NSString* ORPacModelLogToFileChanged	= @"ORPacModelLogToFileChanged";
NSString* ORPacModelLogFileChanged		= @"ORPacModelLogFileChanged";

@interface ORPacModel (private)
- (void) timeout;
- (void) processOneCommandFromQueue;
- (void) _setUpPolling:(BOOL)verbose;
- (void) _stopPolling;
- (void) _startPolling;
- (void) _pollAllChannels;
- (void) shipAdcValues;
- (void) loadLogBuffer;
@end

@implementation ORPacModel
- (id) init
{
	self = [super init];
    [self registerNotificationObservers];
	return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [buffer release];
	[cmdQueue release];
	[lastRequest release];
    [portName release];
	[inComingData release];
    if([serialPort isOpen]){
        [serialPort close];
    }
	[serialPort setDelegate:nil];
	[serialPort release];
	
    [logFile release];
	[self _stopPolling];
	
	int i;
	for(i=0;i<8;i++){
		[timeRates[i] release];
	}
	
	[super dealloc];
}

- (void) wakeUp
{
    if(![self aWake]){
		[self _setUpPolling:NO];
		if(logToFile){
			[self performSelector:@selector(writeLogBufferToFile) withObject:nil afterDelay:60];		
		}
    }
    [super wakeUp];
}

- (void) sleep
{
    [super sleep];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void) setUpImage
{
	[self setImage:[NSImage imageNamed:@"Pac.tif"]];
}

- (void) makeMainController
{
	[self linkToController:@"ORPacController"];
}

- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];

    [notifyCenter addObserver : self
                     selector : @selector(dataReceived:)
                         name : ORSerialPortDataReceived
                       object : nil];
}

#pragma mark •••Accessors
- (ORTimeRate*)timeRate:(int)index
{
	return timeRates[index];
}

- (int)  rdac:(int)index
{
	if(index>=0 && index<148)return rdac[index];
	else return 0;
}

- (void) setRdac:(int)index withValue:(int)aValue
{
	if(index>=0 && index<148){
		[[[self undoManager] prepareWithInvocationTarget:self] setRdac:index withValue:rdac[index]];
		rdac[index] = aValue;
		[[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelRDacsChanged object:self];
	}
}

- (BOOL) setAllRDacs
{
    return setAllRDacs;
}

- (void) setSetAllRDacs:(BOOL)aSetAllRDacs
{
    [[[self undoManager] prepareWithInvocationTarget:self] setSetAllRDacs:setAllRDacs];
    setAllRDacs = aSetAllRDacs;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelSetAllRDacsChanged object:self];
}

- (int) rdacChannel
{
    return rdacChannel;
}

- (void) setRdacChannel:(int)aRdacChannel
{
	if(aRdacChannel<0)aRdacChannel=0;
	if(aRdacChannel>147)aRdacChannel=147;
	
    [[[self undoManager] prepareWithInvocationTarget:self] setRdacChannel:rdacChannel];
    rdacChannel = aRdacChannel;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelRdacChannelChanged object:self];
}

- (BOOL) lcmEnabled
{
    return lcmEnabled;
}

- (void) setLcmEnabled:(BOOL)aLcmEnabled
{
    [[[self undoManager] prepareWithInvocationTarget:self] setLcmEnabled:lcmEnabled];
    lcmEnabled = aLcmEnabled;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelLcmEnabledChanged object:self];
}

- (int) preAmp
{
    return preAmp;
}

- (void) setPreAmp:(int)aPreAmp
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPreAmp:preAmp];
    preAmp = aPreAmp;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelPreAmpChanged object:self];
}

- (int) module
{
    return module;
}

- (void) setModule:(int)aModule
{
    [[[self undoManager] prepareWithInvocationTarget:self] setModule:module];
    module = aModule;
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelModuleChanged object:self];
}

- (int) dacValue
{
    return dacValue;
}

- (void) setDacValue:(int)aDacValue
{
	if(aDacValue>256)aDacValue=255;
    [[[self undoManager] prepareWithInvocationTarget:self] setDacValue:dacValue];
    dacValue = aDacValue;
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelDacValueChanged object:self];
}

- (float) convertedAdc:(int)index
{
	if(index<0 && index>=8)return 0.0;
	else return 5.0 * adc[index]/65535.0;
}


- (unsigned short) adc:(int)index
{
	if(index>=0 && index<8)return adc[index];
	else return 0.0;
}

- (void) setAdc:(int)index value:(unsigned short)aValue
{
	if(index>=0 && index<8){
		adc[index] = aValue;
		//get the time(UT!)
		time_t	ut_Time;
		time(&ut_Time);
		//struct tm* theTimeGMTAsStruct = gmtime(&theTime);
		timeMeasured[index] = ut_Time;
		
		[[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelAdcChanged 
															object:self 
														userInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:index] forKey:@"Index"]];


		if(timeRates[index] == nil) timeRates[index] = [[ORTimeRate alloc] init];
		[timeRates[index] addDataToTimeAverage:[self convertedAdc:index]];
	}
}

- (NSData*) lastRequest
{
	return lastRequest;
}

- (void) setLastRequest:(NSData*)aRequest
{
	[aRequest retain];
	[lastRequest release];
	lastRequest = aRequest;    
}

- (BOOL) portWasOpen
{
    return portWasOpen;
}

- (void) setPortWasOpen:(BOOL)aPortWasOpen
{
    portWasOpen = aPortWasOpen;
}

- (NSString*) portName
{
    return portName;
}

- (void) setPortName:(NSString*)aPortName
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPortName:portName];
    
    if(![aPortName isEqualToString:portName]){
        [portName autorelease];
        portName = [aPortName copy];    

        BOOL valid = NO;
        NSEnumerator *enumerator = [ORSerialPortList portEnumerator];
        ORSerialPort *aPort;
        while (aPort = [enumerator nextObject]) {
            if([portName isEqualToString:[aPort name]]){
                [self setSerialPort:aPort];
                if(portWasOpen){
                    [self openPort:YES];
                 }
                valid = YES;
                break;
            }
        } 
        if(!valid){
            [self setSerialPort:nil];
        }       
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelPortNameChanged object:self];
}

- (ORSerialPort*) serialPort
{
    return serialPort;
}

- (void) setSerialPort:(ORSerialPort*)aSerialPort
{
    [aSerialPort retain];
    [serialPort release];
    serialPort = aSerialPort;

    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelSerialPortChanged object:self];
}

- (void) openPort:(BOOL)state
{
    if(state) {
		[serialPort setSpeed:9600];
		[serialPort setParityNone];
		[serialPort setStopBits2:NO];
		[serialPort setDataBits:8];
        [serialPort open];
		[serialPort setDelegate:self];
    }
    else      [serialPort close];
    portWasOpen = [serialPort isOpen];
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelPortStateChanged object:self];
}

- (NSString*) logFile
{
    return logFile;
}

- (void) setLogFile:(NSString*)aLogFile
{
    [[[self undoManager] prepareWithInvocationTarget:self] setLogFile:logFile];
	
    [logFile autorelease];
    logFile = [aLogFile copy];    
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelLogFileChanged object:self];
}

- (BOOL) logToFile
{
    return logToFile;
}

- (void) setLogToFile:(BOOL)aLogToFile
{
    [[[self undoManager] prepareWithInvocationTarget:self] setLogToFile:logToFile];
    
    logToFile = aLogToFile;
	
	if(logToFile)[self performSelector:@selector(writeLogBufferToFile) withObject:nil afterDelay:60];
	else {
		[logBuffer removeAllObjects];
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(writeLogBufferToFile) object:nil];
	}
	
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelLogToFileChanged object:self];
}

- (void) writeLogBufferToFile
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(writeLogBufferToFile) object:nil];
	if(logToFile && [logBuffer count] && [logFile length]){
		if(![[NSFileManager defaultManager] fileExistsAtPath:[logFile stringByExpandingTildeInPath]]){
			[[NSFileManager defaultManager] createFileAtPath:[logFile stringByExpandingTildeInPath] contents:nil attributes:nil];
		}
		
		NSFileHandle* fh = [NSFileHandle fileHandleForUpdatingAtPath:[logFile stringByExpandingTildeInPath]];
		[fh seekToEndOfFile];
		
		int i;
		int n = [logBuffer count];
		for(i=0;i<n;i++){
			[fh writeData:[[logBuffer objectAtIndex:i] dataUsingEncoding:NSASCIIStringEncoding]];
		}
		[fh closeFile];
		[logBuffer removeAllObjects];
	}
	[self performSelector:@selector(writeLogBufferToFile) withObject:nil afterDelay:60];
}

#pragma mark •••Archival
- (id) initWithCoder:(NSCoder*)decoder
{
	self = [super initWithCoder:decoder];
	[[self undoManager] disableUndoRegistration];
	[self setSetAllRDacs:[decoder decodeBoolForKey:		 @"ORPacModelSetAllRDacs"]];
	[self setRdacChannel:	[decoder decodeIntForKey:	 @"ORPacModelRdacChannel"]];
	[self setLcmEnabled:	[decoder decodeBoolForKey:	 @"ORPacModelLcmEnabled"]];
	[self setPreAmp:		[decoder decodeIntForKey:	 @"ORPacModelPreAmp"]];
	[self setModule:		[decoder decodeIntForKey:	 @"ORPacModelModule"]];
	[self setDacValue:		[decoder decodeIntForKey:	 @"dacValue"]];
	[self setPortWasOpen:	[decoder decodeBoolForKey:	 @"portWasOpen"]];
    [self setPortName:		[decoder decodeObjectForKey: @"portName"]];
	[self setPollingState:	[decoder decodeIntForKey:	 @"pollingState"]];
	[self setLogFile:		[decoder decodeObjectForKey: @"logFile"]];
    [self setLogToFile:		[decoder decodeBoolForKey:	 @"logToFile"]];
	

	int i; 
	for(i=0;i<8;i++){
		timeRates[i] = [[ORTimeRate alloc] init];
	}
	for(i=0;i<148;i++){
		[self setRdac:i withValue: [decoder decodeIntForKey:[NSString stringWithFormat:@"rdac%d",i]]];
	}
	[[self undoManager] enableUndoRegistration];
    [self registerNotificationObservers];

	return self;
}

- (void) encodeWithCoder:(NSCoder*)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeBool:setAllRDacs		forKey:@"ORPacModelSetAllRDacs"];
    [encoder encodeInt:rdacChannel		forKey:@"ORPacModelRdacChannel"];
    [encoder encodeBool:lcmEnabled		forKey:@"ORPacModelLcmEnabled"];
    [encoder encodeInt:preAmp			forKey:@"ORPacModelPreAmp"];
    [encoder encodeInt:module			forKey:@"ORPacModelModule"];
    [encoder encodeInt:dacValue			forKey: @"dacValue"];
    [encoder encodeBool:portWasOpen		forKey: @"portWasOpen"];
    [encoder encodeObject:portName		forKey: @"portName"];
    [encoder encodeInt:pollingState		forKey:@"pollingState"];
    [encoder encodeObject:logFile		forKey:@"logFile"];
    [encoder encodeBool:logToFile		forKey:@"logToFile"];
	
	int i; 
	for(i=0;i<148;i++){
		[encoder encodeInt:rdac[i] forKey: [NSString stringWithFormat:@"rdac%d",i]];
	}
}


#pragma mark ••• Commands
- (void) enqueLcmEnable
{
    if([serialPort isOpen]){ 
		char cmdData[2];
		cmdData[0] = kPacLcmEnaCmd;
		cmdData[1] = ([self lcmEnabled]?kPacLcmEnaSet:kPacLcmEnaClr);
		[self enqueCmdData:[NSData dataWithBytes:cmdData length:2]];
	}
}
- (void) enqueModuleSelect
{
    if([serialPort isOpen]){ 
		char cmdData[2];
		cmdData[0] = kPacSelCmd; //module select
		cmdData[1] = (module << 3) | (preAmp & 0x7);
		[self enqueCmdData:[NSData dataWithBytes:cmdData length:2]];
	}
}

- (void) enqueReadADC:(int)aChannel
{
    if([serialPort isOpen]){ 
		char cmdData[2];
		cmdData[0] = kPacADCmd;		
		cmdData[1] = aChannel;
		[self enqueCmdData:[NSData dataWithBytes:cmdData length:2]];
	}
}

- (void) enqueWriteDac
{
    if([serialPort isOpen]){ 
		if([self setAllRDacs]){
			char cmdData[5];
			cmdData[0] = kPacRDacCmd;
			cmdData[1] = kPacRDacWriteAll;
			cmdData[2] = 0x10 | ((dacValue & 0xf0)>>4);
			cmdData[3] = (dacValue & 0x0f)<<4;
			[self enqueCmdData:[NSData dataWithBytes:cmdData length:4]];
		}
		else {
			char cmdData[5];
			cmdData[0] = kPacRDacCmd;
			cmdData[1] = kPacRDacWriteOneRDac;
			cmdData[2] = rdacChannel+1;
			cmdData[3] = 0x10 | ((dacValue & 0xf0)>>4);
			cmdData[4] = (dacValue & 0x0f)<<4;
			[self enqueCmdData:[NSData dataWithBytes:cmdData length:5]];
		}
	}
}

- (void) enqueWriteRdac:(int)index
{
    if([serialPort isOpen]){ 
		if(index>=0 && index<148){
			char cmdData[5];
			cmdData[0] = kPacRDacCmd;
			cmdData[1] = kPacRDacWriteOneRDac;
			cmdData[2] = index+1;
			cmdData[3] = 0x10 | ((rdac[index] & 0xf0)>>4);
			cmdData[4] = (rdac[index] & 0x0f)<<4;
			[self enqueCmdData:[NSData dataWithBytes:cmdData length:5]];
		}
	}
}


- (void) enqueReadDac
{
    if([serialPort isOpen]){ 

		char cmdData[3];
		cmdData[0] = kPacRDacCmd;
		cmdData[1] = kPacRDacReadOneRDac;
		cmdData[2] = rdacChannel+1;
		[self enqueCmdData:[NSData dataWithBytes:cmdData length:3]];
	}
}

- (void) enqueShipCmd
{
    if([serialPort isOpen]){ 
		
		char theCommand = kPacShipAdcs;
		[self enqueCmdData:[NSData dataWithBytes:&theCommand length:1]];
	}
}

- (void) enqueCmdData:(NSData*)someData
{
	if(!cmdQueue)cmdQueue = [[NSMutableArray array] retain];
	[cmdQueue addObject:someData];
	
	if(!lastRequest)[self processOneCommandFromQueue];
}

- (void) selectModule
{
	[self enqueModuleSelect];
}

- (void) readAdcs
{
	int i;
	
	//----------------------------
	//temp for testing
	//for(i=0;i<8;i++){
	//	[self setAdc:[self adc:i]+1 value:65535./(float)i];
	//}
	//[self loadLogBuffer];
	//----------------------------
	
	[self enqueLcmEnable];
	[self enqueModuleSelect];
	for(i=0;i<8;i++){
		[self enqueReadADC:i];
	}
	[self enqueShipCmd];
}

- (void) writeDac
{
	[self enqueWriteDac];
	if(setAllRDacs){
		int i;
		for(i=0;i<148;i++){
			[self setRdac:i withValue:[self dacValue]];
		}
	}
}

- (void) readDac
{
	[self enqueReadDac];
}

#pragma mark •••Data Records
- (unsigned long) dataId { return dataId; }
- (void) setDataId: (unsigned long) DataId
{
    dataId = DataId;
}
- (void) setDataIds:(id)assigner
{
    dataId       = [assigner assignDataIds:kLongForm];
}

- (void) syncDataIdsWith:(id)anotherPac
{
    [self setDataId:[anotherPac dataId]];
}

- (void) appendDataDescription:(ORDataPacket*)aDataPacket userInfo:(id)userInfo
{
    //----------------------------------------------------------------------------------------
    // first add our description to the data description
    [aDataPacket addDataDescriptionItem:[self dataRecordDescription] forKey:@"PacModel"];
}

- (NSDictionary*) dataRecordDescription
{
    NSMutableDictionary* dataDictionary = [NSMutableDictionary dictionary];
    NSDictionary* aDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
        @"ORPacDecoderForAdc",				@"decoder",
        [NSNumber numberWithLong:dataId],   @"dataId",
        [NSNumber numberWithBool:NO],       @"variable",
        [NSNumber numberWithLong:8],        @"length",
        nil];
    [dataDictionary setObject:aDictionary forKey:@"Adcs"];
    
    return dataDictionary;
}

- (void) dataReceived:(NSNotification*)note
{
	BOOL done = NO;
	if(!lastRequest)return;
	
    if([[note userInfo] objectForKey:@"serialPort"] == serialPort){
		if(!inComingData)inComingData = [[NSMutableData data] retain];
        [inComingData appendData:[[note userInfo] objectForKey:@"data"]];
		
		char* theCmd = (char*)[lastRequest bytes];
		switch (theCmd[0]){
			case kPacADCmd:
				if([inComingData length] == 3) {
					unsigned char* theData	 = (unsigned char*)[inComingData bytes];
					short theChannel = theCmd[1] & 0x7;
					short msb		 = theData[0];
					short lsb		 = theData[1];
					if(theData[2] == kPacOkByte) [self setAdc:theChannel value: msb<<8 | lsb];
					else						 NSLogError(@"PAC",@"ADC !OK",nil);
					done = YES;
				}
			break;
				
			case kPacSelCmd:
				if([inComingData length] == 1) {
					unsigned char* theData	 = (unsigned char*)[inComingData bytes];
					if(theData[0] != kPacOkByte)  NSLogError(@"PAC",@"Port D !OK",nil);
					done = YES;
				}
			break;
				
			case kPacRDacCmd:
				if(theCmd[1] == kPacRDacReadOneRDac){
					if([inComingData length] == 3) {
						unsigned char* theData	 = (unsigned char*)[inComingData bytes];
						short msb		 = (theData[0]&0xf)<<4;
						short lsb		 = (theData[1]&0xf0)>>4;
						if(theData[2] == kPacOkByte) NSLog(@"0x%x\n",msb | lsb);
						else						 NSLogError(@"PAC",@"DAC !OK",nil);
						done = YES;
					}
				}
				else if(theCmd[1] == kPacRDacWriteOneRDac){
					if([inComingData length] == 1) {
						unsigned char* theData	 = (unsigned char*)[inComingData bytes];
						if(theData[0] != kPacOkByte) NSLogError(@"PAC",@"DAC !OK",nil);
						done = YES;
					}
				}
				else if(theCmd[1] == kPacRDacWriteAll){
					if([inComingData length] == 1) {
						unsigned char* theData	 = (unsigned char*)[inComingData bytes];
						if(theData[0] != kPacOkByte) NSLogError(@"PAC",@"DAC !OK",nil);
						done = YES;
					}
				}
				
			break;
				
			case kPacLcmEnaCmd:
				if([inComingData length] == 1) {
					unsigned char* theData	 = (unsigned char*)[inComingData bytes];
					if(theData[0] != kPacOkByte)  NSLogError(@"PAC",@"LCM ENA !OK",nil);
					done = YES;
				}
			break;
		}
		
		if(done){
			[inComingData release];
			inComingData = nil;
			[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
			[self setLastRequest:nil];			 //clear the last request
			[self processOneCommandFromQueue];	 //do the next command in the queue
		}
	}
}

- (unsigned long) timeMeasured:(int)index
{
	if(index<0)return 0;
	else if(index>=8)return 0;
	else return timeMeasured[index];
}

- (void)serialPortWriteProgress:(NSDictionary *)dataDictionary
{
}

- (NSMutableDictionary*) addParametersToDictionary:(NSMutableDictionary*)dictionary
{
    NSMutableDictionary* objDictionary = [NSMutableDictionary dictionary];
    [objDictionary setObject:NSStringFromClass([self class]) forKey:@"Class Name"];

	NSMutableArray* rdacArray = [NSMutableArray array];
	int i;
	for(i=0;i<148;i++){
		[rdacArray addObject:[NSNumber numberWithInt:rdac[i]]];
	}
	
    [objDictionary setObject:rdacArray forKey:@"rdac"];
	
	[dictionary setObject:objDictionary forKey:[self identifier]];
    	
	return objDictionary;
}

- (void) setPollingState:(NSTimeInterval)aState
{
    [[[self undoManager] prepareWithInvocationTarget:self] setPollingState:pollingState];
    
    pollingState = aState;
    
    [self performSelector:@selector(_startPolling) withObject:nil afterDelay:0.5];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ORPacModelPollingStateChanged object: self];
}

- (NSTimeInterval)	pollingState
{
    return pollingState;
}

@end

@implementation ORPacModel (private)
- (void) shipAdcValues
{
    if([[ORGlobal sharedGlobal] runInProgress]){
		
		unsigned long data[18];
		data[0] = dataId | 18;
		data[1] = ([self uniqueIdNumber]&0xfff);
		
		int index = 2;
		int i;
		for(i=0;i<8;i++){
			data[index++] = adc[i];
		}
		[[NSNotificationCenter defaultCenter] postNotificationName:ORQueueRecordForShippingNotification 
															object:[NSData dataWithBytes:&data length:sizeof(long)*18]];
	}
}
- (void) loadLogBuffer
{
	NSString*   outputString = nil;
	if(logToFile) {
		outputString = [NSString stringWithFormat:@"%u ",timeMeasured[0]];
		short chan;
		for(chan=0;chan<8;chan++){
			outputString = [outputString stringByAppendingFormat:@"%.2f ",[self convertedAdc:chan]];
		}
		outputString = [outputString stringByAppendingString:@"\n"];
		//accumulate into a buffer, we'll write the file later
		if(!logBuffer)logBuffer = [[NSMutableArray arrayWithCapacity:1024] retain];
		if([outputString length]){
			[logBuffer addObject:outputString];
		}
	}
	readCount++;	
}
- (void) timeout
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeout) object:nil];
	NSLogError(@"PAC",@"command timeout",nil);
	[self setLastRequest:nil];
	[self processOneCommandFromQueue];	 //do the next command in the queue
}

- (void) processOneCommandFromQueue
{
	if([cmdQueue count] == 0) return;
	NSData* cmdData = [[[cmdQueue objectAtIndex:0] retain] autorelease];
	[cmdQueue removeObjectAtIndex:0];
	unsigned char* cmd = (unsigned char*)[cmdData bytes];
	if(cmd[0] == kPacShipAdcs){
		[self shipAdcValues];
		[self loadLogBuffer];
	}
	else {
		[self setLastRequest:cmdData];
		[serialPort writeDataInBackground:cmdData];
		[self performSelector:@selector(timeout) withObject:nil afterDelay:1];
	}
}

- (void) _stopPolling
{
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_pollAllChannels) object:nil];
	pollRunning = NO;
}

- (void) _startPolling
{
	[self _setUpPolling:YES];
}

- (void) _setUpPolling:(BOOL)verbose
{
    if(pollingState!=0){  
		readCount = 0;
		pollRunning = YES;
        if(verbose)NSLog(@"Polling PAC,%d  every %.0f seconds.\n",[self uniqueIdNumber],pollingState);
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_pollAllChannels) object:nil];
        [self _pollAllChannels];
    }
    else {
		[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_pollAllChannels) object:nil];
        if(verbose)NSLog(@"Not Polling PAC,%d\n",[self uniqueIdNumber]);
    }
}

- (void) _pollAllChannels
{
    @try { 
        [self readAdcs]; 
    }
	@catch(NSException* localException) { 
		//catch this here to prevent it from falling thru, but nothing to do.
	}
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_pollAllChannels) object:nil];
	if(pollingState!=0){
		[self performSelector:@selector(_pollAllChannels) withObject:nil afterDelay:pollingState];
	}
}


@end