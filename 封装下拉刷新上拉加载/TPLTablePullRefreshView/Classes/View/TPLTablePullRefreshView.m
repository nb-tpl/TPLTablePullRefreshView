//
//  TPLTablePullRefreshView.m
//  封装下拉刷新上拉加载
//
//  Created by 谭鄱仑 on 15-1-8.
//  Copyright (c) 2015年 谭鄱仑. All rights reserved.
//


/*  请搜索  例子 */

#define style_default TPLTablePullRefreshViewHeaderStyle
#define showStyle_default 1
#define visibleHeight_default 70


#define scrollViewBackGroundView_tag 650


#define compare_tempValue 8

#import "TPLTablePullRefreshView.h"
#import <ImageIO/ImageIO.h>

@interface TPLTablePullRefreshView ()
{
    UILabel * _textLabel;
    
//data
    NSArray * _pullImageArray;
    CGFloat  _pullTransHeight;
    
    NSArray * _loadingImageArray;
//辅助变量
    CGFloat _totalHeight;
    CGFloat _loadingAnimationDuration;
    
}

@end



@implementation TPLTablePullRefreshView

-(void)dealloc
{
    [_scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [_scrollView removeObserver:self forKeyPath:@"contentSize"];
    
}


-(id)init
{
    self = [super init];
    if (self)
    {
        //init
        _loading = NO;
        _beginAnimation = YES;
        _style = style_default;
        _showStyle = showStyle_default;
        _visibleHeight = visibleHeight_default;
        _totalHeight = 0;
        _loadingAnimationDuration = 1;
        
        _textNormal = @"下拉刷新";
        _textPrepare = @"松手刷新";
        _textLoading = @"正在刷新...";
        
        
        //详情
        _textLabel = [[UILabel alloc] init];
        _textLabel.textAlignment = NSTextAlignmentCenter;
        _textLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.text = @"下拉刷新";
        [self addSubview:_textLabel];
        
        
        //拉动时的动画
        _pullImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 10, 50, 50)];
        _pullImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_pullImageView];
        
        self.pullImagePath = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"gif"];
        
        //拉动时的动画
        _loadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(70, 10, 50, 50)];
        _loadingImageView.backgroundColor = [UIColor clearColor];
        [self addSubview:_loadingImageView];
        
        self.loadingImagePath = [[NSBundle mainBundle] pathForResource:@"logo" ofType:@"gif"];

        
        
        
        
        //test
        self.backgroundColor = [UIColor greenColor];
        
    }
    return self;
}

#pragma mark
#pragma mark           property
#pragma mark
//设定管理的TableView
-(void)setScrollView:(UIScrollView *)scrollView
{
    if ([_scrollView isEqual:_scrollView])
    {
        return;
    }
    
    [_scrollView removeObserver: self forKeyPath: @"contentOffset"];
    
    _scrollView = scrollView;
    
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context: nil];
    [_scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];

    
    [self updateFrame];
}
//设定高度
-(void)setVisibleHeight:(CGFloat)visibleHeight
{
    if (_visibleHeight == visibleHeight)
    {
        return;
    }
    _visibleHeight = visibleHeight;
    [self updateFrame];
}

//设定类型
-(void)setShowStyle:(int)showStyle
{
    if (_showStyle == showStyle)
    {
        return;
    }
    _showStyle = showStyle;
    [self updateFrame];
}
//设定上拉还是下拉
-(void)setStyle:(TPLTablePullRefreshViewStyle)style
{
    if (_style == style)
    {
        return;
    }
    _style = style;
//    if (TPLTablePullRefreshViewHeaderStyle == _style)
//    {
//        _textNormal =  _textNormal ? _textNormal : @"下拉刷新";
//        _textPrepare = _textPrepare ? _textPrepare : @"松手刷新";
//        _textLoading =  _textLoading ? _textLoading : @"正在刷新...";
//    }
//    else
//    {
//        _textNormal =  _textNormal ? _textNormal : @"上拉加载";
//        _textPrepare = _textPrepare ? _textPrepare : @"松手加载";
//        _textLoading =  _textLoading ? _textLoading : @"正在加载...";
//    }

    [self updateFrame];
}

//设定加载标志
-(void)setLoading:(BOOL)loading
{
    if (_scrollView && loading != _loading)
    {
        _loading = loading;
        if (NO == loading)
        {
            [self refreshing:loading];
            [self adding:loading];
        }
        else
        {
            if (TPLTablePullRefreshViewHeaderStyle == _style)
            {
                [self refreshing:loading];
            }
            else
            {
                [self adding:YES];
            }
        }
    }
}


