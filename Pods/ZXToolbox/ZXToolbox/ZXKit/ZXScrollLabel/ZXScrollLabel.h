//
// ZXScrollLabel.h
// https://github.com/xinyzhao/ZXToolbox
//
// Copyright (c) 2019 Zhao Xin
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <UIKit/UIKit.h>

/**
 ZXScrollLabel
 */
@interface ZXScrollLabel : UILabel
/// The data source of texts
@property (nonatomic, strong) NSArray *textArray;
/// Halt time of each text, default is 0 sec.
@property (nonatomic, assign) IBInspectable double haltTime;
/// Default is width/6 in pixels per second.
@property (nonatomic, assign) IBInspectable double scrollingSpeed;
/// Vertical scrolling, default is NO
@property (nonatomic, getter=isVerticalScrolling) IBInspectable BOOL verticalScrolling;

/**
 Start scrolling
 */
- (void)startScrolling;

/**
 Stop scrolling
 */
- (void)stopScrolling;

@end
