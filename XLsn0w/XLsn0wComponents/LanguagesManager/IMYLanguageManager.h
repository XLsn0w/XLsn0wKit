//
// Created by Ivan Chua on 15/4/8.
// Copyright (c) 2015 MeiYou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LanguagesManager.h"


#define IMYString(key) [[IMYLanguageManager sharedInstance] localizedStringForKey:key value:nil]

@interface IMYLanguageManager : LanguagesManager
@end