//拉动
-(void)setPullImagePath:(NSString *)pullImagePath
{
    if ([_pullImagePath isEqualToString:pullImagePath])
    {
        return;
    }
    
    _pullImagePath = pullImagePath;
    [self updateData];
}

-(void)setLoadingImagePath:(NSString *)loadingImagePath
{
    if ([_loadingImagePath isEqualToString:loadingImagePath])
    {
        return;
    }
    
    _loadingImagePath = loadingImagePath;
    [self updateData];
}

-(void)setLoadingAnimationDuration:(CGFloat)loadingAnimationDuration
{
    _loadingAnimationDuration = loadingAnimationDuration;
    _loadingImageView.animationDuration = _loadingAnimationDuration;
}



#pragma mark
#pragma mark           KVO contentOffset
#pragma mark
#pragma mark
#pragma mark           KVO contentOffset
#pragma mark
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"contentOffset"])
    {
        CGPoint contentOffset = [change[@"new"] CGPointValue];
        
        //    NSLog(@"thread = %@ main = %@",[NSThread currentThread],[NSThread mainThread]);
        //    NSLog(@"change %@",change);
        //    NSLog(@"contentOffset = %@",NSStringFromCGPoint(contentOffset));
        //    NSLog(@"scrollViewContentSize = %@",NSStringFromCGSize(_scrollView.contentSize));
        
        //是头视图还是底部视图
        if(TPLTablePullRefreshViewHeaderStyle == _style)
        {
            if (contentOffset.y < 0)//下拉动画
            {
                int i = abs((int)contentOffset.y)/_pullTransHeight;
                //        NSLog(@"i = %d",i);
                i = i >= _pullImageArray.count ? (int)_pullImageArray.count - 1 : i;
                _pullImageView.image = [_pullImageArray objectAtIndex:i];
            }
            
            
            CGFloat value = (0-contentOffset.y) - _visibleHeight;
            if (value > 0)//松开刷新状态
            {
                if (NO == _scrollView.dragging && _loading == NO && _groupView.loading == NO)//松手了，要启动刷新
                {
                    [self refreshing:YES];
                }
                else if(value > compare_tempValue && _loading == NO)//系统反应不过来，必须多一点才行
                {
                    _textLabel.text = _textPrepare;
                    if (_beginAnimation)//开始动画切换
                    {
                        [self changeAnimation:YES];
                    }
                }
                else if(_loading == YES)
                {
                    _textLabel.text = _textLoading;
                }
            }
            else
            {
                if (NO == _loading)
                {
                    if (_pullImageView.hidden && _beginAnimation)
                    {
                        [self changeAnimation:NO];
                    }
                    _textLabel.text = _textNormal;
                }
            }
        }
        else
        {
            CGFloat temp = MAX(_scrollView.contentSize.height > _scrollView.frame.size.height ? _scrollView.contentSize.height : _scrollView.frame.size.height,_totalHeight);
            
            CGFloat pullDownValue = (contentOffset.y + _scrollView.frame.size.height) - temp;
            if ( pullDownValue > 0)//上拉动画
            {
                int i = abs((int)pullDownValue)/_pullTransHeight;
                //        NSLog(@"i = %d",i);
                i = i >= _pullImageArray.count ? (int)_pullImageArray.count - 1 : i;
                _pullImageView.image = [_pullImageArray objectAtIndex:i];
            }
            
            
            //        NSLog(@"_scrollView frame = %@",NSStringFromCGRect(_scrollView.frame));
//            NSLog(@"OK = %f , %f",(contentOffset.y + _scrollView.frame.size.height) - temp,_visibleHeight);
            

            CGFloat value = ((contentOffset.y + _scrollView.frame.size.height) - temp ) - _visibleHeight;
      
            if (value > 0)
            {
                if (NO == _scrollView.dragging && _loading == NO && temp != 0 && _groupView.loading == NO)//松手了，要启动加载
                {
                    [self adding:YES];
                }
                else if(value > compare_tempValue && _loading == NO)
                {
                    _textLabel.text = _textPrepare;
                    if (_beginAnimation)//开始动画切换
                    {
                        [self changeAnimation:YES];
                    }
                }
                else if(_loading == YES)
                {
                    _textLabel.text = _textLoading;
                }
                
            }
            else
            {
                if (NO == _loading)
                {
                    if (_pullImageView.hidden && _beginAnimation)
                    {
                        [self changeAnimation:NO];
                    }
                    _textLabel.text = _textNormal;
                }
            }
        }
    }
    else if ([keyPath isEqualToString:@"contentSize"])
    {
        [self updateFrame];
    }
}



