/*
 *  ORCaen965Controller.m
 *  Orca
 *
 *  Created by Mark Howe on Thurs May 29 2008.
 *  Copyright (c) 2008 CENPA, University of Washington. All rights reserved.
 *
 */
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

#import "ORCaen965Controller.h"
#import "ORCaenDataDecoder.h"
#import "ORCaen965Model.h"

@implementation ORCaen965Controller

#pragma mark ***Initialization
- (id) init
{
    self = [ super initWithWindowNibName: @"Caen965" ];
    return self;
}
- (void) awakeFromNib
{
	
    settingSize     = NSMakeSize(280,400);
    thresholdSize   = NSMakeSize(290,570);
    
    blankView = [[NSView alloc] init];
    [self tabView:tabView didSelectTabViewItem:[tabView selectedTabViewItem]];
	
    [registerAddressPopUp setAlignment:NSCenterTextAlignment];
    [channelPopUp setAlignment:NSCenterTextAlignment];
	
    [self populatePullDown];
    
    [super awakeFromNib];
	
    NSString* key = [NSString stringWithFormat: @"orca.ORCaen965%d.selectedtab",[model slot]];
    int index = [[NSUserDefaults standardUserDefaults] integerForKey: key];
    if((index<0) || (index>[tabView numberOfTabViewItems]))index = 0;
    [tabView selectTabViewItemAtIndex: index];
	
}

#pragma mark •••Notifications
- (void) registerNotificationObservers
{
    [ super registerNotificationObservers ];
	
	NSNotificationCenter* notifyCenter = [NSNotificationCenter defaultCenter];
    [notifyCenter addObserver:self
					 selector:@selector(baseAddressChanged:)
						 name:ORVmeIOCardBaseAddressChangedNotification
					   object:model];
	
	[notifyCenter addObserver : self
					 selector : @selector(slotChanged:)
						 name : ORVmeCardSlotChangedNotification
					   object : model];
	
   [notifyCenter addObserver : self
					 selector : @selector(onlineMaskChanged:)
						 name : ORCaen965ModelOnlineMaskChanged
					   object : model];
	
	[notifyCenter addObserver:self
					 selector:@selector(lowThresholdChanged:)
						 name:ORCaen965LowThresholdChanged
					   object:model];
	
	[notifyCenter addObserver:self
					 selector:@selector(highThresholdChanged:)
						 name:ORCaen965HighThresholdChanged
					   object:model];
	
	[notifyCenter addObserver : self
                     selector : @selector(basicLockChanged:)
                         name : ORCaen965BasicLock
						object: nil];
	
	[notifyCenter addObserver : self
					 selector : @selector(basicLockChanged:)
						 name : ORRunStatusChangedNotification
					   object : nil];
	
	[notifyCenter addObserver:self
					 selector:@selector(selectedRegIndexChanged:)
						 name:ORCaen965SelectedRegIndexChanged
					   object:model];
	
    [notifyCenter addObserver:self
					 selector:@selector(selectedRegChannelChanged:)
						 name:ORCaen965SelectedChannelChanged
					   object:model];
	
	
    [notifyCenter addObserver:self
					 selector:@selector(writeValueChanged:)
						 name:ORCaen965WriteValueChanged
					   object:model];
}

#pragma mark ***Interface Management
- (void) updateWindow
{
	[super updateWindow ];
    [self baseAddressChanged:nil];
    [self onlineMaskChanged:nil];
	[self slotChanged:nil];
    [self writeValueChanged:nil];
    [self selectedRegIndexChanged:nil];
    [self selectedRegIndexChanged:nil];
    short 	i;
    for (i = 0; i < [model numberOfChannels]; i++){
        NSMutableDictionary* userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:[NSNumber numberWithInt:i] forKey:@"channel"];
        [[NSNotificationCenter defaultCenter] postNotificationName:ORCaen965LowThresholdChanged object:model userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotificationName:ORCaen965HighThresholdChanged object:model userInfo:userInfo];
	}
    [self basicLockChanged:nil];
    [self slotChanged:nil];
}

- (void) checkGlobalSecurity
{
    BOOL secure = [[[NSUserDefaults standardUserDefaults] objectForKey:OROrcaSecurityEnabled] boolValue];
    [gSecurity setLock:ORCaen965BasicLock to:secure];
    [basicLock1Button setEnabled:secure];
    [basicLock2Button setEnabled:secure];
}

- (void) baseAddressChanged:(NSNotification*)aNote
{
	[baseAddressField setIntValue: [model baseAddress]];
}

