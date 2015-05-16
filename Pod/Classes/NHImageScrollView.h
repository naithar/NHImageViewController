//
//  NHImageScrollView.h
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import <UIKit/UIKit.h>
#import <FLAnimatedImage.h>

@interface NHImageScrollView : UIScrollView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic, readonly, assign) BOOL loadingImage;

@property (nonatomic, readonly, strong) FLAnimatedImageView *contentView;

- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage*)image;
- (instancetype)initWithFrame:(CGRect)frame andPath:(NSString*)path;
- (instancetype)initWithFrame:(CGRect)frame image:(UIImage*)image andPath:(NSString*)path;

- (void)loadImage;
- (void)saveImage;
- (void)sizeContent;
- (void)zoomToPoint:(CGPoint)point andScale:(CGFloat)scale;
@end