//切换刷新状态
-(void)refreshing:(BOOL)refreshing
{
    _loading = refreshing;
    if (refreshing)
    {
        _textLabel.text = self.textLoading;
        _scrollView.contentInset = UIEdgeInsetsMake(_visibleHeight + compare_tempValue, 0.0f, 0.0f, 0.0f);
        [UIView animateWithDuration:0.2 animations:^{
            _scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x, -_visibleHeight);
        
        } completion:^(BOOL finished)
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(refreshScrollView:TPLTablePullRefreshView:)])
            {
                [self.delegate refreshScrollView:_scrollView TPLTablePullRefreshView:self];
            }
            _loadingImageView.hidden = NO;
            [_loadingImageView startAnimating];
            _pullImageView.hidden = YES;
            
        }];
    }
    else
    {
//        _textLabel.text = @"正在加载...";
        
        [_loadingImageView stopAnimating];
        _loadingImageView.hidden = YES;
        _pullImageView.hidden = NO;
        
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        _scrollView.contentInset = UIEdgeInsetsMake(0, 0.0f, 0.0f, 0.0f);
        [UIView commitAnimations];
    }
}
//切换加载状态
-(void)adding:(BOOL)adding
{
    _loading = adding;
    if (adding)
    {
        [UIView animateWithDuration:0.2 animations:^{
            
            _scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, _visibleHeight + compare_tempValue, 0.0f);
            
        } completion:^(BOOL finished)
         {
             if (self.delegate && [self.delegate respondsToSelector:@selector(addMoreScrollView:TPLTablePullRefreshView:)])
             {
                 [self.delegate addMoreScrollView:_scrollView TPLTablePullRefreshView:self];
             }
             _loadingImageView.hidden = NO;
             [_loadingImageView startAnimating];
             _pullImageView.hidden = YES;
             
         }];
    }
    else
    {
        
        [_loadingImageView stopAnimating];
        _loadingImageView.hidden = YES;
        _pullImageView.hidden = NO;
        

        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.2];
        _scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 0, 0.0f);
        [UIView commitAnimations];
    }
}

-(void)changeAnimation:(BOOL)animation
{
    if (animation)
    {
        _loadingImageView.hidden = NO;
        [_loadingImageView startAnimating];
        _pullImageView.hidden = YES;
    }
    else
    {
        [_loadingImageView stopAnimating];
        _loadingImageView.hidden = YES;
        _pullImageView.hidden = NO;
    }
}



#pragma mark
#pragma mark           help function
#pragma mark
-(void)updateFrame
{
    if (nil == _scrollView)//如果控制的列表视图不存在
    {
        return;
    }
    
    
    //刷新视图背面视图
    UIView * scrollViewBackGroundView;
    if ([_scrollView isKindOfClass:[UITableView class]])
    {
        scrollViewBackGroundView = [(UITableView*)_scrollView  backgroundView];
    }
    else if ([_scrollView isKindOfClass:[UICollectionView class]])
    {
        scrollViewBackGroundView = [(UICollectionView*)_scrollView  backgroundView];
    }
    else
    {
       scrollViewBackGroundView  = [_scrollView viewWithTag:scrollViewBackGroundView_tag];
    }
    
    if (scrollViewBackGroundView == nil)
    {
        scrollViewBackGroundView = [[UIView alloc] init];
        scrollViewBackGroundView.backgroundColor = [UIColor clearColor];
        scrollViewBackGroundView.opaque = NO;
        scrollViewBackGroundView.userInteractionEnabled = YES;
    }
    
    //显示在上面还是固定不动
    if (1 == _showStyle)
    {
        scrollViewBackGroundView.frame = _scrollView.bounds;
        //为了区分ScrollView和tableView和UICollectionView
        if ([_scrollView isKindOfClass:[UITableView class]])
        {
            UITableView * tableView = (UITableView*)_scrollView;
            tableView.backgroundView = scrollViewBackGroundView;
        }
        else if ([_scrollView isKindOfClass:[UICollectionView class]])
        {
            UICollectionView * collectionView = (UICollectionView*)_scrollView;
            collectionView.backgroundView = scrollViewBackGroundView;
        }
        else
        {
            [_scrollView addSubview:scrollViewBackGroundView];
            [_scrollView sendSubviewToBack:scrollViewBackGroundView];
        }
        
        //视图功能类型
        if(TPLTablePullRefreshViewHeaderStyle == _style)
        {
            self.frame = CGRectMake(0, 0, _scrollView.frame.size.width, _visibleHeight);
        }
        else
        {
        self.frame = CGRectMake(0,_scrollView.frame.size.height - _visibleHeight, _scrollView.frame.size.width, _visibleHeight);
        }
        [scrollViewBackGroundView addSubview:self];

    }
    else
    {
        //是头视图还是底部视图
        if(TPLTablePullRefreshViewHeaderStyle == _style)
        {
            self.frame = CGRectMake(0, -_visibleHeight, _scrollView.frame.size.width, _visibleHeight);
        }
        else
        {
            CGFloat height = MAX(_scrollView.frame.size.height, _scrollView.contentSize.height);
            if ([_scrollView isKindOfClass:[UITableView class]])
            {
                height = [self getHeightFromTableView:(UITableView*)_scrollView];
            }
            else if ([_scrollView isKindOfClass:[UICollectionView class]])
            {
                
            }
            self.frame = CGRectMake(0, height, _scrollView.frame.size.width, _visibleHeight);
        }
        [_scrollView addSubview:self];
    }
    
}

