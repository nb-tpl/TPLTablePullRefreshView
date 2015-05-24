//
//  ViewController.m
//  封装下拉刷新上拉加载
//
//  Created by 谭鄱仑 on 15-1-8.
//  Copyright (c) 2015年 谭鄱仑. All rights reserved.
//


/*  请搜索  例子 */


#import "ViewController.h"

#import "TPLTablePullRefreshView.h"

@interface ViewController ()<UITableViewDataSource,UITableViewDelegate,TPLTablePullRefreshViewDelegate>
{
    UITableView * _tableView;
    
    TPLTablePullRefreshView * _footerView;
    TPLTablePullRefreshView * _headerView;
    
    int _rowCount;
    
    
    
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rowCount = 20;
    // Do any additional setup after loading the view, typically from a nib.
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, self.view.frame.size.height - 20) style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor grayColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
/* 例子 */
    //下拉刷新
    _headerView = [[TPLTablePullRefreshView alloc] init];
    _headerView.visibleHeight = 70;
    _headerView.style = TPLTablePullRefreshViewHeaderStyle;
    _headerView.showStyle = 2;
    _headerView.scrollView = _tableView;
    _headerView.delegate = self;
    
    
    
    //上拉加载
    _footerView = [[TPLTablePullRefreshView alloc] init];
    _footerView.visibleHeight = 60;
    _footerView.style = TPLTablePullRefreshViewFooterStyle;
    _footerView.showStyle = 2;
    _footerView.scrollView = _tableView;
    _footerView.delegate = self;
    
    //关联
    _footerView.groupView = _headerView;
    _headerView.groupView = _footerView;
/* 例子 */
    
    //下拉方式
    UIButton * changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changeButton.frame = CGRectMake(10, 200, 120, 50);
    changeButton.backgroundColor = [UIColor grayColor];
    [changeButton addTarget:self action:@selector(changeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [changeButton setTitle:@"改变下拉方式" forState:UIControlStateNormal];
    [self.view addSubview:changeButton];
    
    
    
    //是否需要开始准备动画
    UIButton * animationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    animationButton.frame = CGRectMake(10, 260, 120, 50);
    animationButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    animationButton.backgroundColor = [UIColor grayColor];
    [animationButton addTarget:self action:@selector(animationButton:) forControlEvents:UIControlEventTouchUpInside];
    [animationButton setTitle:@"是否需要开始准备动画" forState:UIControlStateNormal];
    [self.view addSubview:animationButton];
    
    
    //京东
    UIButton * jdButton = [UIButton buttonWithType:UIButtonTypeCustom];
    jdButton.frame = CGRectMake(10, 320, 120, 50);
    jdButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    jdButton.backgroundColor = [UIColor grayColor];
    [jdButton addTarget:self action:@selector(jdButton:) forControlEvents:UIControlEventTouchUpInside];
    [jdButton setTitle:@"京东动画" forState:UIControlStateNormal];
    [self.view addSubview:jdButton];



}
    
-(void)changeButtonClicked:(id)sender
{
    _footerView.showStyle = _footerView.showStyle == 2?1:2;
    _headerView.showStyle = _headerView.showStyle == 2?1:2;
}


-(void)animationButton:(id)sender
{
    _headerView.beginAnimation = !_headerView.beginAnimation;
    _footerView.beginAnimation = !_footerView.beginAnimation;
}

-(void)jdButton:(id)sender
{
    if (_headerView.loadingAnimationDuration == 0.25)
    {
        _headerView.pullImagePath = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"gif"];
        _headerView.loadingImagePath = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"gif"];
        _headerView.loadingAnimationDuration = 1;
        
        _footerView.pullImagePath = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"gif"];
        _footerView.loadingImagePath = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"gif"];
        _footerView.loadingAnimationDuration = 1;
 
    }
    else
    {
        _headerView.pullImagePath = [[NSBundle mainBundle] pathForResource:@"jd" ofType:@"gif"];
        _headerView.loadingImagePath = [[NSBundle mainBundle] pathForResource:@"jd" ofType:@"gif"];
        _headerView.loadingAnimationDuration = 0.25;
        
        _footerView.pullImagePath = [[NSBundle mainBundle] pathForResource:@"jd" ofType:@"gif"];
        _footerView.loadingImagePath = [[NSBundle mainBundle] pathForResource:@"jd" ofType:@"gif"];
        _footerView.loadingAnimationDuration = 0.25;
    }
}

#pragma mark
#pragma mark           UITableViewDelegate & UITableViewDataSource
#pragma mark
//dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _rowCount;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellName = @"cellName";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
        //        cell.backgroundColor = [TPLHelpTool getRandomColor];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
//    cell.model = [_cellModelArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [@(indexPath.row) stringValue];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


/* 例子 */
#pragma mark
#pragma mark           TPLTablePullRefreshViewDelegate
#pragma mark

//下拉刷新
-(void)refreshScrollView:(UIScrollView*)scrollView TPLTablePullRefreshView:(TPLTablePullRefreshView*)view
{
    [self performSelector:@selector(endRefresh:) withObject:view afterDelay:3];
}


//上拉加载
-(void)addMoreScrollView:(UIScrollView*)scrollView TPLTablePullRefreshView:(TPLTablePullRefreshView*)view
{
    [self performSelector:@selector(endAddMore:) withObject:view afterDelay:3];
}


//test
-(void)endRefresh:(TPLTablePullRefreshView*)view
{
    _rowCount = 20;
    [_tableView reloadData];
//    [view.groupView updateFrame];
    view.loading = NO;
}

-(void)endAddMore:(TPLTablePullRefreshView*)view
{
    _rowCount = _rowCount+10;
    [_tableView reloadData];
//    [view updateFrame];
    view.loading = NO;
}
/* 例子 */



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
