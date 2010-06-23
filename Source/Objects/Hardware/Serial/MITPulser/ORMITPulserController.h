//--------------------------------------------------------
// ORMITPulserController
// Created by Mark  A. Howe on Fri Jul 22 2005
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

#pragma mark ***Imported Files

@interface ORMITPulserController : OrcaObjectController
{
	//pusler variables
	IBOutlet NSTextField*	frequencyField;
	IBOutlet NSStepper*		frequencyStepper;
	IBOutlet NSTextField*	dutyCycleField;
	IBOutlet NSStepper*		dutyCycleStepper;
	IBOutlet NSTextField*	resistanceField;
	IBOutlet NSStepper*		resistanceStepper;
	IBOutlet NSPopUpButton* clockSpeedPU;
	IBOutlet NSPopUpButton* pulserVersionPU;
    IBOutlet NSButton*      loadHwButton;
    IBOutlet NSButton*      onButton;
    IBOutlet NSButton*      offButton;
	
	//serial port and misc fields
    IBOutlet NSTextField*   portStateField;
    IBOutlet NSPopUpButton* portListPopup;
    IBOutlet NSButton*      openPortButton;
    IBOutlet NSButton*      lockButton;
}

#pragma mark ***Initialization
- (id) init;
- (void) awakeFromNib;

#pragma mark ***Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;

#pragma mark ***Interface Management
- (void) frequencyChanged:(NSNotification*)aNote;
- (void) dutyCycleChanged:(NSNotification*)aNote;
- (void) resistanceChanged:(NSNotification*)aNote;
- (void) clockSpeedChanged:(NSNotification*)aNote;
- (void) pulserVersionChanged:(NSNotification*)aNote;
- (void) lockChanged:(NSNotification*)aNotification;
- (void) portNameChanged:(NSNotification*)aNotification;
- (void) portStateChanged:(NSNotification*)aNotification;

#pragma mark ***Actions
- (IBAction) turnPowerOn:(id)sender;
- (IBAction) turnPowerOff:(id)sender;
- (IBAction) loadHWAction:(id)sender;
- (IBAction) frequencyAction:(id)sender;
- (IBAction) dutyCycleAction:(id)sender;
- (IBAction) resistanceAction:(id)sender;
- (IBAction) clockSpeedAction:(id)sender;
- (IBAction) pulserVersionAction:(id)sender;
- (IBAction) portListAction:(id) sender;
- (IBAction) openPortAction:(id)sender;
- (IBAction) lockAction:(id) sender;

@end


