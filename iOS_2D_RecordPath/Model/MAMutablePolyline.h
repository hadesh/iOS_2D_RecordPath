//
//  MAMutablePolyline.h
//  officialDemo2D
//
//  Created by PC on 15/7/15.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAOverlay.h>

@interface MAMutablePolyline : NSObject<MAOverlay>

/* save MAMapPoints by NSValue */
@property (nonatomic, strong) NSMutableArray *pointArray;

- (instancetype)initWithPoints:(NSArray *)nsvaluePoints;

- (MAMapRect)showRect;

- (MAMapPoint)mapPointForPointAt:(NSUInteger)index;

- (void)updatePoints:(NSArray *)points;

- (void)appendPoint:(MAMapPoint)point;

@end
