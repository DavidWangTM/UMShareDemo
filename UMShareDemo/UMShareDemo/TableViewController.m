//
//  TableViewController.m
//  UMShareDemo
//
//  Created by DavidWang on 15/7/22.
//  Copyright (c) 2015年 DavidWang. All rights reserved.
//

#import "TableViewController.h"
#import "TableCell.h"
#import "AppDelegate.h"

@interface TableViewController ()<UMSocialUIDelegate>{
    NSArray *data;
}

@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    data = @[@"UMMenuShare",@"UMSinaShare",@"UMWXShare",@"UMWXPYShare",@"UMQQShare",@"WXLogin",@"QQLogin",@"SianLogin"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return data.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"TableCell";
    TableCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell.showlab.text = data[indexPath.row];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = indexPath.row;
    if (row == 0) {
        [self MenuOnclick];
    }else if (row == 1){
        [self ShareOnclick:UMShareToSina];
    }else if (row == 2){
        [self ShareOnclick:UMShareToWechatSession];
    }else if (row == 3){
        [self ShareOnclick:UMShareToWechatTimeline];
    }else if (row == 4){
        [self ShareOnclick:UMShareToQzone];
    }else if (row == 5){
        [self LoginOnclick:UMShareToWechatTimeline];
    }else if (row == 6){
        [self LoginOnclick:UMShareToQQ];
    }else if (row == 7){
        [self LoginOnclick:UMShareToSina];
    }

}
//sina.5211818556240bc9ee01db2f

//weixin wxd930ea5d5a258f4f

//tencent100424468

-(void)MenuOnclick{
    NSString *shareText = @"测试分享。 http://www.umeng.com/social";             //分享内嵌文字
    UIImage *shareImage = [UIImage imageNamed:@"UMS_social_demo"];          //分享内嵌图片
    NSArray *arr = @[UMShareToSina,UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQzone];
    //调用快速分享接口
    [UMSocialSnsService presentSnsIconSheetView:self
                                         appKey:UmengAppkey
                                      shareText:shareText
                                     shareImage:shareImage
                                shareToSnsNames:arr
                                       delegate:self];
}

//下面得到分享完成的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    NSLog(@"didFinishGetUMSocialDataInViewController with response is %@",response);
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}

-(void)ShareOnclick:(NSString *)snsName{
    NSString *shareText = @"测试分享。 http://www.umeng.com/social";             //分享内嵌文字
    UIImage *shareImage = [UIImage imageNamed:@"UMS_social_demo"];
    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[snsName] content:shareText image:shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity * response){
        if (response.responseCode == UMSResponseCodeSuccess) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"成功" message:@"分享成功" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
            [alertView show];
        } else if(response.responseCode != UMSResponseCodeCancel) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"失败" message:@"分享失败" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
            [alertView show];
        }
    }];
}


-(void)LoginOnclick:(NSString *)snsName{
    [UMSocialControllerService defaultControllerService].socialUIDelegate = self;
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:snsName];
    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
        //          获取微博用户名、uid、token等
        if (response.responseCode == UMSResponseCodeSuccess) {
            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:snsName];
            NSLog(@"username is %@, uid is %@, token is %@ iconUrl is %@",snsAccount.userName,snsAccount.usid,snsAccount.accessToken,snsAccount.iconURL);
        }
        //这里可以获取到腾讯微博openid,Qzone的token等
        /*
         if ([platformName isEqualToString:UMShareToTencent]) {
         [[UMSocialDataService defaultDataService] requestSnsInformation:UMShareToTencent completion:^(UMSocialResponseEntity *respose){
         NSLog(@"get openid  response is %@",respose);
         }];
         }
         */
    });
}

-(void)cancelLogin:(NSString *)snsName{
    [[UMSocialDataService defaultDataService] requestUnOauthWithType:snsName completion:^(UMSocialResponseEntity *response) {
        NSLog(@"unOauth response is %@",response);
    }];
}


@end
