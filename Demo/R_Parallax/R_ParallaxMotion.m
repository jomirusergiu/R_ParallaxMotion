//
//  R_ParallaxMotion.m
//  R_Parallax
//
//  Created by RocKK on 11/22/13.
//  Copyright (c) 2013 RocKK.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms are permitted
//  provided that the above copyright notice and this paragraph are
//  duplicated in all such forms and that any documentation,
//  advertising materials, and other materials related to such
//  distribution and use acknowledge that the software was developed
//  by the RocKK.  The name of the
//  RocKK may not be used to endorse or promote products derived
//  from this software without specific prior written permission.
//  THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR
//  IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED
//  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.

#import "R_ParallaxMotion.h"
#import <objc/runtime.h>

static void * const ParallaxDepthKey = (void*)&ParallaxDepthKey;
static void * const ParallaxMotionEffectGroupKey = (void*)&ParallaxMotionEffectGroupKey;

@implementation UIView (R_ParallaxMotion)

-(void)setParallaxValue:(CGFloat)parallaxDepth
{
    if (self.parallaxValue == parallaxDepth)
        return;
    
    objc_setAssociatedObject(self, ParallaxDepthKey, @(parallaxDepth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    if (![UIInterpolatingMotionEffect class])
        return;
        
    if (parallaxDepth == 0.0)
    {
        [self removeMotionEffect:[self getParallaxMotionEffectGroup]];
        [self setParallaxMotionEffectGroup:nil];
        return;
    }

    UIMotionEffectGroup * parallaxGroup = [self getParallaxMotionEffectGroup];
    if (!parallaxGroup)
    {
        parallaxGroup = [[UIMotionEffectGroup alloc] init];
        [self setParallaxMotionEffectGroup:parallaxGroup];
        [self addMotionEffect:parallaxGroup];
    }
    
    [self setParallaxMotionEffectsToGroup:parallaxGroup withDepth:parallaxDepth];

}

-(void)setParallaxMotionEffectsToGroup:(UIMotionEffectGroup *)parallaxGroup withDepth:(CGFloat)parallaxDepth
{
    UIInterpolatingMotionEffect *xAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    UIInterpolatingMotionEffect *yAxis = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    
    NSArray * motionEffects = @[xAxis, yAxis];
    xAxis.maximumRelativeValue = @(-parallaxDepth/1.5);
    xAxis.minimumRelativeValue = @(parallaxDepth/1.5);
    yAxis.maximumRelativeValue = @(-parallaxDepth);
    yAxis.minimumRelativeValue = @(parallaxDepth);
    
    parallaxGroup.motionEffects = motionEffects;
}

-(CGFloat)parallaxValue
{
    NSNumber * val = objc_getAssociatedObject(self, ParallaxDepthKey);
    if (!val)
        return 0.0;
    return val.doubleValue;
}


-(UIMotionEffectGroup*)getParallaxMotionEffectGroup
{
    return objc_getAssociatedObject(self, ParallaxMotionEffectGroupKey);
}

-(void)setParallaxMotionEffectGroup:(UIMotionEffectGroup*)group
{
    objc_setAssociatedObject(self, ParallaxMotionEffectGroupKey, group, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    NSAssert( group == objc_getAssociatedObject(self, ParallaxMotionEffectGroupKey), @"setting failed" );
}

@end


