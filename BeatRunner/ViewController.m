//
//  ViewController.m
//  BeatRunner
//
//  Created by koki nakamura on 2014/02/25.
//  Copyright (c) 2014年 koki nakamura. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    //UI部
    BOOL _isPlaying;
    
    //タイマー、BPM取得部における変数
    NSTimer *_timer;
    NSDate *_startDate;
    NSDate *_dateNow;
    float _countTime;
    int _tapCount;

    //音楽データの配列、BPM
    NSMutableArray *_musicItems;
    int _BPMnum;

}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    //プレイヤーの設定
    _player = [MPMusicPlayerController iPodMusicPlayer];
    
    //Notificationの設定
    _ncenter = [NSNotificationCenter defaultCenter];
    [_ncenter addObserver:self
                 selector:@selector(handle_NowPlayingItemChanged)
                     name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                   object:_player];
    [_player beginGeneratingPlaybackNotifications];
    
    
    //配列の設定
    _musicItems = [NSMutableArray array];
}

- (void)handle_NowPlayingItemChanged {
    MPMediaItem *playingItem = [_player nowPlayingItem];
    if (playingItem) {
        NSInteger mediaType = [[playingItem valueForProperty:MPMediaItemPropertyMediaType] integerValue];
        
        if (mediaType == MPMediaTypeMusic) {
            
            NSString *songTitle = [playingItem valueForProperty:MPMediaItemPropertyTitle];
            NSString *albumTitle = [playingItem valueForProperty:MPMediaItemPropertyAlbumTitle];
            NSString *artist = [playingItem valueForProperty:MPMediaItemPropertyArtist];
            NSString *bpm = [playingItem valueForProperty:MPMediaItemPropertyBeatsPerMinute];
            
            _NowPlayingViewer.text = [NSString stringWithFormat:@"%@ - %@ / %@:BPM-%@", songTitle, albumTitle, artist, bpm];
        }
    }
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)BPMBtn:(id)sender {
    if (![_timer isValid]) {
        //タップボタン押した時に一番最初に入るところなので、各変数のリセットをここで行います。
        [_musicItems removeAllObjects];
        _countTime = 1.6;
        _tapCount = -1;
        //初期化ここまで
        
        _startDate = [NSDate date];
        
        //タイマー開始
        _timer = [NSTimer
                 scheduledTimerWithTimeInterval:0.2
                 target: self
                 selector:@selector(TimerAction)
                 userInfo:nil
                 repeats:YES];
        
    } else {
        _dateNow = [NSDate date];
        _countTime = 1.6;
    }

    _tapCount++;
}

- (void)TimerAction {
    
    if (_countTime > 0) {
        _countTime -= 0.2;
    } else {
        // タイマーを停止する
        [_timer invalidate];
        
        //BPM取得
        _BPMnum = ( 60 / ([_dateNow timeIntervalSinceDate:_startDate] / _tapCount));
        _BPMViewer.text = [NSString stringWithFormat:@"%d", _BPMnum];
        
        //音楽セット
        [self setCollection];
        
        //配列の中身をここで表示してます。デバッグ用。
        for( MPMediaItem *music in _musicItems) {
            NSString *songTitle = [music valueForProperty:MPMediaItemPropertyTitle];
            NSLog(@"%@", songTitle);
        }
        
        //分岐させて、音楽データがあれば再生。
        if (_musicItems.count != 0 && _musicItems) {
            _player = [[MPMusicPlayerController alloc] init];
            MPMediaItemCollection *myMediaItemCollection = [MPMediaItemCollection alloc];
            [myMediaItemCollection initWithItems:_musicItems];
            [_player setQueueWithItemCollection:myMediaItemCollection];
            [_player play];
            } else {
            //エラー処理
            NSLog(@"error");
        }
    }
}


- (void)setCollection {
    NSNumber *BPM = [NSNumber numberWithInt:_BPMnum];
    for (MPMediaItem *item in [[MPMediaQuery songsQuery] items]) {
        if ( [[item valueForProperty:MPMediaItemPropertyBeatsPerMinute] isEqualToNumber: BPM]) {
          [_musicItems addObject:item];
        }
    }
    
    for (int i = 1; i < 7; i++) {
        BPM = [NSNumber numberWithInt:_BPMnum + i];
        for (MPMediaItem *item in [[MPMediaQuery songsQuery] items]) {
            if ( [[item valueForProperty:MPMediaItemPropertyBeatsPerMinute] isEqualToNumber: BPM]) {
                [_musicItems addObject:item];
            }
        }
        BPM = [NSNumber numberWithInt:_BPMnum - i];
        for (MPMediaItem *item in [[MPMediaQuery songsQuery] items]) {
            if ( [[item valueForProperty:MPMediaItemPropertyBeatsPerMinute] isEqualToNumber: BPM]) {
                [_musicItems addObject:item];
            }
        }
    }
}


- (IBAction)NextBtn:(id)sender {
    [_player skipToNextItem];
}

- (IBAction)PrevBtn:(id)sender {
    [_player skipToPreviousItem];
}

- (IBAction)StartOrStopBtn:(id)sender {
    if (_isPlaying)
        [_player pause];
    else
        [_player play];
    
    _isPlaying = !_isPlaying;
}
@end
