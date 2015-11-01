//
//  HomeAR.h
//  HomeAR
//
//  Created by Joel Teply on 10/26/15.
//  Copyright © 2015 Joel Teply. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for HomeAR.
FOUNDATION_EXPORT double HomeARVersionNumber;

//! Project version string for HomeAR.
FOUNDATION_EXPORT const unsigned char HomeARVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <HomeAR/PublicHeader.h>

#ifndef HOMEAUGMENTATION

#define HOMEAUGMENTATION 1

#import <Foundation/Foundation.h>
#import <UIKIt/UIKit.h>

//common
#import <HomeAR/CBDefines.h>
#import <HomeAR/CBImageTypes.h>
#import <HomeAR/CBLicensing.h>
#import <HomeAR/CBThreading.h>

//imaging
#import <HomeAR/CBPrimative.h>
#import <HomeAR/CBImage.h>
#import <HomeAR/CBLayer.h>
#import <HomeAR/CBMask.h>

//painting
#import <HomeAR/CBImagePainter.h>
#import <HomeAR/CBColoring.h>
#import <HomeAR/CBColorFinder.h>

//UI
#import <HomeAR/CBDrawerController.h>
#import <HomeAR/CGRectAdditions.h>

//data
#import <HomeAR/CBCoreData.h>

//video painter
#import <HomeAR/CBVideoTypes.h>
#import <HomeAR/CBVideoDevice.h>
#import <HomeAR/CBVideoPainter.h>

#endif