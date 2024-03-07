//
//  RootViewController.h
//  Tilemap
//
//  Created by Steffen Itterheim on 05.10.10.
//  Copyright Steffen Itterheim 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenFeint/OFTimeStamp.h"
#import "OpenFeint/OFGameFeedSettings.h"

//TODO: move OpenFeint out of this file only into LGSocialGamer
#import "OpenFeint/OFHighScoreService.h"
#import "OpenFeint/OFCloudStorageService.h"
#import "OpenFeint/OFAnnouncement.h"

#ifdef __IPHONE_4_1
#import "OpenFeint/OpenFeint+GameCenter.h"
#import "GameKit/GameKit.h"
#endif


#import "OpenFeint/OpenFeint.h"
#import "OpenFeint/OFGameFeedView.h"
#import "OpenFeint/OpenFeint+NSNotification.h"
#import "OpenFeint/UIButton+OpenFeint.h"
#import "OpenFeint/OpenFeint+Private.h"
#import "OpenFeint/OFSettings.h"


#import "OpenFeint/OFGameFeedView.h"


//#import "GameConfig.h"



@interface RootViewController : UIViewController {
    
    /***OF INTEGRATION***/
    
  //  OFGameFeedAlignment currentGameFeedAlignment;
    
}

//@property (nonatomic, retain) OFGameFeedView* gameFeed;

//game feed testing:
//- (void)setupGameFeedWithAdditionalSettings:(NSDictionary*)additionalSettings;

@end
