//
//  MAMutablePolylineView.m
//  officialDemo2D
//
//  Created by PC on 15/7/15.
//  Copyright (c) 2015年 AutoNavi. All rights reserved.
//

#import "MAMutablePolylineRenderer.h"
#import "MAMutablePolyline.h"

@implementation MAMutablePolylineRenderer

#pragma mark - Override

- (void)drawMapRect:(MAMapRect)mapRect zoomScale:(MAZoomScale)zoomScale inContext:(CGContextRef)context
{
    MAMutablePolyline *polyline = (MAMutablePolyline *)self.overlay;
    
    if (polyline == nil)
    {
        NSLog(@"polyline is nil");
        return;
    }
    
    //绘制path
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    CGContextSetLineWidth(context, 4.0 / zoomScale);

    NSUInteger count = polyline.pointArray.count;
    if (count > 0)
    {
        CGPoint point = [self pointForMapPoint:[polyline mapPointForPointAt:0]];
        CGContextMoveToPoint(context, point.x, point.y);
    }
    
    for (int i = 1; i < count; i++)
    {
        CGPoint point = [self pointForMapPoint:[polyline mapPointForPointAt:i]];
        CGContextAddLineToPoint(context, point.x, point.y);
    }

    CGContextDrawPath(context, kCGPathStroke);
}


@end
