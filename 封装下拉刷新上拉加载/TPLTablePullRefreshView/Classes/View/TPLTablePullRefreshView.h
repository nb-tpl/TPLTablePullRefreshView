//
//  TPLTablePullRefreshView.h
//  封装下拉刷新上拉加载
//
//  Created by 谭鄱仑 on 15-1-8.
//  Copyright (c) 2015年 谭鄱仑. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef enum//是上拉加载还是下拉刷新
{
    TPLTablePullRefreshViewHeaderStyle = 1,
    TPLTablePullRefreshViewFooterStyle,
}TPLTablePullRefreshViewStyle;


@protocol TPLTablePullRefreshViewDelegate;

@interface TPLTablePullRefreshView : UIView

//属性
//是否正在加载
@property(nonatomic,assign)BOOL loading;
//关联加载的，防止同时刷新和加载更多,开始没设计好，应该合一起的...,每个ScrollView的上拉和下拉一定要相互关联
@property(nonatomic,weak)TPLTablePullRefreshView * groupView;
//视图类型，默认为header
@property(nonatomic,assign)TPLTablePullRefreshViewStyle style;
//视图是跟着tableView走还是在TableView下 1为跟着走，2为固定 默认为1
@property(nonatomic,assign)int showStyle;
//视图可见高度 /默认为65
@property(nonatomic,assign)CGFloat visibleHeight;


//显示文字的Label
@property(nonatomic,readonly)UILabel * textLabel;
//三种状态的文字
@property(nonatomic,strong)NSString * textNormal;
@property(nonatomic,strong)NSString * textPrepare;
@property(nonatomic,strong)NSString * textLoading;


//加载动画的相框
@property(nonatomic,readonly)UIImageView * loadingImageView;
@property(nonatomic,strong)NSString * loadingImagePath;//支持png,gif..
//帧动画时间 默认为一秒
@property(nonatomic,assign)CGFloat loadingAnimationDuration;

//拉动变化的相框
@property(nonatomic,readonly)UIImageView * pullImageView;
@property(nonatomic,strong)NSString * pullImagePath;//支持png,gif...

//是否需要开始动画,默认为需要
@property(nonatomic,assign)BOOL beginAnimation;





//代理
@property(nonatomic,weak)id<TPLTablePullRefreshViewDelegate> delegate;
//控制的scrollView
@property(nonatomic,weak)UIScrollView * scrollView;



//方法
//刷新位置方法,不管加载还是刷新，reloadData后都应该用底部的视图调用该方法，除非没有下拉加载
-(void)updateFrame;

@end

@protocol TPLTablePullRefreshViewDelegate<NSObject>

//下拉刷新
-(void)refreshScrollView:(UIScrollView*)scrollView TPLTablePullRefreshView:(TPLTablePullRefreshView*)view;
//上拉加载
-(void)addMoreScrollView:(UIScrollView*)scrollView TPLTablePullRefreshView:(TPLTablePullRefreshView*)view;
@end


