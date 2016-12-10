//
//  MenuListModel.h
//  Benefit
//
//  Created by kazeik on 2016/12/9.
//  Copyright © 2016年 kazeik. All rights reserved.
// 主菜单类

#import <Foundation/Foundation.h>


@interface MenuListModel : NSObject

@property(nonatomic, strong) NSMutableArray *item;
@property(nonatomic,strong) NSMutableArray *subList;

@end
