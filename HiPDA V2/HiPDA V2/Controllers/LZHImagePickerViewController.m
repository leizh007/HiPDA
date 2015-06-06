//
//  LZHImagePickerViewController.m
//  HiPDA V2
//
//  Created by leizh007 on 15/6/6.
//  Copyright (c) 2015年 leizh007. All rights reserved.
//

#import "LZHImagePickerViewController.h"
#import "CTAssetsPickerController.h"
#import "CTAssetsPageViewController.h"
#import "DBCameraViewController.h"
#import "DBCameraContainerViewController.h"
#import "DBCameraLibraryViewController.h"
#import "DBCameraGridView.h"
#import "LZHShowMessage.h"
#import "UIImage+LZHHIPDA.h"
#import "LZHReply.h"

@interface LZHImagePickerViewController ()<UITableViewDelegate,UITableViewDataSource,CTAssetsPickerControllerDelegate,DBCameraViewControllerDelegate>

@property (strong, nonatomic) UISegmentedControl *imageSizeSegmentControll;
@property (strong, nonatomic) UISegmentedControl *cameraLibrarySegmentControl;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *assets;
@property (strong, nonatomic) ALAssetsLibrary *library;
@property (strong, nonatomic) NSMutableArray *imageUploadResponse;
@property (assign, nonatomic) NSInteger totoalFinishedImageNumber;

@end

@implementation LZHImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title=@"选择图片";
    self.view.backgroundColor=[UIColor whiteColor];
    
    UIBarButtonItem *cancelBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"放弃" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.leftBarButtonItem=cancelBarButtonItem;
    
    UIBarButtonItem *sendBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendButtonPressed:)];
    self.navigationItem.rightBarButtonItem=sendBarButtonItem;
    
    _imageSizeSegmentControll=[[UISegmentedControl alloc]initWithItems:@[@"~100kb",@"~200kb",@"~400kb",@"~800kb"]];
    _imageSizeSegmentControll.selectedSegmentIndex=1;
    _imageSizeSegmentControll.frame=CGRectMake(8.0f, [[UIScreen mainScreen]bounds].size.height-36.0f-8, [[UIScreen mainScreen]bounds].size.width-2*8.0f, 36.0f);
    [self.view addSubview:_imageSizeSegmentControll];
    
    _cameraLibrarySegmentControl=[[UISegmentedControl alloc]initWithItems:@[@"拍照",@"照片"]];
    _cameraLibrarySegmentControl.selected=NO;
    _cameraLibrarySegmentControl.frame=CGRectMake(8+_imageSizeSegmentControll.frame.size.width/8, _imageSizeSegmentControll.frame.origin.y-8-_imageSizeSegmentControll.frame.size.height, _imageSizeSegmentControll.frame.size.width*3/4, _imageSizeSegmentControll.frame.size.height);
    [_cameraLibrarySegmentControl addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_cameraLibrarySegmentControl];
    
    _tableView=[[UITableView alloc]init];
    _tableView.frame=CGRectMake(0, 64, [[UIScreen mainScreen]bounds].size.width, _cameraLibrarySegmentControl.frame.origin.y-8.0-64);
    _tableView.delegate=self;
    _tableView.dataSource=self;
    [self.view addSubview:_tableView];
    
    //初始化参数
    _assets=[[NSMutableArray alloc]init];
    _library = [[ALAssetsLibrary alloc] init];
    _imageUploadResponse=[[NSMutableArray alloc]init];
    _totoalFinishedImageNumber=0;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _cameraLibrarySegmentControl.selectedSegmentIndex=-1;
}

#pragma mark - Button Pressed

