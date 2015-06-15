/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "ComApaladiniBrightnessModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"

@implementation ComApaladiniBrightnessModule
{
    float _interval;
    float _delay;
    float _level;
    float _busy;
}

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"0a311e93-3d22-4982-b537-a6803c5e4849";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"com.apaladini.brightness";
}

#pragma Public APIs

-(id)getSystemBrightLevel:(id)args
{
	float brightness = [[UIScreen mainScreen] brightness];
	return NUMFLOAT(brightness);
}

-(id)setSystemBrightLevel:(id)args
{
    float f = [TiUtils floatValue:args];
    float answer = ((int)(f * 100 + .5) / 100.0);
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    float oldBrightness = mainScreen.brightness;
    mainScreen.brightness = answer;
    
    return NUMFLOAT(oldBrightness);
}

-(id)setSystemBrightLevelSmooth:(id)args
{
    NSLog(@"args ==> %@", args);
    
    if (_busy) {
        NSLog(@"busy");
        return @"Busy";
    }
    
    _busy = YES;
    
    float level = [TiUtils floatValue:@"level" properties:args def:1.0f];
    _level = ((int)(level * 100 + .5) / 100.0);
    
    UIScreen *mainScreen = [UIScreen mainScreen];
    float oldBrightness = mainScreen.brightness;
    
    _interval = [TiUtils floatValue:@"interval" properties:args def:.01f];
    _delay = [TiUtils floatValue:@"delay" properties:args def:.01f];
    
    
    NSLog(@"_level ==> %f", _level);
    NSLog(@"_delay ==> %f", _delay);
    NSLog(@"_interval ==> %f", _interval);
    
    if (oldBrightness  < _level) {
        [self brightnessIncrease];
    } else if (oldBrightness > level) {
        [self brightnessDecrease];
    } else {
        _busy = NO;
    }
    
    return NUMFLOAT(oldBrightness);
}

- (void)fullBright:(id)sender {
    
    NSLog(@"enter fullbright");
    
    CGFloat brightness = [UIScreen mainScreen].brightness;
    if (brightness < 1) {
        NSLog(@"try fullbright");
        [UIScreen mainScreen].brightness += 0.01;
        [self performSelector:@selector(fullBright:) withObject:nil afterDelay:.01];
    }
}

- (void)brightnessIncrease{
    float brightness = [UIScreen mainScreen].brightness;
    NSLog(@"current brightness => %f", brightness);
    if (brightness < _level) {
        [UIScreen mainScreen].brightness += _interval;
        
        dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delay * NSEC_PER_SEC));
        dispatch_after(dispatchTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self brightnessIncrease];
        });
    } else {
        NSLog(@"finish with current brightness => %f", brightness);
        _busy = NO;
    }
}

- (void)brightnessDecrease{
    CGFloat brightness = [UIScreen mainScreen].brightness;
    NSLog(@"current brightness => %f", brightness);
    if (brightness > _level) {
        [UIScreen mainScreen].brightness -= _interval;
        dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delay * NSEC_PER_SEC));
        dispatch_after(dispatchTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self brightnessDecrease];
        });
    } else {
        NSLog(@"finish with current brightness => %f", brightness);
        _busy = NO;
    }
}

@end