- (void) slotChanged:(NSNotification*)aNotification
{
	[slotField setIntValue: [model slot]];
	[[self window] setTitle:[NSString stringWithFormat:@"%@",[model identifier]]];
}

- (void) setModel:(id)aModel
{
	[super setModel:aModel];
	[[self window] setTitle:[NSString stringWithFormat:@"%@",[model identifier]]];
}

- (void) lowThresholdChanged:(NSNotification*) aNote
{
	int chnl = [[[aNote userInfo] objectForKey:@"channel"] intValue];
	[[lowThresholdMatrix cellWithTag:chnl] setIntValue:[model lowThreshold:chnl]];
}

- (void) highThresholdChanged:(NSNotification*) aNote
{
	int chnl = [[[aNote userInfo] objectForKey:@"channel"] intValue];
	[[highThresholdMatrix cellWithTag:chnl] setIntValue:[model highThreshold:chnl]];
}

- (void) basicLockChanged:(NSNotification*)aNotification
{
    BOOL runInProgress = [gOrcaGlobals runInProgress];
    BOOL lockedOrRunningMaintenance = [gSecurity runInProgressButNotType:eMaintenanceRunType orIsLocked:ORCaen965BasicLock];
    BOOL locked = [gSecurity isLocked:ORCaen965BasicLock];
    [onlineMaskMatrix setEnabled:!lockedOrRunningMaintenance];
    [lowThresholdMatrix setEnabled:!lockedOrRunningMaintenance];
    [highThresholdMatrix setEnabled:!lockedOrRunningMaintenance];
    [readThresholdsButton setEnabled:!lockedOrRunningMaintenance];
    [writeThresholdsButton setEnabled:!lockedOrRunningMaintenance];
	
    [baseAddressField setEnabled:!locked && !runInProgress];
    [writeValueStepper setEnabled:!lockedOrRunningMaintenance];
    [writeValueTextField setEnabled:!lockedOrRunningMaintenance];
    [registerAddressPopUp setEnabled:!lockedOrRunningMaintenance];
    [channelPopUp setEnabled:!lockedOrRunningMaintenance];
	
    [basicWriteButton setEnabled:!lockedOrRunningMaintenance];
    [basicReadButton setEnabled:!lockedOrRunningMaintenance]; 
	
    NSString* s = @"";
    if(lockedOrRunningMaintenance){
		if(runInProgress && ![gSecurity isLocked:ORCaen965BasicLock])s = @"Not in Maintenance Run.";
    }
    [basicLockDocField setStringValue:s];
	
}

- (void) onlineMaskChanged:(NSNotification*)aNotification
{
	short i;
	unsigned short theMask = [model onlineMask];
	for(i=0;i<[model numberOfChannels];i++){
		[[onlineMaskMatrix cellWithTag:i] setIntValue:(theMask&(1<<i))!=0];
	}
}

- (void) writeValueChanged:(NSNotification*) aNotification
{
	//  Set value of both text and stepper
	[self updateStepper:writeValueStepper setting:[model writeValue]];
	[writeValueTextField setIntValue:[model writeValue]];
}

- (void) selectedRegIndexChanged:(NSNotification*) aNotification
{
	
	//  Set value of popup
	short index = [model selectedRegIndex];
	[self updatePopUpButton:registerAddressPopUp setting:index];
	[self updateRegisterDescription:index];
	
	
	BOOL readAllowed = [model getAccessType:index] == kReadOnly || [model getAccessType:index] == kReadWrite;
	BOOL writeAllowed = [model getAccessType:index] == kWriteOnly || [model getAccessType:index] == kReadWrite;
	
	[basicWriteButton setEnabled:writeAllowed];
	[basicReadButton setEnabled:readAllowed];
	[writeValueTextField setEnabled:writeAllowed];
	[writeValueStepper setEnabled:writeAllowed];
	[channelPopUp setEnabled:index==kHiThresholds || index==kLowThresholds];
    
}

- (void) selectedRegChannelChanged:(NSNotification*) aNotification
{
	[self updatePopUpButton:channelPopUp setting:[model selectedChannel]];
}

#pragma mark •••Actions
- (IBAction) writeValueAction:(id) aSender
{
	[model setWriteValue:[aSender intValue]];
}
- (IBAction) selectRegisterAction:(id) aSender
{
	[model setSelectedRegIndex:[aSender indexOfSelectedItem]]; // set new value
}

- (IBAction) selectChannelAction:(id) aSender
{
	[model setSelectedChannel:[aSender indexOfSelectedItem]];
}

- (IBAction) lowThresholdAction:(id) sender
{
	[model setLowThreshold:[[sender selectedCell] tag] withValue:[sender intValue]]; 
}

