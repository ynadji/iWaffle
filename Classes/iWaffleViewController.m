//
//  iWaffleViewController.m
//  iWaffle
//
//  Created by Yacin Nadji on 12/13/09.
//  Copyright Georgia Institute of Technology 2009. All rights reserved.
//

// TODO: handle camera stuff

#import "iWaffleViewController.h"
#import "ASIFormDataRequest.h"
#import "UIImage+Resize.h"

@implementation iWaffleViewController

@synthesize image;
@synthesize imageView;
@synthesize pickPhotoButton;
@synthesize uploadButton;
@synthesize uploadedImageUrl;
@synthesize captureUrl;
@synthesize uploadProgress;
@synthesize spinner;
@synthesize pick;

/**
 * Prettify dem buttons!
 */
- (void)viewDidLoad {
  [self prettifyButton:pickPhotoButton];
  [self prettifyButton:uploadButton];
}

/**
 * Given a button, makes it pretty using the stretchable images.
 */
- (void)prettifyButton:(UIButton *)button {
  UIImage *buttonImageNormal = [UIImage imageNamed:@"whiteButton.png"];
  UIImage *stretchableButtonImageNormal = [buttonImageNormal
                                           stretchableImageWithLeftCapWidth:12 topCapHeight:0];
  [button setBackgroundImage:stretchableButtonImageNormal
                               forState:UIControlStateNormal];
  
  UIImage *buttonImagePressed = [UIImage imageNamed:@"blueButton.png"];
  UIImage *stretchableButtonImagePressed = [buttonImagePressed
                                            stretchableImageWithLeftCapWidth:12 topCapHeight:0];
  [button setBackgroundImage:stretchableButtonImagePressed
                               forState:UIControlStateHighlighted];
}

/**
 * Brings up UIImagePickerController
 */
- (IBAction)pickPhotoPressed:(id)sender {
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    // do stuff for camera, basically, ask user which they want to do and go from there
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@""
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Choose Existing Media",@"Take Photo",nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
  } else {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@""
                                  delegate:self
                                  cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"Choose Existing Media",nil];
    [actionSheet showInView:self.view];
    [actionSheet release];
  }
}

/**
 * Action sheet delegate for media choice action sheet.
 */
- (void)actionSheet:(UIActionSheet *)actionSheet
didDismissWithButtonIndex:(NSInteger)buttonIndex {
  NSLog(@"didDismissWithButtonIndex: %d", buttonIndex); 
  
  // image picker
  if (pick == nil)
    pick = [[UIImagePickerController alloc] init];
  pick.delegate = self;
  
  // determine the image source type
  if (buttonIndex == [actionSheet cancelButtonIndex]) {
    // if we cancelled, just go back to main screen
    NSLog(@"cancelled image selection...");
    [self dismissModalViewControllerAnimated:YES];
    return;
  } else if (buttonIndex == PICK_PHOTO) {
    pick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    NSLog(@"picking from photo library...");
  } else {
    pick.sourceType = UIImagePickerControllerSourceTypeCamera;
    NSLog(@"picking from camera...");
  }
  
  [self presentModalViewController:pick animated:YES];
}

/**
 * Grabs/resizes image for display and upload, sets `image' and `imageData' instance
 * variables for use during upload. You could make it more clear that the image is
 * being resized at this point for future versions.
 */
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  // Get image data and resize image to under 1 MB
  float compressionLevel = 0.9f;
  
  // release memory if we keep taking pictures
  [image release];
  do {
    imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], compressionLevel);
    NSLog(@"image size: %d", [imageData length]);
    compressionLevel -= 0.1;
  } while ([imageData length] > MAX_IMAGE_SIZE);
  image = [[UIImage alloc] initWithData:imageData];
  NSLog(@"image retain count: %d", [image retainCount]);
  imageView.image = [image imageByScalingProportionallyToSize:[imageView bounds].size];
  
  [picker dismissModalViewControllerAnimated:YES];
  [picker resignFirstResponder];
}

/**
 * Uploads the image stored in imageData.
 */
- (IBAction)uploadPhoto:(id)sender {
  NSLog(@"upload photo...");
  
  // disable buttons
  [self changeButtonEnabled:NO];

  // keeping this here in case I want to use this code again
  /*
  [spinner setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
	[imageView addSubview:spinner];
  [imageView bringSubviewToFront:spinner];
  [spinner setHidden:NO];
  [spinner startAnimating];
   */
  
  // so, the animation only starts _after_ the image has been resized for some reason...
  //[spinner stopAnimating];
  
  if (imageData != nil) {
    // show progress bar
    [uploadProgress setHidden:NO];
    [uploadProgress setProgress:0.0];
    
    // ASIHTTP request information
    NSURL *url = [NSURL URLWithString:@"http://waffleimages.com/upload"];
    ASIFormDataRequest *request = [[[ASIFormDataRequest alloc] initWithURL:url] autorelease];
    [request setPostValue:@"file" forKey:@"mode"];
    [request addRequestHeader:@"User-Agent" value:@"iWaffle-iPhone-1.0"];
    [request addRequestHeader:@"Accept" value:@"text/xml"];
    [request setUploadProgressDelegate:uploadProgress];
    [request setDelegate:self];
    [request setData:imageData withFileName:@"photo.jpg" andContentType:@"image/jpeg" forKey:@"file"];
    [request setDidFailSelector:@selector(requestWentWrong:)];
    [request startAsynchronous];
  } else {
    NSLog(@"No image data found!");
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"No Image Selected"
                          message:@"Select and image and try again."
                          delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil];
    
    [alert show];
    [alert release];
    
    [self changeButtonEnabled:YES];
  }
}

