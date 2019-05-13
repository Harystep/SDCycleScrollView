


#import "HRCardSwitchFlowLayout.h"

#define ZScreen_Size [UIScreen mainScreen].bounds.size
#define Active_Dintance 180
#define Zoom_Factory 0.08
#define TOPScreenWidth [UIScreen mainScreen].bounds.size.width
#define kCellMargin 50

//#define wScale ((TOPScreenWidth - 50) / TOPScreenWidth)
//#define hScale 0.9

@implementation HRCardSwitchFlowLayout

- (void)prepareLayout {
    
    [super prepareLayout];
    [self calculateItems];
}

- (void)calculateItems {
    //设置样式
    self.itemSize = CGSizeMake(TOPScreenWidth - kCellMargin, 200);
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
    
}

////卡片宽度
//- (CGFloat)cellWidth {
//    return TOPScreenWidth * wScale;
//}

//当边界发生改变时，是否应该刷新布局。如果YES则在边界变化（一般是scroll到其他地方）时，将重新计算需要的布局信息。
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}


//返回可见cell布局
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    NSArray *array = [super layoutAttributesForElementsInRect:rect];
    //当前显示的视图位置
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    NSMutableArray *attArray = [[NSMutableArray alloc] init];
    
    for (UICollectionViewLayoutAttributes *attributes in array) {

        UICollectionViewLayoutAttributes *att = [attributes copy];
        if ( CGRectIntersectsRect(attributes.frame, rect)) {
            //cell中心距屏幕中心距离
            CGFloat distance = CGRectGetMidX(visibleRect)-att.center.x;
            distance = ABS(distance);
            //判断,cell是否居中
            if (distance < ZScreen_Size.width/2 + self.itemSize.width) {
                //居中就放大 zoom比例
                CGFloat zoom = 1 + Zoom_Factory*(1-distance/Active_Dintance);
                if (zoom < 1) {
                    att.transform3D = CATransform3DMakeScale(1, zoom, 1.0);

                } else {
                    att.transform3D = CATransform3DMakeScale(1, 1.001, 1.0);
                }
            }
        }
        [attArray addObject:att];
    }
    return attArray;
    
}


//防止报错 先复制attributes
- (NSArray *)getCopyOfAttributes:(NSArray *)attributes {
    NSMutableArray *copyArr = [NSMutableArray new];
    for (UICollectionViewLayoutAttributes *attribute in attributes) {
        [copyArr addObject:[attribute copy]];
    }
    return copyArr;
}


//手动指定偏移量
- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity{
    
    // 计算出最终显示的矩形框
    CGRect rect;
    rect.origin.y = 0;
    rect.origin.x = proposedContentOffset.x;
    rect.size = self.collectionView.frame.size;
    
    //获得super已经计算好的布局的属性
    NSArray *arr = [super layoutAttributesForElementsInRect:rect];
    //计算collectionView最中心点的x值
    CGFloat centerX = proposedContentOffset.x + self.collectionView.frame.size.width * 0.5;
    
    CGFloat minDelta = TOPScreenWidth-kCellMargin;//cell的宽度
    for (UICollectionViewLayoutAttributes *attrs in arr) {
        if (ABS(minDelta) > ABS(attrs.center.x - centerX)) {
            minDelta = attrs.center.x - centerX;
        }
    }
    proposedContentOffset.x += minDelta;
    return proposedContentOffset;
}

@end