//更新数据
-(void)updateData
{
    if (_pullImagePath)
    {
        _pullImageArray = [TPLTablePullRefreshView imageArrayFromImageFile:_pullImagePath];
    }
    
    if (_loadingImagePath)
    {
        _loadingImageArray = [TPLTablePullRefreshView imageArrayFromImageFile:_loadingImagePath];
        _loadingImageView.animationImages = _loadingImageArray;
        _loadingImageView.animationDuration = _loadingAnimationDuration;
        _loadingImageView.animationRepeatCount = 0;
    }

    _pullTransHeight = (_visibleHeight + compare_tempValue)/_pullImageArray.count;
}

//获得tableView的高度,这样重复计算了总高度，不知道还有没有更好的方法
-(CGFloat)getHeightFromTableView:(UITableView*)tableView
{
    NSInteger sectionCount = [tableView numberOfSections];
    _totalHeight = 0;
    for (int i = 0; i < sectionCount; i++)
    {
        NSInteger sectionRowCount = [tableView numberOfRowsInSection:i];
        for (int j = 0; j < sectionRowCount; j++)
        {
            if([tableView.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
            {
                _totalHeight = _totalHeight + [tableView.delegate tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
            }
            else
            {
                _totalHeight = _totalHeight + 44;//tableView.rowHeight;
            }

        }
    }
    
    return _totalHeight;
}
//获得CollectionView的高度,这样重复计算了总高度，不知道还有没有更好的方法
//-(CGFloat)getHeightFromCollectionView:(UICollectionView*)collectionView
//{
//    NSInteger sectionCount = [collectionView numberOfSections];
//    _totalHeight = 0;
//    for (int i = 0; i < sectionCount; i++)
//    {
//        NSInteger sectionRowCount = [collectionView numberOfRowsInSection:i];
//        for (int j = 0; j < sectionRowCount; j++)
//        {
//            if([tableView.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)])
//            {
//                _totalHeight = _totalHeight + [tableView.delegate tableView:tableView heightForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
//            }
//            else
//            {
//                _totalHeight = _totalHeight + 44;//tableView.rowHeight;
//            }
//            
//        }
//    }
//    
//    return _totalHeight;
//}



//获取指定GIF图片的图片数组
+(NSMutableArray*)imageArrayFromImageFile:(NSString*)imageFilePath
{
    NSData *imageData = [NSData dataWithContentsOfFile: imageFilePath];
    NSMutableArray *frames = nil;
    CGImageSourceRef src = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    if (src)
    {
        size_t l = CGImageSourceGetCount(src);
        if (l > 0)
        {
            frames = [NSMutableArray arrayWithCapacity: l];
            for (size_t i = 0; i < l; i++)
            {
                CGImageRef img = CGImageSourceCreateImageAtIndex(src, i, NULL);
                if (img) {
                    [frames addObject: [UIImage imageWithCGImage: img]];
                    CGImageRelease(img);
                }
            }
        }
        
    }
    
    return frames;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
