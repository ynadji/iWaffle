//
//  UIImage.m
//  iWaffle
//
//  Created by Yacin Nadji on 12/16/09.
//  Copyright 2009 Georgia Institute of Technology. All rights reserved.
//

#import "UIImage+Resize.h"

@implementation UIImage (Resize)

- (UIImage *)imageByScalingProportionallyToSize:(CGSize)targetSize {
  
  UIImage *sourceImage = self;
  UIImage *newImage = nil;
  
  CGSize imageSize = sourceImage.size;
  CGFloat width = imageSize.width;
  CGFloat height = imageSize.height;
  
  CGFloat targetWidth = targetSize.width;
  CGFloat targetHeight = targetSize.height;
  
  CGFloat scaleFactor = 0.0;
  CGFloat scaledWidth = targetWidth;
  CGFloat scaledHeight = targetHeight;
  
  CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
  
  if (CGSizeEqualToSize(imageSize, targetSize) == NO) {
    
    CGFloat widthFactor = targetWidth / width;
    CGFloat heightFactor = targetHeight / height;
    
    if (widthFactor < heightFactor) 
      scaleFactor = widthFactor;
    else
      scaleFactor = heightFactor;
    
    scaledWidth  = width * scaleFactor;
    scaledHeight = height * scaleFactor;
    
    // center the image
    
    if (widthFactor < heightFactor) {
      thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5; 
    } else if (widthFactor > heightFactor) {
      thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
    }
  }
  
  
  // this is actually the interesting part:
  
  UIGraphicsBeginImageContext(targetSize);
  
  CGRect thumbnailRect = CGRectZero;
  thumbnailRect.origin = thumbnailPoint;
  thumbnailRect.size.width  = scaledWidth;
  thumbnailRect.size.height = scaledHeight;
  
  [sourceImage drawInRect:thumbnailRect];
  
  newImage = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  if(newImage == nil) NSLog(@"could not scale image");
  
  return newImage ;
}

@end