/**
 * Disables/enables the buttons. Used during upload so the user doesn't screw it up.
 */
- (void)changeButtonEnabled:(BOOL)enabled {
  [pickPhotoButton setEnabled:enabled];
  [uploadButton setEnabled:enabled];
}

/**
 * Successful request. Parses out URL and prompts the user to
 * either open the URL in Safari, or copies it to the clipboard.
 */
- (void)requestFinished:(ASIHTTPRequest *)request {
  NSString *response = [request responseString];
  NSLog(@"response: %@", response);
  [self getURL:response];
  NSLog(@"image url: %@", [uploadedImageUrl absoluteString]);
  
  [self resetProgressBar];
  
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:@"Success!"
                        message:@"Image uploaded successfully!"
                        delegate:self
                        cancelButtonTitle:@"Open URL"
                        otherButtonTitles:@"Copy URL",nil];
  
  [alert show];
  [alert release];
  
  // enable buttons
  [self changeButtonEnabled:YES];
}

/**
 * Upload failure delegate. Try again!
 */
- (void)requestFailed:(ASIHTTPRequest *)request {
  // we don't use error if we define __OPTIMIZE__
  // to remove NSLog's
  NSError *error = [request error];
  NSLog(@"error: %@", error);
  
  [self resetProgressBar];
  
  UIAlertView *alert = [[UIAlertView alloc]
                        initWithTitle:@"Upload Failed"
                        message:@"Check your data/internet connection and try again."
                        delegate:self
                        cancelButtonTitle:@"OK"
                        otherButtonTitles:nil];
  
  [alert show];
  [alert release];
  
  // enable buttons
  [self changeButtonEnabled:YES];
}

/**
 * Resets the progress bar to its initial state.
 */
- (void)resetProgressBar {
  [uploadProgress setHidden:YES];
  [uploadProgress setProgress:0.0];
}

/**
 * Alert view after successful upload. Opens the URL in Safari or
 * copies it to the clipboard.
 */
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
  if (buttonIndex == OPEN_URL)
    [[UIApplication sharedApplication] openURL:uploadedImageUrl];
  else if (buttonIndex == COPY_URL)
    [[UIPasteboard generalPasteboard] setURL:uploadedImageUrl];
}

/**
 * getURL starts up the XML parser to retrieve the url of the uploaded
 * image from <imageurl></imageurl>. This seems pretty ugly, there's got
 * to be a better way to do this.
 */
- (void)getURL:(NSString *)response {
  NSXMLParser *parser = [[NSXMLParser alloc] initWithData:[response dataUsingEncoding:NSUTF8StringEncoding]];
  captureUrl = NO;
  
  [parser setDelegate:self];
  [parser setShouldProcessNamespaces:NO];
  [parser setShouldReportNamespacePrefixes:NO];
  [parser setShouldResolveExternalEntities:NO];
  
  [parser parse];
  
  [parser release];
}

/**
 * If we hit the <imageurl> element, we want to begin capturing
 * the characters (which will be the URL).
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
  NSLog(@"start elementName: %@", elementName);
  if ([elementName isEqualToString:@"imageurl"])
    captureUrl = YES;
}

/**
 * Stop capturing characters.
 */
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  NSLog(@"end elementName: %@", elementName);
  if ([elementName isEqualToString:@"imageurl"])
    captureUrl = NO;
}

/**
 * If we've seen <imageurl>, store the found characters as our URL.
 */
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  NSLog(@"foundCharacters: %@", string);
  if (captureUrl) {
    NSLog(@"captureUrl is true. foundCharacters: %@", string);
    uploadedImageUrl = [NSURL URLWithString:string];
    [uploadedImageUrl retain];
  }
}

/**
 * Delegate for ASIHTTPRequest
 */
- (void)requestWentWrong:(id)sender {
  [self requestFailed:(ASIHTTPRequest *)sender];
}

- (void)didReceiveMemoryWarning {
  NSLog(@"oh snap, memory warning!!!");
	// Releases the view if it doesn't have a superview.
  [super didReceiveMemoryWarning];
  
  image = [image imageByScalingProportionallyToSize:[imageView bounds].size];
	imageView.image = image;
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
  [image release];
  [imageView release];
  [uploadedImageUrl release];
  [pickPhotoButton release];
  [uploadButton release];
  [uploadProgress release];
  [spinner release];
  [pick release];
  [imageData release];
  
  [super dealloc];
}

@end
