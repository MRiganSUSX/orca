//--------------------------------------------------------
// ORMJDBiasWatcherController
// Created by Mark  A. Howe on Thursday, Aug 11, 2016
// Code partially generated by the OrcaCodeWizard. Written by Mark A. Howe.
// Copyright (c) 2016 University of North Carolina. All rights reserved.
//-----------------------------------------------------------
//This program was prepared for the Regents of the University of
//North Carolina  sponsored in part by the United States
//Department of Energy (DOE) under Grant #DE-FG02-97ER41020.
//The University has certain rights in the program pursuant to
//the contract and the program should not be copied or distributed
//outside your organization.  The DOE and the University of
//North Carolina reserve all rights in the program. Neither the authors,
//University of North Carolina, or U.S. Government make any warranty,
//express or implied, or assume any liability or responsibility
//for the use of this software.
//-------------------------------------------------------------

#pragma mark ***Imported Files

@class ORCompositeTimeLineView;

@interface ORMJDBiasWatcherController : OrcaObjectController
{
    IBOutlet ORCompositeTimeLineView*	hvPlotter;
    IBOutlet ORCompositeTimeLineView*	baselinePlotter;
    IBOutlet NSTableView*               detectorTableView;
	BOOL                                scheduledToUpdatePlot;
}

#pragma mark ***Initialization
- (id)	 init;
- (void) dealloc;
- (void) awakeFromNib;
- (void) setUpPlots;

#pragma mark ***Notifications
- (void) registerNotificationObservers;
- (void) updateWindow;
- (void) deferredPlotUpdate;

#pragma mark ***Interface Management
- (void) watchChanged:(NSNotification*)aNote;
- (void) updateTable:(NSNotification*)aNote;
- (void) miscAttributesChanged:(NSNotification*)aNote;
- (void) scaleAction:(NSNotification*)aNote;
- (void) updatePlots:(NSNotification*)aNote;


#pragma mark ***Actions
- (IBAction) pollNowAction:(id)sender;

#pragma mark ***DataSource
- (NSColor*) colorForDataSet:(int)set;
- (int) numberPointsInPlot:(id)aPlotter;
- (void) plotter:(id)aPlotter index:(int)i x:(double*)xValue y:(double*)yValue;

@end

