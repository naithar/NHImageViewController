//
//  NHImageScrollView.m
//  Pods
//
//  Created by Sergey Minakov on 08.05.15.
//
//

#import "NHImageScrollView.h"

@interface NHImageScrollView ()<UIScrollViewDelegate>


@property (nonatomic, strong) UIImageView *contentView;

@end

@implementation NHImageScrollView

- (instancetype)init {
    self = [super init];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        [self commonInit];
    }

    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andImage:(UIImage*)image {
    self = [super initWithFrame:frame];

    if (self) {
        self.image = image;
        [self commonInit];
    }

    return self;
}

- (void)commonInit {

    self.delegate = self;
    self.contentView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.contentView.image = self.image;
    self.contentView.contentMode = UIViewContentModeScaleAspectFit;
    self.contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.contentView];

    [self sizeContent];
}


- (void)layoutSubviews {
    [self setZoomScale:1 animated:YES];
    [super layoutSubviews];
    [self sizeContent];
    [self layoutIfNeeded];
}

- (void)sizeContent {
    [self.contentView sizeToFit];

    CGRect bounds = self.contentView.frame;

    CGFloat ratio = bounds.size.width / MAX(bounds.size.height, 1);

    if (ratio != 1) {
        if (self.frame.size.height > self.frame.size.width) {
            bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height);
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = MIN(self.bounds.size.width, self.bounds.size.height);
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    else {
        bounds.size.width = MIN(self.bounds.size.width, self.bounds.size.height);
        bounds.size.width -= 10;
        bounds.size.height = bounds.size.width;
    }

    self.contentView.frame = bounds;
    self.contentView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);

    [self scrollViewDidZoom:self];
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView.zoomScale == self.minimumZoomScale) {
        self.contentInset = UIEdgeInsetsZero;
        return;
    }

    CGSize zoomedSize = self.contentView.bounds.size;
    zoomedSize.width *= self.zoomScale;
    zoomedSize.height *= self.zoomScale;

    CGFloat verticalOffset = 0;
    CGFloat horizontalOffset = 0;

    if (zoomedSize.width < self.bounds.size.width) {
        horizontalOffset = (self.bounds.size.width - zoomedSize.width) / 2.0;
    }

    if (zoomedSize.height < self.bounds.size.height) {
        verticalOffset = (self.bounds.size.height - zoomedSize.height) / 2.0;
    }

    self.contentInset = UIEdgeInsetsMake(verticalOffset - self.contentView.frame.origin.y,
                                                    horizontalOffset - self.contentView.frame.origin.x,
                                                    verticalOffset + self.contentView.frame.origin.y,
                                                    horizontalOffset + self.contentView.frame.origin.x);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.contentView;
}


@end