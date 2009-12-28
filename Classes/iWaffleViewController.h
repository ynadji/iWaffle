//
//  iWaffleViewController.h
//  iWaffle
//
//  Created by Yacin Nadji on 12/13/09.
//  Copyright Georgia Institute of Technology 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

//#undef __OPTIMIZE__
#define __OPTIMIZE__

#ifndef __OPTIMIZE__
#    define NSLog(...) NSLog(__VA_ARGS__)
#else
#    define NSLog(...) {}
#endif

#define OPEN_URL 0
#define COPY_URL 1

#define IMAGE_VIEW_WIDTH 279
#define IMAGE_VIEW_HEIGHT 357

#define PICK_PHOTO 0

#define MAX_IMAGE_SIZE 1048576

@interface iWaffleViewController : UIViewController <UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UIActionSheetDelegate> {
	UIImage *image;
  UIImagePickerController *pick;
  NSData *imageData;
  
  IBOutlet UIImageView *imageView;
  IBOutlet UIButton *pickPhotoButton;
  IBOutlet UIButton *uploadButton;
  IBOutlet UIProgressView *uploadProgress;
  IBOutlet UIActivityIndicatorView *spinner;
  
  NSURL *uploadedImageUrl;
  BOOL captureUrl;
}

@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) UIImageView *imageView;
@property (retain, nonatomic) UIButton *pickPhotoButton;
@property (retain, nonatomic) UIButton *uploadButton;
@property (retain, nonatomic) NSURL *uploadedImageUrl;
@property (retain, nonatomic) UIProgressView *uploadProgress;
@property (retain, nonatomic) UIActivityIndicatorView *spinner;
@property (retain, nonatomic) UIImagePickerController *pick;
@property BOOL captureUrl;

- (IBAction)pickPhotoPressed:(id)sender;
- (IBAction)uploadPhoto:(id)sender;
- (void)prettifyButton:(UIButton *)button;
- (void)getURL:(NSString *)response;
- (void)resetProgressBar;
- (void)changeButtonEnabled:(BOOL)enabled;

@end

