//
//  ResizeBadge.h
//
//  Created by Developer on 10/07/17.
//
//

#import <Foundation/Foundation.h>

@interface ResizeBadge : NSObject

+ (void)resizeBadge:(UILabel *)badge
     totalFreeSpace:(CGFloat)totalFreeSpace
     canTextBeScaled:(BOOL)canTextBeScaled
setBadgeWidthCompletion:(void(^)(CGFloat calculatedWidth))completion;

+(CGFloat)calculatingNeededWidthForBadge:(NSString *)text rangeLength:(NSInteger)rangeLength font:(UIFont *)font;

@end
