/*
 *  LGAnnouncementDelegate.h
 *  LostMonsters
 *
 *  Created by Jeff Cates on 6/28/11.
 *  Copyright 2011 leftygames. All rights reserved.
 *
 */

/***PROTOCOL FOR OUR BEHAVIOR***/
@protocol AnnouncementDelegate

//these are all optional
@required

//one simple method to show announcements from an array of strings
//rest is up to the handler
-(void) showAnnouncements:(NSArray *) announcementList;

@end
