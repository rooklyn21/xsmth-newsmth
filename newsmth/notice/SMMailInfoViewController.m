//
//  SMMailInfoViewController.m
//  newsmth
//
//  Created by Maxwin on 13-9-15.
//  Copyright (c) 2013年 nju. All rights reserved.
//

#import "SMMailInfoViewController.h"
#import "PBWebViewController.h"
#import "SMMailComposeViewController.h"
#import "SMUserViewController.h"

@interface SMMailInfoViewController ()<SMWebLoaderOperationDelegate, UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webViewForContent;
@property (weak, nonatomic) IBOutlet UIView *viewForInfo;
@property (weak, nonatomic) IBOutlet UILabel *labelForTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelForDate;
@property (weak, nonatomic) IBOutlet UIButton *buttonForAuthor;

@property (strong, nonatomic) SMWebLoaderOperation *mailContentOp;

@end

@implementation SMMailInfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self makeupHeadInfo];
    
    [self loadMailInfo];
}

- (void)onRightBarButtonItemClick
{
    SMMailComposeViewController *mailComposeViewController = [[SMMailComposeViewController alloc] init];
    NSString *title = _mail.title;
    NSRange r = [title rangeOfString:@"Re: "];
    if (r.length == 0 || (r.length > 0 && r.location > 0)) {
        title = [NSString stringWithFormat:@"Re: %@", title];
    }
    _mail.title = title;
    mailComposeViewController.mail = _mail;
    
    P2PNavigationController *nvc = [[P2PNavigationController alloc] initWithRootViewController:mailComposeViewController];
    [self.navigationController presentModalViewController:nvc animated:YES];
    
}

- (IBAction)onUserButtonClick:(id)sender
{
    SMUserViewController *vc = [[SMUserViewController alloc] init];
    vc.username = _mail.author;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)loadMailInfo
{
    _mailContentOp = [[SMWebLoaderOperation alloc] init];
    NSString *url = [NSString stringWithFormat:@"http://m.newsmth.net/%@", _mail.url];
    _mailContentOp.delegate = self;
    [_mailContentOp loadUrl:url withParser:@"mailcontent,util_notice"];
}

- (void)makeupHeadInfo
{
    CGFloat heightExpectTitle = _viewForInfo.frame.size.height - _labelForTitle.frame.size.height;
    
    CGFloat titleHeight = [_mail.title smSizeWithFont:_labelForTitle.font constrainedToSize:CGSizeMake(_labelForTitle.frame.size.width, CGFLOAT_MAX) lineBreakMode:_labelForTitle.lineBreakMode].height;
    
    CGRect frame = _viewForInfo.frame;
    frame.size.height = titleHeight + heightExpectTitle;
    _viewForInfo.frame = frame;
    
    _labelForTitle.text = _mail.title;
    [_buttonForAuthor setTitle:_mail.author forState:UIControlStateNormal];
    [_buttonForAuthor sizeToFit];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    _labelForDate.text = [formatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:_mail.date / 1000]];
}

#pragma mark - SMWebLoaderOperationDelegate
- (void)webLoaderOperationFinished:(SMWebLoaderOperation *)opt
{
//    XLog_d(@"%@", opt.data);
    SMResult *result = opt.data;
    NSString *html = [NSString stringWithFormat:@"<html><body style='margin:0; padding: 10px; font-size: 15px;font-family: Verdana;'>%@</body></html>", result.message];
    [_webViewForContent loadHTMLString:html baseURL:nil];
    
    UIScrollView *scrollView = _webViewForContent.scrollView;
    UIEdgeInsets inset = scrollView.contentInset;
    inset.top = SM_TOP_INSET + _viewForInfo.frame.size.height;
    scrollView.contentInset = scrollView.scrollIndicatorInsets = inset;
    
    _mail.content = result.message;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(onRightBarButtonItemClick)];
}


- (void)webLoaderOperationFail:(SMWebLoaderOperation *)opt error:(SMMessage *)error
{
    [self toast:error.message];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        return YES;
    }
    
    PBWebViewController *pbvc = [[PBWebViewController alloc] init];
    pbvc.URL = request.URL;
    [self.navigationController pushViewController:pbvc animated:YES];
    return NO;
}


@end
