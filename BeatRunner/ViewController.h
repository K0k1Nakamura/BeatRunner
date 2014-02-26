//
//  ViewController.h
//  BeatRunner
//
//  Created by koki nakamura on 2014/02/25.
//  Copyright (c) 2014年 koki nakamura. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ViewController : UIViewController

//UI部分
@property (weak, nonatomic) IBOutlet UILabel *BPMViewer;
- (IBAction)BPMBtn:(id)sender;
- (IBAction)NextBtn:(id)sender;
- (IBAction)PrevBtn:(id)sender;
- (IBAction)StartOrStopBtn:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *NowPlayingViewer;


//音楽プレイヤー
@property MPMusicPlayerController *player;
@property NSNotificationCenter *ncenter;
@property (weak, nonatomic) IBOutlet UISlider *timelineSlider;
- (IBAction)setTimeLinePosition:(id)sender;

@end