-(void)cancelButtonPressed:(id)sender{
    __weak typeof(self)weakSelf=self;
    UIAlertController *alert=[UIAlertController alertControllerWithTitle:@"放弃" message:@"是否真的放弃？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [weakSelf.navigationController dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)sendButtonPressed:(id)sender{
    if (_assets.count==0) {
        [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:@"请先选择图片！"];
        return;
    }
    
    [SVProgressHUD showWithStatus:@"压缩图片并上传中..." maskType:SVProgressHUDMaskTypeGradient];

    NSInteger imageFileSize;
    switch (self.imageSizeSegmentControll.selectedSegmentIndex) {
        case 0:
            imageFileSize=100*1000;
            break;
        case 1:
            imageFileSize=200*1000;
            break;
        case 2:
            imageFileSize=400*1000;
            break;
        case 3:
            imageFileSize=800*1000;
            break;
        default:
            break;
    }
    _totoalFinishedImageNumber=0;
    
    __weak typeof(self) weakSelf=self;
    [_assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop) {
        ALAssetRepresentation *representation = [asset defaultRepresentation];
        
        NSData *data=(NSData *)[UIImage imageWithImage:[UIImage imageWithCGImage:representation.fullResolutionImage scale:[representation scale] orientation:(UIImageOrientation)[representation orientation]] scaledToFileSize:imageFileSize];
        [LZHReply uploadImage:data completionHandler:^(NSArray *array, NSError *error) {
            if (error) {
                [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
            }else{
                //NSLog(@"response %@",array[0]);
                [weakSelf.imageUploadResponse addObject:array[0]];
                weakSelf.totoalFinishedImageNumber=weakSelf.totoalFinishedImageNumber+1;
            }
            [SVProgressHUD dismiss];
        }];
    }];
    
}

-(void)segmentAction:(UISegmentedControl *)segementControl
{
    if (segementControl.selectedSegmentIndex==1) {
        if (!self.assets) {
            self.assets=[[NSMutableArray alloc]init];
        }
        
        CTAssetsPickerController *picker=[[CTAssetsPickerController alloc]init];
        picker.assetsFilter=[ALAssetsFilter allPhotos];
        picker.showsCancelButton=(UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
        picker.delegate=self;
        picker.selectedAssets=_assets;
        
        [self presentViewController:picker animated:YES completion:nil];
    }else{
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[DBCameraViewController initWithDelegate:self]];
        [nav setNavigationBarHidden:YES];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

#pragma mark - setter & getter

-(void)setTotoalFinishedImageNumber:(NSInteger)totoalFinishedImageNumber{
    _totoalFinishedImageNumber=totoalFinishedImageNumber;
    if (totoalFinishedImageNumber==_assets.count) {
        if (_delegate) {
            [_delegate didFinishImagePick:_imageUploadResponse];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _assets.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reusableCellWithIdentifier=@"reusableCellWithIdentifier";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:reusableCellWithIdentifier];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reusableCellWithIdentifier];
    }
    
    ALAsset *asset = [self.assets objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageWithCGImage:asset.thumbnail];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;

}

#pragma mark - TableView Delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 74.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CTAssetsPageViewController *vc = [[CTAssetsPageViewController alloc] initWithAssets:self.assets];
    vc.pageIndex = indexPath.row;
    
    [self.navigationController pushViewController:vc animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - Assets Picker Delegate

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker isDefaultAssetsGroup:(ALAssetsGroup *)group
{
    return ([[group valueForProperty:ALAssetsGroupPropertyType] integerValue] == ALAssetsGroupSavedPhotos);
}

- (void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets
{

    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    
    self.assets = [NSMutableArray arrayWithArray:assets];
    [self.tableView reloadData];
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldEnableAsset:(ALAsset *)asset
{
    // Enable video clips if they are at least 5s
    if ([[asset valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo])
    {
        NSTimeInterval duration = [[asset valueForProperty:ALAssetPropertyDuration] doubleValue];
        return lround(duration) >= 5;
    }
    else
    {
        return YES;
    }
}

- (BOOL)assetsPickerController:(CTAssetsPickerController *)picker shouldSelectAsset:(ALAsset *)asset
{
    if (picker.selectedAssets.count >= 10)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Please select not more than 10 assets"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    if (!asset.defaultRepresentation)
    {
        UIAlertView *alertView =
        [[UIAlertView alloc] initWithTitle:@"Attention"
                                   message:@"Your asset has not yet been downloaded to your device"
                                  delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil];
        
        [alertView show];
    }
    
    return (picker.selectedAssets.count < 10 && asset.defaultRepresentation != nil);
}

#pragma mark - DBCameraViewControllerDelegate

- (void) dismissCamera:(id)cameraViewController{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    [cameraViewController restoreFullScreenMode];
}

- (void) camera:(id)cameraViewController didFinishWithImage:(UIImage *)image withMetadata:(NSDictionary *)metadata
{
    __weak typeof(self)weakSelf=self;
    [_library writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error )
     {
         [weakSelf.library assetForURL:assetURL resultBlock:^(ALAsset *asset )
          {
              dispatch_async(dispatch_get_main_queue(), ^{
                  [_assets addObject:asset];
                  [_tableView reloadData];
              });
          }
                 failureBlock:^(NSError *error )
          {
              [LZHShowMessage showProgressHUDType:SVPROGRESSHUDTYPEERROR message:[error localizedDescription]];
          }];
     }];
    
    [cameraViewController restoreFullScreenMode];
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
