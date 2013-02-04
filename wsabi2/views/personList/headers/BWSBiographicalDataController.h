//
//  WSBiographicalDataController.h
//  wsabi2
//
//  Created by Matt Aronoff on 1/30/12.
 
//

#import <UIKit/UIKit.h>
#import "UIView+FirstResponder.h"
#import "WSCDPerson.h"
#import "ELCTextfieldCell.h"
#import "ActionSheetPicker.h"

//These control the order of the table sections
#define kSectionBasic 0 //first, middle, last, other, alias, DOB, POB
#define kSectionGender 1
#define kSectionDescriptive 2 //hair, race, eyes, height, weight
#define kSectionNotes 3

//These control within-section ordering
#define kRowFirstName 0
#define kRowMiddleName 1
#define kRowLastName 2
#define kRowOtherName 3
#define kRowAlias 4
#define kRowDOB 5
#define kRowPOB 6

#define kRowGender 0

#define kRowHair 0
#define kRowRace 1
#define kRowEyes 2
#define kRowHeight 3
#define kRowWeight 4

#define kRowNotes 0

@protocol BWSBiographicalDataDelegate <NSObject>

-(void) didUpdateDisplayName;

@end

@interface BWSBiographicalDataController : UIViewController <UITableViewDataSource, UITableViewDelegate, 
                                                            ELCTextFieldDelegate, UITextFieldDelegate, 
                                                            UITextViewDelegate>
{
    NSMutableArray *aliases;
    NSMutableArray *datesOfBirth;
    NSMutableArray *placesOfBirth;
    
    NSArray *genderStrings;
    NSArray *hairColorStrings;
    NSArray *raceStrings;
    NSArray *eyeColorStrings;

}

-(void) keyboardDidShow:(NSNotification*)notification;

-(void) dobSelected:(NSDate *)selectedDate element:(id)element;
-(void) genderSelected:(NSNumber *)selectedIndex element:(id)element;
-(void) hairColorSelected:(NSNumber *)selectedIndex element:(id)element;
-(void) raceSelected:(NSNumber *)selectedIndex element:(id)element;
-(void) eyeColorSelected:(NSNumber *)selectedIndex element:(id)element;

- (IBAction)tappedBehindView:(UITapGestureRecognizer *)sender;

@property (nonatomic, strong) WSCDPerson *person;
@property (nonatomic, strong) IBOutlet UITableView *bioDataTable;

@property (nonatomic, unsafe_unretained) id<BWSBiographicalDataDelegate> delegate;

@property (nonatomic, strong) IBOutlet UITapGestureRecognizer *tapBehindViewRecognizer;
@property (nonatomic, assign) UIPopoverController *popoverController;

@end
