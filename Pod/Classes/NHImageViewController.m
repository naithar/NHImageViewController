//
//  NHImageViewController.m
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import "NHImageViewController.h"
#import "NHImageScrollView.h"

@interface NHImageViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign) UIModalPresentationStyle parentPresentationStyle;

@property (nonatomic, copy) NSString *note;
@property (nonatomic, strong) NSArray *imagesArray;

@property (nonatomic, strong) UIScrollView *pageScrollView;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) NSInteger pages;

@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, assign) CGPoint panGestureStartPoint;

@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *optionsButton;

@property (strong, nonatomic) UILabel *noteLabel;

@property (nonatomic, assign) CGFloat pageSpacing;

@property (nonatomic, assign) BOOL interfaceHidden;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UITapGestureRecognizer *doubleTapGesture;
@end

@implementation NHImageViewController

- (void)viewDidLoad {

     [super viewDidLoad];

    _interfaceHidden = NO;
    self.view.backgroundColor = [UIColor blackColor];

    self.pages = self.imagesArray.count;
    self.currentPage = 0;
    if (self.pageSpacing == 0) {
        self.pageSpacing = 5;
    }

    self.pageScrollView = [[UIScrollView alloc] initWithFrame:UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, -self.pageSpacing, 0, -self.pageSpacing))];
    self.pageScrollView.backgroundColor = [UIColor clearColor];
    self.pageScrollView.pagingEnabled = YES;
    self.pageScrollView.alwaysBounceHorizontal = NO;
    self.pageScrollView.delegate = self;
    self.pageScrollView.showsHorizontalScrollIndicator = NO;
    self.pageScrollView.showsVerticalScrollIndicator = NO;

    [self.view addSubview:self.pageScrollView];

    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.pages * self.pageScrollView.bounds.size.width, self.view.bounds.size.height)];

    self.contentView.backgroundColor = [UIColor clearColor];

    [self.pageScrollView addSubview:self.contentView];

    for (int i = 0; i < self.imagesArray.count; i++) {
        NHImageScrollView *scrollView = [[NHImageScrollView alloc] initWithFrame:CGRectMake(self.pageSpacing * (i + 1) + (self.view.bounds.size.width + self.pageSpacing) * i, 0, self.view.bounds.size.width, self.view.bounds.size.height) andImage:self.imagesArray[i]];

        [self.contentView addSubview:scrollView];
    }
    

    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    self.panGesture.delegate = self;
    [self.pageScrollView addGestureRecognizer:self.panGesture];

    self.doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGestureAction:)];
    self.doubleTapGesture.numberOfTapsRequired = 2;
    [self.pageScrollView addGestureRecognizer:self.doubleTapGesture];

    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    self.tapGesture.numberOfTapsRequired = 1;
    [self.tapGesture requireGestureRecognizerToFail:self.doubleTapGesture];
    [self.tapGesture requireGestureRecognizerToFail:self.panGesture];
    [self.pageScrollView addGestureRecognizer:self.tapGesture];

    self.closeButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 64)];
    self.closeButton.backgroundColor = [UIColor clearColor];
    [self.closeButton setTitle:nil forState:UIControlStateNormal];
    [self.closeButton setImage:[[UIImage imageNamed:@"NHImageView.close.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.closeButton.tintColor = [UIColor whiteColor];
    [self.view addSubview:self.closeButton];


    self.optionsButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 50, 0, 50, 64)];
    self.optionsButton.backgroundColor = [UIColor clearColor];
    [self.optionsButton setTitle:nil forState:UIControlStateNormal];
    [self.optionsButton setImage:[[UIImage imageNamed:@"NHImageView.more.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self.optionsButton addTarget:self action:@selector(optionsButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.optionsButton.tintColor = [UIColor whiteColor];
    [self.view addSubview:self.optionsButton];

    self.noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height - 64, self.view.bounds.size.width, 64)];
    self.noteLabel.textAlignment = NSTextAlignmentCenter;
    self.noteLabel.text = self.note;
    self.noteLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    self.noteLabel.numberOfLines = 2;
    self.noteLabel.textColor = [UIColor whiteColor];
    self.noteLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    self.noteLabel.hidden = self.note == nil || [self.note length] == 0;

    [self.view addSubview:self.noteLabel];
}

- (void)closeButtonAction:(UIButton*)button {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)optionsButtonAction:(UIButton*)button {

}

- (void)doubleTapGestureAction:(UITapGestureRecognizer*)recognizer {

    NHImageScrollView *currentPage = ((NHImageScrollView*)[[self contentView] subviews][self.currentPage]);

    if (currentPage.zoomScale > 1.5) {
        [currentPage setZoomScale:1 animated:YES];
    }
    else {
        CGPoint location = [recognizer locationInView:currentPage.contentView];

        [currentPage zoomToPoint:location andScale:5];
    }

}

- (void)tapGestureAction:(UITapGestureRecognizer*)recognizer {
    if (self.interfaceHidden) {
        [self displayInterface];
    }
    else {
        [self hideInterface];
    }
}

- (void)hideInterface {
    if (self.interfaceHidden) {
        return;
    }

    self.interfaceHidden = YES;
    CGRect closeButtonFrame = self.closeButton.frame;
    closeButtonFrame.origin.y = -64;

    CGRect menuButtonFrame = self.optionsButton.frame;
    menuButtonFrame.origin.y = -64;

    CGRect noteLabelFrame = self.noteLabel.frame;
    noteLabelFrame.origin.y = self.view.frame.size.height;

    [UIView animateWithDuration:0.2 animations:^{
        self.closeButton.frame = closeButtonFrame;
        self.optionsButton.frame = menuButtonFrame;
        self.noteLabel.frame = noteLabelFrame;
    }];
}

- (void)displayInterface {
    if (!self.interfaceHidden) {
        return;
    }

    self.interfaceHidden = NO;
    CGRect closeButtonFrame = CGRectMake(0, 0, 50, 64);

    CGRect menuButtonFrame = CGRectMake(self.view.bounds.size.width - 50, 0, 50, 64);

    CGRect noteLabelFrame = CGRectMake(0, self.view.bounds.size.height - 64, self.view.bounds.size.width, 64);

    [UIView animateWithDuration:0.2 animations:^{
        self.closeButton.frame = closeButtonFrame;
        self.optionsButton.frame = menuButtonFrame;
        self.noteLabel.frame = noteLabelFrame;
    }];
}

- (void)panGestureAction:(UIPanGestureRecognizer*)panGesture {
    CGPoint translation = [panGesture translationInView:self.pageScrollView];
//
    if (ABS(translation.x) >= ABS(translation.y)
        && CGPointEqualToPoint(self.panGestureStartPoint, CGPointZero)) {
        panGesture.enabled = NO;
        panGesture.enabled = YES;
        self.pageScrollView.panGestureRecognizer.enabled = YES;
        self.pageScrollView.pinchGestureRecognizer.enabled = YES;
        self.view.backgroundColor = [UIColor blackColor];
        self.pageScrollView.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
        self.panGestureStartPoint = CGPointZero;
        return;
    }

    CGPoint velocity = [panGesture velocityInView:self.pageScrollView];

    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            self.panGestureStartPoint = self.pageScrollView.center;
        case UIGestureRecognizerStateChanged: {

            [self hideInterface];

            self.pageScrollView.panGestureRecognizer.enabled = NO;
            self.pageScrollView.pinchGestureRecognizer.enabled = NO;

            self.pageScrollView.center = CGPointMake(self.panGestureStartPoint.x, self.panGestureStartPoint.y + translation.y);

            CGFloat value = ABS(self.view.bounds.size.height / 2.0 - self.pageScrollView.center.y) / (self.view.bounds.size.height / 2.0) / 3.0;


            self.view.backgroundColor = [self.view.backgroundColor colorWithAlphaComponent:1 - value];
        } break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:

            self.pageScrollView.panGestureRecognizer.enabled = YES;
            self.pageScrollView.pinchGestureRecognizer.enabled = YES;

            if (ABS(velocity.y) > 800) {
                [UIView animateWithDuration:0.3
                                      delay:0
                                    options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionNone
                                 animations:^{
                                     self.pageScrollView.center = CGPointMake(self.panGestureStartPoint.x,
                                                                          1.5 * self.pageScrollView.frame.size.height * (velocity.y < 0 ? -1 : 1));
                                 } completion:^(BOOL finished) {
                                     [self dismissViewControllerAnimated:YES completion:nil];
                                 }];


            }
            else {
                if (self.pageScrollView.center.y < 0) {
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         self.pageScrollView.center = CGPointMake(self.panGestureStartPoint.x,
                                                                              -1.5 * self.pageScrollView.frame.size.height);
                                     } completion:^(BOOL finished) {
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     }];
                }
                else if (self.pageScrollView.center.y > self.view.bounds.size.height) {
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         self.pageScrollView.center = CGPointMake(self.panGestureStartPoint.x,
                                                                              1.5 * self.pageScrollView.frame.size.height);
                                     } completion:^(BOOL finished) {
                                         [self dismissViewControllerAnimated:YES completion:nil];
                                     }];
                }
                else {
                    [UIView animateWithDuration:0.3
                                          delay:0
                                        options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionTransitionNone
                                     animations:^{
                                         self.view.backgroundColor = [UIColor blackColor];
                                         self.pageScrollView.center = self.panGestureStartPoint;
                                     } completion:^(BOOL finished) {
                                         [self displayInterface];
                                     }];

                    self.panGestureStartPoint = CGPointZero;
                }
            }
            break;
        default:
            break;
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return gestureRecognizer.view == otherGestureRecognizer.view;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    NSInteger page = self.currentPage;
    
    self.pageScrollView.frame = UIEdgeInsetsInsetRect(self.view.bounds, UIEdgeInsetsMake(0, -self.pageSpacing, 0, -self.pageSpacing));
    self.contentView.frame = CGRectMake(0, 0, self.pages * self.pageScrollView.frame.size.width, self.pageScrollView.frame.size.height);
    self.pageScrollView.contentSize = self.contentView.bounds.size;

    [self.pageScrollView setNeedsDisplay];

    self.closeButton.frame = CGRectMake(0, 0, 50, 64);
    self.optionsButton.frame = CGRectMake(self.view.bounds.size.width - 50, 0, 50, 64);
    self.noteLabel.frame = CGRectMake(0, self.view.bounds.size.height - 64, self.view.bounds.size.width, 64);
    self.pageScrollView.contentOffset = CGPointMake(page * self.pageScrollView.frame.size.width, 0);


    [self.contentView.subviews enumerateObjectsUsingBlock:^(NHImageScrollView *obj, NSUInteger idx, BOOL *stop) {
        [obj setZoomScale:1];
        obj.frame = CGRectMake(self.pageSpacing * (idx + 1) + (self.view.bounds.size.width + self.pageSpacing) * idx, 0, self.view.bounds.size.width, self.view.bounds.size.height);
        [obj sizeContent];
    }];

    [self.view layoutSubviews];
    [self.view layoutIfNeeded];
    [self.view setNeedsDisplay];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = floor((scrollView.contentOffset.x) / scrollView.bounds.size.width);

    if (self.currentPage != page
        && page >= 0
        && page < self.pages) {
        [((NHImageScrollView*)self.contentView.subviews[self.currentPage]) setZoomScale:1 animated:YES];
        self.currentPage = page;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {

    UIViewController *presentingViewController = self.presentingViewController;

    [super dismissViewControllerAnimated:flag completion:^{
        if (completion) {
            completion();
        }

        presentingViewController.modalPresentationStyle = self.parentPresentationStyle;
    }];
}

+ (void)showImage:(UIImage*)image inViewController:(UIViewController*)controller {
    NHImageViewController *imageViewController = [[NHImageViewController alloc] init];
    imageViewController.imagesArray = @[image, image];
    imageViewController.parentPresentationStyle = controller.modalPresentationStyle;
    controller.modalPresentationStyle = UIModalPresentationCurrentContext;
    imageViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    imageViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    imageViewController.note = @"note";

    [controller presentViewController:imageViewController animated:YES completion:nil];

}

@end
