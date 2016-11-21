/*********************************************************************************************
 *   __      __   _         _________     _ _     _    _________   __         _         __   *
 *	 \ \    / /  | |        | _______|   | | \   | |  |  ______ |  \ \       / \       / /   *
 *	  \ \  / /   | |        | |          | |\ \  | |  | |     | |   \ \     / \ \     / /    *
 *     \ \/ /    | |        | |______    | | \ \ | |  | |     | |    \ \   / / \ \   / /     *
 *     /\/\/\    | |        |_______ |   | |  \ \| |  | |     | |     \ \ / /   \ \ / /      *
 *    / /  \ \   | |______   ______| |   | |   \ \ |  | |_____| |      \ \ /     \ \ /       *
 *   /_/    \_\  |________| |________|   |_|    \__|  |_________|       \_/       \_/        *
 *                                                                                           *
 *********************************************************************************************/

#import "XLsn0wPictureCacher.h"

#import "UIImageView+WebCache.h"
#import "UIButton+WebCache.h"
#import "SDImageCache.h"

@interface XLsn0wPictureCacher ()

@property (nonatomic, strong) NSString *XLsn0wCacherPath;

@end

@implementation XLsn0wPictureCacher

/**************************************************************************************************/
static XLsn0wPictureCacher *instance = nil;
+ (XLsn0wPictureCacher *)defaultCacher {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
/**************************************************************************************************/

- (void)xl_setCacheImageView:(UIImageView *)imageView imageURL:(NSString *)imageURL imageKey:(NSString *)imageKey {
//    [imageView setShowActivityIndicatorView:YES];
//    [imageView setIndicatorStyle:UIActivityIndicatorViewStyleGray];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [imageView sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil];
    
    [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:imageKey toDisk:YES];// 缓存图片
    }];
    // 从缓存取图片并显示
    UIImage *cacheImage = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:imageKey];
    [imageView setImage:cacheImage];
}

/**************************************************************************************************/

- (void)xl_setCacheImageButton:(UIButton *)imageButton imageURL:(NSString *)imageURL imageKey:(NSString *)imageKey {
    [imageButton sd_setImageWithURL:[NSURL URLWithString:imageURL] forState:(UIControlStateNormal) placeholderImage:nil];
    
    [[SDWebImageManager sharedManager].imageDownloader downloadImageWithURL:[NSURL URLWithString:imageURL] options:SDWebImageDownloaderContinueInBackground progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        
    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
        [[SDWebImageManager sharedManager].imageCache storeImage:image forKey:imageKey toDisk:YES];//缓存图片
    }];
    // 从缓存取图片并显示
    UIImage *cacheImage = [[SDWebImageManager sharedManager].imageCache imageFromDiskCacheForKey:imageKey];
    [imageButton setImage:cacheImage forState:(UIControlStateNormal)];
}

@end
