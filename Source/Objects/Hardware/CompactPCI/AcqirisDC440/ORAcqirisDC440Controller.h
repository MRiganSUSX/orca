//--------------------------------------------------------
// ORAcqirisDC440Controller
// Created by Mark A. Howe on Fri Jun 22 2007
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2007 CENPA, University of Washington. All rights reserved.
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

#import <Cocoa/Cocoa.h>
#import "OrcaObjectController.h"

@class ORCompositePlotView;
@class ORValueBarGroupView;

@interface ORAcqirisDC440Controller : OrcaObjectController
{
	IBOutlet NSTextField*	numberSamplesField;
	IBOutlet NSMatrix*		enableMaskMatrix;
	IBOutlet NSButton*		readContinouslyButton;
	IBOutlet NSTextField*	triggerLevel2Field;
	IBOutlet NSTextField*	triggerLevel1Field;
	IBOutlet NSPopUpButton*	triggerCouplingPU;
	IBOutlet NSPopUpButton* triggerSourcePU;
	IBOutlet NSPopUpButton*	triggerSlopePU;
	IBOutlet NSPopUpButton*	couplingPU;
	IBOutlet NSTextField*	verticalOffsetField;
	IBOutlet NSPopUpButton*	fullScalePU;
	IBOutlet NSTextField*	delayTimeField;
	IBOutlet NSTextField*	sampleIntervalField;
	IBOutlet NSTextField*	triggerLablel1Field;
	IBOutlet NSTextField*	triggerLablel2Field;
	IBOutlet ORCompositePlotView*	plotter;
	IBOutlet NSTextField*	baseAddressField;
	IBOutlet NSButton*		loadDialogButton;
	IBOutlet NSButton*		readOneButton;
	IBOutlet NSButton*		reportButton;
	IBOutlet NSButton*		initButton;
    IBOutlet NSMatrix*		sampleRateTextFields;
    IBOutlet ORValueBarGroupView*	rate0;
    IBOutlet NSButton*		settingLockButton;
    IBOutlet NSButton*		probeButton;
	IBOutlet NSTextField*	boardIdField;
}

#pragma mark •••Initialization
- (id) init;
- (void) dealloc;
- (void) awakeFromNib;

#pragma mark •••Notifications
- (void) registerNotificationObservers;
- (void) registerRates;
- (void) updateWindow;
- (void) updateButtons;

#pragma mark ***Interface Management
- (void) boardIDChanged:(NSNotification*)aNote;
- (void) settingsLockChanged:(NSNotification*)aNote;
- (void) enableMaskChanged:(NSNotification*)aNote;
- (void) sampleRateChanged:(NSNotification*)aNote;
- (void) readContinouslyChanged:(NSNotification*)aNote;
- (void) slotChanged:(NSNotification*)aNote;
- (void) triggerSlopeChanged:(NSNotification*)aNote;
- (void) triggerLevelChanged:(NSNotification*)aNote;
- (void) triggerCouplingChanged:(NSNotification*)aNote;
- (void) triggerSourceChanged:(NSNotification*)aNote;
- (void) couplingChanged:(NSNotification*)aNote;
- (void) verticalOffsetChanged:(NSNotification*)aNote;
- (void) fullScaleChanged:(NSNotification*)aNote;
- (void) delayTimeChanged:(NSNotification*)aNote;
- (void) numberSamplesChanged:(NSNotification*)aNote;
- (void) sampleIntervalChanged:(NSNotification*)aNote;
- (void) baseAddressChanged:(NSNotification*)aNote;
- (void)  dataChanged:(NSNotification*)aNote;
- (void) connectionChanged:(NSNotification*)aNote;
- (void) settingsLockChanged:(NSNotification*)aNote;
- (void) samplingWaveformsChanged:(NSNotification*)aNote;
- (void) scaleAction:(NSNotification*)aNote;
- (void) miscAttributesChanged:(NSNotification*)aNote;
- (void) sampleRateGroupChanged:(NSNotification*)aNote;

#pragma mark •••Actions
- (IBAction) enableMaskAction:(id)sender;
- (IBAction) readContinouslyAction:(id)sender;
- (IBAction) triggerSlopeAction:(id)sender;
- (IBAction) triggerLevel2FieldAction:(id)sender;
- (IBAction) triggerLevel1FieldAction:(id)sender;
- (IBAction) triggerCouplingAction:(id)sender;
- (IBAction) triggerSourceAction:(id)sender;
- (IBAction) couplingAction:(id)sender;
- (IBAction) verticalOffsetAction:(id)sender;
- (IBAction) fullScalePUAction:(id)sender;
- (IBAction) delayTimeFieldAction:(id)sender;
- (IBAction) numberSamplesAction:(id)sender;
- (IBAction) sampleIntervalAction:(id)sender;
- (IBAction) baseAddressAction:(id)sender;
- (IBAction) probeAction:(id)sender;
- (IBAction) initAction:(id)sender;
- (IBAction) loadDialogAction:(id)sender;
- (IBAction) get1Waveform:(id)sender;
- (IBAction) report:(id)sender;
- (IBAction) settingLockAction:(id) sender;

- (int) numberPointsInPlot:(id)aPlotter;
- (void) plotter:(id)aPlotter index:(int)i x:(double*)xValue y:(double*)yValue;

@end



