//--------------------------------------------------------
// ORMotoGPSController
// Created by Mark  A. Howe on Fri Jul 22 2005 / Julius Hartmann, KIT, November 2017
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
//for the use of this softwarePulser.
//-------------------------------------------------------------

#pragma mark ***Imported Files

#import "ORMotoGPSController.h"
#import "ORMotoGPSModel.h"
#import "ORRefClockModel.h"

@implementation ORMotoGPSController
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [topLevelObjects release];
    [super dealloc];
}

#pragma mark ***Initialization

- (void) awakeFromNib
{
    if(!deviceContent){
        if ([[NSBundle mainBundle] loadNibNamed:@"MotoGPS" owner:self  topLevelObjects:&topLevelObjects]) {
            [topLevelObjects retain];
        
            [deviceView setContentView:deviceContent];
            [[self model] setStatusPoll:[statusPollCB state]];
        }
        else NSLog(@"Failed to load MotoGPS.nib");
    }
}

- (id) model
{
    return model;
}

- (void) setModel:(id)aModel
{
    model = aModel;
    [self registerNotificationObservers];
    [self updateWindow];
}

#pragma mark ***Notifications
- (void) registerNotificationObservers
{
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];

    [notifyCenter addObserver : self
                     selector : @selector(statusChanged:)
                         name : ORMotoGPSModelStatusChanged
                        object: model];

    [notifyCenter addObserver : self
                     selector : @selector(statusPollChanged:)
                         name : ORMotoGPSModelStatusPollChanged
                        object: model];

    [notifyCenter addObserver : self
                     selector : @selector(receivedMessageChanged:)
                         name : ORMotoGPSModelReceivedMessageChanged
                        object: model];

    
    
}

- (void) updateWindow
{
    [self statusChanged:nil];
    [self statusPollChanged:nil];
    [self receivedMessageChanged:nil];
}

- (void) setButtonStates
{
    //BOOL runInProgress = [gOrcaGlobals runInProgress];
    BOOL lockedOrRunningMaintenance = [gSecurity runInProgressButNotType:eMaintenanceRunType orIsLocked:ORRefClockLock];//ORMotoGPSLock];
    BOOL portOpen = [model portIsOpen];
    [setDefaults         setEnabled:!lockedOrRunningMaintenance && portOpen];
    [autoSurveyButton    setEnabled:!lockedOrRunningMaintenance && portOpen];
    [statusButton        setEnabled:!lockedOrRunningMaintenance && portOpen];
    [statusPollCB        setEnabled:!lockedOrRunningMaintenance && portOpen];
    [deviceIDButton      setEnabled:!lockedOrRunningMaintenance && portOpen];
    [cableDelayCorButton setEnabled:!lockedOrRunningMaintenance && portOpen];
}

- (void) receivedMessageChanged:(NSNotification*)aNote
{
    if([model lastReceived] != nil){
        [receivedMessageField setStringValue:[model lastReceived]];
    }
}
- (void) autoSurveyChanged:(NSNotification*)aNote
{
}

- (void) statusChanged:(NSNotification*)aNote
{
}

- (void) statusPollChanged:(NSNotification*)aNote
{
    [statusPollCB setIntValue:[model statusPoll]];
}

- (void) visibleSatsChanged:(NSNotification*)aNote
{
}

- (void) trackedSatsChanged:(NSNotification*)aNote
{
}

- (void) visibilityStatusChanged:(NSNotification*)aNote
{
}

- (void) antennaSenseChanged:(NSNotification*)aNote
{
}

- (void) accSignalStrengthChanged:(NSNotification*)aNote
{
}

- (void) oscTemperatureChanged:(NSNotification*)aNote
{
}

#pragma mark ***Actions
- (IBAction) setDefaultsAction:(id)sender
{
    [model setDefaults];
}

- (IBAction) autoSurveyAction:(id)sender
{
}

- (void) statusAction:(id)sender
{
  //[model requestStatus];
}

- (void) statusPollAction:(id)sender
{
    [model setStatusPoll:[sender intValue]];
}

- (void) deviceIDAction:(id)sender
{
}

- (IBAction) cableDelayCorAction:(id)sender
{
}

@end