- (IBAction) highThresholdAction:(id) sender
{
    if ([sender intValue] != [model highThreshold:[[sender selectedCell] tag]]){
        [model setHighThreshold:[[sender selectedCell] tag] withValue:[sender intValue]]; 
    }
}

- (IBAction) read:(id) pSender
{
	@try {
		[self endEditing];		// Save in memory user changes before executing command.
		[model read];
    }
	@catch(NSException* localException) {
        NSRunAlertPanel([localException name], @"%@\nRead of %@ failed", @"OK", nil, nil,
                        localException,[model getRegisterName:[model selectedRegIndex]]);
    }
}

- (IBAction) write:(id) pSender
{
	@try {
		[self endEditing];		// Save in memory user changes before executing command.
		[model write];
    }
	@catch(NSException* localException) {
        NSRunAlertPanel([localException name], @"%@\nWrite to %@ failed", @"OK", nil, nil,
                        localException,[model getRegisterName:[model selectedRegIndex]]);
    }
}

- (IBAction) onlineAction:(id)sender
{
	if([sender intValue] != [model onlineMaskBit:[[sender selectedCell] tag]]){
		[model setOnlineMaskBit:[[sender selectedCell] tag] withValue:[sender intValue]];
	}
}

- (IBAction) readThresholds:(id) sender
{
	@try {
		[self endEditing];
		[model readThresholds];
		[model logThresholds];
    }
	@catch(NSException* localException) {
        NSLog(@"Read of %@ thresholds FAILED.\n",[model identifier]);
        NSRunAlertPanel([localException name], @"%@\nFailed Reading Thresholds", @"OK", nil, nil,
                        localException);
    }
}

- (IBAction) writeThresholds:(id) pSender
{
	@try {
		[self endEditing];
		[model writeThresholds];
    }
	@catch(NSException* localException) {
        NSLog(@"Write of %@ thresholds FAILED.\n",[model identifier]);
        NSRunAlertPanel([localException name], @"%@\nFailed Writing Thresholds", @"OK", nil, nil,
                        localException);
    }
}

- (IBAction) basicLockAction:(id)sender
{
    [gSecurity tryToSetLock:ORCaen965BasicLock to:[sender intValue] forWindow:[self window]];
}

- (void) populatePullDown
{
    short	i;
	
	// Clear all the popup items.
    [registerAddressPopUp removeAllItems];
    [channelPopUp removeAllItems];
    
	// Populate the register popup
    for (i = 0; i < [model getNumberRegisters]; i++) {
        [registerAddressPopUp insertItemWithTitle:[model 
												   getRegisterName:i] 
										  atIndex:i];
    }
    
	// Populate the channel popup
    for (i = 0; i < [model numberOfChannels]; i++) {
        [channelPopUp insertItemWithTitle:[NSString stringWithFormat:@"%d", i] 
								  atIndex:i];
    }
	
    [channelPopUp insertItemWithTitle:@"All" atIndex:[model numberOfChannels]];
	
    [self selectedRegIndexChanged:nil];
	
}
- (void) updateRegisterDescription:(short) aRegisterIndex
{
    NSString* types[] = {
		@"[ReadOnly]",
		@"[WriteOnly]",
		@"[ReadWrite]"
    };
	
    [registerOffsetTextField setStringValue:
	 [NSString stringWithFormat:@"0x%04x",
	  [model getAddressOffset:aRegisterIndex]]];
	
    [registerReadWriteTextField setStringValue:types[[model getAccessType:aRegisterIndex]]];
    [regNameField setStringValue:[model getRegisterName:aRegisterIndex]];
	
    [drTextField setStringValue:[model dataReset:aRegisterIndex] ? @"Y" :@"N"];
    [srTextField setStringValue:[model swReset:aRegisterIndex]   ? @"Y" :@"N"];
    [hrTextField setStringValue:[model hwReset:aRegisterIndex]   ? @"Y" :@"N"];    
}

- (void)tabView:(NSTabView *)aTabView didSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
    if([tabView indexOfTabViewItem:tabViewItem] == 0){
		[[self window] setContentView:blankView];
		[self resizeWindowToSize:settingSize];
		[[self window] setContentView:tabView];
    }
    else if([tabView indexOfTabViewItem:tabViewItem] == 1){
		[[self window] setContentView:blankView];
		[self resizeWindowToSize:thresholdSize];
		[[self window] setContentView:tabView];
    }
	
    NSString* key = [NSString stringWithFormat: @"orca.ORCaenCard%d.selectedtab",[model slot]];
    int index = [tabView indexOfTabViewItem:tabViewItem];
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:key];
	
}

@end
