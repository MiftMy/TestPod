//
//  XMBaseViewController.m
//  podAFNetwork
//
//  Created by mifit on 15/9/14.
//  Copyright (c) 2015年 mifit. All rights reserved.
//

#import "XMBaseViewController.h"
#import "XMHttp.h"

@interface XMBaseViewController ()<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
/// 上传url
@property (nonatomic,strong) NSString *uploadURL;
/// 上传参数
@property (nonatomic,strong) NSDictionary *paramter;
/// 图片宽度
@property (nonatomic,assign) NSInteger imageWidth;
/// 获取到图片回调block。image获取到的图片
@property (nonatomic,copy) void (^block)(UIImage *image);
@end

@implementation XMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark - public
- (void)uploadImageFromCamera:(NSString *)url paramers:(NSDictionary *)dic imageWidth:(NSInteger)width completed:(void (^)(UIImage *image))block{
    self.uploadURL = url;
    self.paramter = dic;
    self.block = block;
    self.imageWidth = width;

    UIActionSheet *sheet;
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
        sheet = [[UIActionSheet alloc]initWithTitle:@"获取相片方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相册" otherButtonTitles:@"相机", nil];
    } else{
        sheet = [[UIActionSheet alloc]initWithTitle:@"获取相片方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"相册" otherButtonTitles:nil];
    }
    [sheet showInView:self.view];
}

#pragma mark - private
- (NSString *)savePath{
    if (!_savePath) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *cachesDir = [paths objectAtIndex:0];
        _savePath = [cachesDir stringByAppendingPathComponent:@"tempHeaderPhoto.jpg"];
    }
    return _savePath;
}

- (void)uploadImage{
    dispatch_async(dispatch_get_main_queue(), ^{
        [XMHttp http_Posts:self.uploadURL parameters:self.paramter filePath:self.savePath fileType:@"image" success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"success");
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"error:%@",error);
        }];
    });
    
}

//将UIImage缩放到指定大小尺寸
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}
#pragma mark - action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIImagePickerController *imagePC = [[UIImagePickerController alloc]init];
        imagePC.delegate = self;
        imagePC.allowsEditing = YES;
        switch (buttonIndex) {
            case 0:
                imagePC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                [self presentViewController:imagePC animated:YES completion:nil];
                break;
            case 1:
                imagePC.sourceType = UIImagePickerControllerSourceTypeCamera;
                if([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
                    imagePC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                }
                [self presentViewController:imagePC animated:YES completion:nil];
                break;
            default:
                [actionSheet dismissWithClickedButtonIndex:3 animated:YES];
                break;
        }
    });
}

#pragma mark - imagePickerController delegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    CGSize size;
    if (self.imageWidth > 0) {
        size = CGSizeMake(self.imageWidth, self.imageWidth);
    } else {
        size = CGSizeMake(200, 200);
    }
    UIImage *imageTem = [self scaleToSize:image size:size];
    if (self.block) {
        self.block(imageTem);
    }
    NSString *filePath = [self savePath];
    [UIImageJPEGRepresentation(imageTem, 1.0f) writeToFile:filePath atomically:YES];
    [self uploadImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
