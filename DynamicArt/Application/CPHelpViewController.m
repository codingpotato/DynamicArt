//
//  CPHelpViewController.m
//  DynamicArt
//
//  Created by wangyw on 9/15/12.
//  Copyright (c) 2012 codingpotato. All rights reserved.
//

#import "CPHelpViewController.h"

#import <WebKit/WebKit.h>

#import "CPApplicationController.h"

@interface CPHelpViewController () <CPHelpContentViewControllerDelegate, WKNavigationDelegate>

@property (strong, nonatomic) WKWebView *webView;

@property (strong, nonatomic) NSURL *helpUrl;

@property (strong, nonatomic) IBOutlet UIToolbar *rightToolbar;

@end

@implementation CPHelpViewController

#pragma mark - property methods

- (NSURL *)helpUrl {
    if (!_helpUrl) {
        _helpUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help[index]" ofType:@"html" inDirectory:@"Help"]];
    }
    return _helpUrl;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Introduction";
    self.navigationItem.rightBarButtonItems = self.rightToolbar.items;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    self.webView.navigationDelegate = self;
    [self.view addSubview:self.webView];
    self.webView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:@[
                                [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
                                [NSLayoutConstraint constraintWithItem:self.webView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1 constant:0]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.helpUrl]];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [self.webView reload];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"CPHelpContentSegue"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        CPHelpContentViewController *helpContentViewController = (CPHelpContentViewController *)navigationController.topViewController;
        helpContentViewController.delegate = self;
    }
}

- (IBAction)doneButtonPressed:(id)sender {
    [self.delegate backFromHelpViewController:self];
}

- (IBAction)helpContentButtonPressed:(id)sender {
    [self performSegueWithIdentifier:@"CPHelpContentSegue" sender:self];
}

#pragma mark - CPHelpContentViewControllerDelegate implement

- (void)helpContentViewController:(CPHelpContentViewController *)helpContentViewController sectionTitle:(NSString *)title selectedHtml:(NSString *)htmlPath {
    self.title = title;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:htmlPath relativeToURL:self.helpUrl]]];
}

#pragma mark - WKNavigationDelegate implement

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if ([navigationAction.request.URL.scheme isEqualToString:@"codingpotato.dynamicart"]) {
        [CPApplicationController loadAppFromUrl:navigationAction.request.URL];
        [self.presentingViewController dismissViewControllerAnimated:self completion:nil];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

@end
