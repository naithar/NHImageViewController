//
//  NHImageViewController.h
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import <UIKit/UIKit.h>

@interface NHImageViewController : UIViewController

@property (strong, readonly, nonatomic) UIButton *closeButton;
@property (strong, readonly, nonatomic) UIButton *menuButton;

@property (strong, readonly, nonatomic) UILabel *noteLabel;

+ (void)showImage:(UIImage*)image inViewController:(UIViewController*)controller;

@end
