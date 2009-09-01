//----------------------------------------------------------
//  ORStatusController.m
//
//  Created by Mark Howe on Wed Jan 02 2002.
//  Copyright  � 2001 CENPA. All rights reserved.
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



#pragma mark ���Forward Declarations
@class ORDataSet;

@interface ORStatusController : NSWindowController <NSOutlineViewDataSource>
{
	IBOutlet NSTabView*     tabView;
    IBOutlet NSTextView*    statusView;  //our view
    IBOutlet NSTextField*   errorField;  //our error count
    IBOutlet NSOutlineView* outlineView;  //our error view

    IBOutlet NSButton*      clearCountsButton;
    IBOutlet NSTextField*   errorTextField;
    IBOutlet NSTextView*    logBookField;
    IBOutlet NSTextField*   logBookPathField;

    IBOutlet NSButton*      saveLogBookButton;

    ORDataSet*              dataSet;
    BOOL                    scheduledToUpdate;
	BOOL					logBookDirty;
	NSString*				logBookFile;

}

#pragma mark ���Accessors
+ (ORStatusController*) sharedStatusController;
- (int) statusTextlength;
- (NSString*) text;
- (void) setDataSet: (ORDataSet *) aDataSet;
- (NSString*) substringWithRange:(NSRange)aRange;
- (void) handleInvocation:(NSInvocation*) anInvocation;
- (void) removeDataSet:(ORDataSet*)item;
- (void) setLogBookFile:(NSString*)aFilePath;

#pragma mark ���Updating
- (void) updateErrorDisplay;
- (NSString*) errorSummary;
- (oneway void) logError:(NSString*)string usingKeyArray:(NSArray*)keys;
- (oneway void) printString: (NSString*)aComment;
- (oneway void) printString: (NSString*)s1 withColor:(NSColor*)aColor;
- (BOOL) validateMenuItem:(NSMenuItem*)menuItem;

#pragma mark ���Data Source Methods
- (BOOL) outlineView:(NSOutlineView*)ov isItemExpandable:(id)item;
- (int)  outlineView:(NSOutlineView*)ov numberOfChildrenOfItem:(id)item;
- (id)   outlineView:(NSOutlineView*)ov child:(int)index ofItem:(id)item;
- (id)   outlineView:(NSOutlineView*)ov objectValueForTableColumn:(NSTableColumn*)tableColumn byItem:(id)item;
- (unsigned)  numberOfChildren;
- (id)   childAtIndex:(int)index;
- (id)   name;

#pragma mark ���Actions
- (IBAction) clearAllAction:(id)sender;
- (IBAction) delete:(id)sender;
- (IBAction) cut:(id)sender;
- (IBAction) selectAll:(id)sender;
- (IBAction) removeItemAction:(id)sender;

- (IBAction) saveLogBook:(id)sender;
- (IBAction) saveAsLogBook:(id)sender;
- (IBAction) loadLogBook:(id)sender;
- (IBAction) newLogBook:(id)sender;

- (IBAction) insertDate:(id)sender;
- (IBAction) insertRunNumber:(id)sender;
- (IBAction) insertConfigurationName:(id)sender;
- (IBAction) mailContent:(id)sender;

- (void) loadCurrentLogBook;

- (void)textDidChange:(NSNotification *)notification;

#pragma mark ���Archival
- (void) decode:(NSCoder*) aDecoder;
- (void) encode:(NSCoder*) anEncoder;

@end

@interface ORPrintableView : NSTextView
- (IBAction) print:(id)sender;
@end

@interface ORPrintableOutlineView : NSOutlineView
- (IBAction) print:(id)sender;
@end


@interface NSProxy (junk)
 - (void) dealloc;
@end

@interface NSProxy (ORStatusController)
- (oneway void) logError:(id)string usingKeyArray:(id)keys;
- (oneway void) printString: (NSString*)aComment;
- (oneway void) printString: (NSString*)s1 withColor:(NSColor*)aColor;
- (oneway void) printString: (NSString*)s1 withFont:(NSFont*)aFont;
@end

extern NSString* ORStatusFlushedNotification;
extern NSString* ORStatusFlushSize;

extern ORStatusController* theLogger;
