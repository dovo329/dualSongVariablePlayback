//
//  ViewController.m
//  iPodVisualizer
//
//  Created by Xinrong Guo on 13-3-23.
//  Copyright (c) 2013年 Xinrong Guo. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VisualizerView.h"

@interface ViewController ()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UINavigationBar *navBar;
@property (strong, nonatomic) UIToolbar *toolBar;
@property (strong, nonatomic) NSArray *playItems_1not2;
@property (strong, nonatomic) NSArray *playItems_2not1;
@property (strong, nonatomic) NSArray *playItems_1and2;
@property (strong, nonatomic) NSArray *playItems_not1and2;
@property (strong, nonatomic) UIBarButtonItem *playBBI;
@property (strong, nonatomic) UIBarButtonItem *pauseBBI;
@property (strong, nonatomic) UIBarButtonItem *playBBI2;
@property (strong, nonatomic) UIBarButtonItem *pauseBBI2;

// Add properties here
@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (strong, nonatomic) AVAudioPlayer *audioPlayer2;
@property (strong, nonatomic) VisualizerView *visualizer;
@property (strong, nonatomic) VisualizerView *visualizer2;

@property (nonatomic) NSTimer *updateSongPositionTimer;
@property (nonatomic) UISlider *songPositionSlider;
@property (nonatomic) UISlider *songLoopback1Slider;
@property (nonatomic) UISlider *songLoopback2Slider;

@end

@implementation ViewController {
    BOOL _isBarHide;
    BOOL _isPlaying;
    BOOL _isPlaying2;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBars];
    [self configureAudioSession];
    /*CGRect leftVisualizerFrame = self.view.frame;
    leftVisualizerFrame.size.width /= 2.0;
    CGRect rightVisualizerFrame = self.view.frame;
    rightVisualizerFrame.size.width /= 2.0;
    rightVisualizerFrame.origin.x += rightVisualizerFrame.size.width;
    self.visualizer = [[VisualizerView alloc] initWithFrame:leftVisualizerFrame];
    [_visualizer setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_backgroundView addSubview:_visualizer];
    self.visualizer2 = [[VisualizerView alloc] initWithFrame:rightVisualizerFrame];
    [_visualizer2 setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_backgroundView addSubview:_visualizer2];*/
    [self configureAudioPlayer];
    [self createPlaybackSpeedSlider];
    [self createPlaybackSpeedSlider2];
    [self createMixerSlider];
    [self createSongPositionSlider];
    [self createSongLoopback1Slider];
    [self createSongLoopback2Slider];
    
    self.updateSongPositionTimer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                      target:self
                                                    selector:@selector(updateSongPositionTimerHandler)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.songPositionSlider.maximumValue = self.audioPlayer.duration;
    NSLog(@"self.audioPlayer.duration=%f", self.audioPlayer.duration);

    self.songLoopback1Slider.minimumValue = 0.0;
    self.songLoopback1Slider.maximumValue = self.audioPlayer.duration;
    self.songLoopback1Slider.value = 0.0;
    
    self.songLoopback2Slider.minimumValue = 0.0;
    self.songLoopback2Slider.maximumValue = self.audioPlayer.duration;
    self.songLoopback2Slider.value = self.audioPlayer.duration;
    
    [self toggleBars];
}

- (void)configureBars {
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    CGRect frame = self.view.frame;
    
    self.backgroundView = [[UIView alloc] initWithFrame:frame];
    [_backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    [_backgroundView setBackgroundColor:[UIColor blackColor]];
    
    [self.view addSubview:_backgroundView];
    
    // NavBar
    self.navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, -44, frame.size.width, 44)];
    [_navBar setBarStyle:UIBarStyleBlackTranslucent];
    [_navBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    UINavigationItem *navTitleItem = [[UINavigationItem alloc] initWithTitle:@"Music Visualizer"];
    [_navBar pushNavigationItem:navTitleItem animated:NO];
    
    [self.view addSubview:_navBar];
    
    // ToolBar
    self.toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 320, frame.size.width, 44)];
    [_toolBar setBarStyle:UIBarStyleBlackTranslucent];
    [_toolBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    
    UIBarButtonItem *pickBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(pickSong)];
    
    self.playBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPause)];
    
    self.pauseBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playPause)];
    
    self.playBBI2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(playPause2)];
    
    self.pauseBBI2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPause target:self action:@selector(playPause2)];
    
    UIBarButtonItem *leftFlexBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *middleFlexBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *rightFlexBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    self.playItems_not1and2 = [NSArray arrayWithObjects:pickBBI, leftFlexBBI, _pauseBBI, middleFlexBBI, _pauseBBI2, rightFlexBBI, nil];
    self.playItems_2not1 = [NSArray arrayWithObjects:pickBBI, leftFlexBBI, _pauseBBI, middleFlexBBI, _playBBI2, rightFlexBBI, nil];
    self.playItems_1not2 = [NSArray arrayWithObjects:pickBBI, leftFlexBBI, _playBBI, middleFlexBBI, _pauseBBI2, rightFlexBBI, nil];
    self.playItems_1and2 = [NSArray arrayWithObjects:pickBBI, leftFlexBBI, _playBBI, middleFlexBBI, _playBBI2, rightFlexBBI, nil];
    
    [_toolBar setItems:_playItems_not1and2];
    
    [self.view addSubview:_toolBar];
    
    _isBarHide = YES;
    _isPlaying = NO;
    _isPlaying2 = NO;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureHandler:)];
    [_backgroundView addGestureRecognizer:tapGR];
}

- (void)toggleBars {
    CGFloat navBarDis = -44;
    CGFloat toolBarDis = 44;
    if (_isBarHide ) {
        navBarDis = -navBarDis;
        toolBarDis = -toolBarDis;
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        CGPoint navBarCenter = _navBar.center;
        navBarCenter.y += navBarDis;
        [_navBar setCenter:navBarCenter];
        
        CGPoint toolBarCenter = _toolBar.center;
        toolBarCenter.y += toolBarDis;
        [_toolBar setCenter:toolBarCenter];
    }];
    
    _isBarHide = !_isBarHide;
}

- (void)tapGestureHandler:(UITapGestureRecognizer *)tapGR {
    [self toggleBars];
}


#pragma mark - Music control

- (void)playPause {
    if (_isPlaying) {
        // Pause audio here
        [_audioPlayer pause];
    }
    else {
        // Play audio here
        [_audioPlayer play];
    }
    
    _isPlaying = !_isPlaying;
    
    if (_isPlaying && _isPlaying2) {
        [_toolBar setItems:_playItems_1and2];  // toggle play/pause button
    } else if (_isPlaying) {
        [_toolBar setItems:_playItems_1not2];  // toggle play/pause button
    } else if (_isPlaying2) {
        [_toolBar setItems:_playItems_2not1];  // toggle play/pause button
    } else {
        [_toolBar setItems:_playItems_not1and2];  // toggle play/pause button
    }
}


- (void)playPause2 {
    if (_isPlaying2) {
        // Pause audio here
        [_audioPlayer2 pause];
    }
    else {
        // Play audio here
        [_audioPlayer2 play];
    }
    
    _isPlaying2 = !_isPlaying2;
    
    if (_isPlaying && _isPlaying2) {
        [_toolBar setItems:_playItems_1and2];  // toggle play/pause button
    } else if (_isPlaying) {
        [_toolBar setItems:_playItems_1not2];  // toggle play/pause button
    } else if (_isPlaying2) {
        [_toolBar setItems:_playItems_2not1];  // toggle play/pause button
    } else {
        [_toolBar setItems:_playItems_not1and2];  // toggle play/pause button
    }
}



- (void)playURL:(NSURL *)url {
    if (_isPlaying) {
        [self playPause]; // Pause the previous audio player
    }

    // Add audioPlayer configurations here
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    [_audioPlayer setMeteringEnabled:YES];
    [_visualizer setAudioPlayer:_audioPlayer];
    
    self.audioPlayer.enableRate=YES;
    self.audioPlayer.rate = 1.0f;
    self.audioPlayer.pan = -1.0;
    
    [_audioPlayer setNumberOfLoops:-1];
    
    [self playPause];   // Play
}

- (void)playURL2:(NSURL *)url {

    // Add audioPlayer configurations here
    self.audioPlayer2 = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    [_audioPlayer2 setMeteringEnabled:YES];
    [_visualizer2 setAudioPlayer:_audioPlayer2];
    
    self.audioPlayer2.enableRate=YES;
    self.audioPlayer2.rate = 1.0f;
    self.audioPlayer2.pan = 1.0;
    
    [_audioPlayer2 setNumberOfLoops:-1];
}

#pragma mark - Media Picker

/*
 * This method is called when the user presses the magnifier button (because this selector was used 
 * to create the button in configureBars, defined earlier in this file). It displays a media picker 
 * screen to the user configured to show only audio files.
 */
- (void)pickSong {
#if TARGET_IPHONE_SIMULATOR
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Media picker doesn't work in the simulator, please run this app on a device." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
#else
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    [picker setDelegate:self];
    [picker setAllowsPickingMultipleItems: YES];
    [self presentViewController:picker animated:YES completion:NULL];
#endif
}

#pragma mark - Media Picker Delegate

/*
 * This method is called when the user chooses something from the media picker screen. It dismisses the media picker screen
 * and plays the selected song.
 */
- (void)mediaPicker:(MPMediaPickerController *) mediaPicker didPickMediaItems:(MPMediaItemCollection *) collection {
  
    // remove the media picker screen
    [self dismissViewControllerAnimated:YES completion:NULL];

    // grab the first selection (media picker is capable of returning more than one selected item,
    // but this app only deals with one song at a time)
    MPMediaItem *item = [[collection items] objectAtIndex:0];
    MPMediaItem *item2 = [[collection items] objectAtIndex:1];
    NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
    [_navBar.topItem setTitle:title];
  
    // get a URL reference to the selected item
    NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
    NSURL *url2 = [item2 valueForProperty:MPMediaItemPropertyAssetURL];
    
    NSLog(@"url1=%@", url);
    NSLog(@"url2=%@", url2);

    // pass the URL to playURL:, defined earlier in this file
    [self playURL:url];
    [self playURL2:url2];
}

/*
 * This method is called when the user cancels out of the media picker. It just dismisses the media picker screen.
 */
- (void)mediaPickerDidCancel:(MPMediaPickerController *) mediaPicker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)configureAudioPlayer {
    NSURL *audioFileURL = [[NSBundle mainBundle] URLForResource:@"DemoSong" withExtension:@"m4a"];
    NSError *error;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [_audioPlayer setMeteringEnabled:YES];
    self.audioPlayer.enableRate=YES;
    self.audioPlayer.rate = 1.0f;
    self.audioPlayer2.pan = -1.0;
    [_visualizer setAudioPlayer:_audioPlayer];
    
    [_audioPlayer setNumberOfLoops:-1];
    
    
    self.audioPlayer2 = [[AVAudioPlayer alloc] initWithContentsOfURL:audioFileURL error:&error];
    if (error) {
        NSLog(@"%@", [error localizedDescription]);
    }
    
    [_audioPlayer2 setMeteringEnabled:YES];
    self.audioPlayer2.enableRate=YES;
    self.audioPlayer2.rate = 1.0f;
    self.audioPlayer2.pan = 1.0;
    [_visualizer2 setAudioPlayer:_audioPlayer2];
    
    [_audioPlayer2 setNumberOfLoops:-1];
}

- (void)configureAudioSession {
    NSError *error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
    
    if (error) {
        NSLog(@"Error setting category: %@", [error description]);
    }
}

-(void)playbackSpeedSliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    self.audioPlayer.rate = slider.value;
}

-(IBAction)createPlaybackSpeedSlider
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect frame = screenRect;
    frame.size.height /= 8.0;
    frame.origin.y += screenRect.size.height/8.0;
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    
    [slider setMinimumTrackImage:[UIImage imageNamed:@"slider_minimum.png"] forState:UIControlStateNormal];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"slider_maximum.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateHighlighted];
    
    [slider addTarget:self action:@selector(playbackSpeedSliderAction:) forControlEvents:UIControlEventValueChanged];
    [slider setBackgroundColor:[UIColor whiteColor]];
    slider.minimumValue = 0.0;
    slider.maximumValue = 2.0;
    slider.continuous = YES;
    slider.value = 1.0;
    
    [self.view addSubview:slider];
}


-(void)playbackSpeedSliderAction2:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    self.audioPlayer2.rate = slider.value;
}

-(IBAction)createPlaybackSpeedSlider2
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect frame = screenRect;
    frame.size.height /= 8.0;
    frame.origin.y += screenRect.size.height*(2.0/8.0);
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    
    [slider setMinimumTrackImage:[UIImage imageNamed:@"slider_minimum.png"] forState:UIControlStateNormal];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"slider_maximum.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateHighlighted];
    
    [slider addTarget:self action:@selector(playbackSpeedSliderAction2:) forControlEvents:UIControlEventValueChanged];
    [slider setBackgroundColor:[UIColor whiteColor]];
    slider.minimumValue = 0.0;
    slider.maximumValue = 2.0;
    slider.continuous = YES;
    slider.value = 1.0;
    
    [self.view addSubview:slider];
}


-(void)mixerSliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    //NSLog(@"mixer slider value = %f", slider.value);
    self.audioPlayer.volume = 1.0-slider.value;
    self.audioPlayer2.volume = slider.value;
}

-(IBAction)createMixerSlider
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect frame = screenRect;
    frame.size.height /= 8.0;
    frame.origin.y += screenRect.size.height*(3.0/8.0);
    UISlider *slider = [[UISlider alloc] initWithFrame:frame];
    
    [slider setMinimumTrackImage:[UIImage imageNamed:@"slider_minimum.png"] forState:UIControlStateNormal];
    [slider setMaximumTrackImage:[UIImage imageNamed:@"slider_maximum.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateNormal];
    [slider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateHighlighted];
    
    [slider addTarget:self action:@selector(mixerSliderAction:) forControlEvents:UIControlEventValueChanged];
    [slider setBackgroundColor:[UIColor whiteColor]];
    slider.minimumValue = 0.0;
    slider.maximumValue = 1.0;
    slider.continuous = YES;
    slider.value = 0.5;
    
    [self.view addSubview:slider];
}

-(void)songPositionSliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    NSLog(@"song position slider value = %f", slider.value);
    self.audioPlayer.currentTime = slider.value;
}

- (void)updateSongPositionTimerHandler
{
    //NSLog(@"update currentTime=%f duration=%f", self.audioPlayer.currentTime, self.audioPlayer.duration);
    self.songPositionSlider.value = self.audioPlayer.currentTime;
    if (self.songPositionSlider.value > self.songLoopback2Slider.value) {
        self.songPositionSlider.value = self.songLoopback1Slider.value;
        self.audioPlayer.currentTime = self.songLoopback1Slider.value;
    }
}

-(IBAction)createSongPositionSlider
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect frame = screenRect;
    frame.size.height /= 8.0;
    frame.origin.y += screenRect.size.height*(4.0/8.0);
    self.songPositionSlider = [[UISlider alloc] initWithFrame:frame];
    
    [self.songPositionSlider setMinimumTrackImage:[UIImage imageNamed:@"slider_minimum.png"] forState:UIControlStateNormal];
    [self.songPositionSlider setMaximumTrackImage:[UIImage imageNamed:@"slider_maximum.png"] forState:UIControlStateNormal];
    [self.songPositionSlider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateNormal];
    [self.songPositionSlider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateHighlighted];
    
    [self.songPositionSlider addTarget:self action:@selector(songPositionSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.songPositionSlider setBackgroundColor:[UIColor whiteColor]];
    self.songPositionSlider.minimumValue = 0.0;
    self.songPositionSlider.maximumValue = self.audioPlayer.duration;
    NSLog(@"self.audioPlayer.duration=%f", self.audioPlayer.duration);
    self.songPositionSlider.continuous = YES;
    self.songPositionSlider.value = 0.0;
    
    [self.view addSubview:self.songPositionSlider];
}

-(void)songLoopback1SliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    NSLog(@"song loopback slider1 value = %f", slider.value);
}

-(IBAction)createSongLoopback1Slider
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect frame = screenRect;
    frame.size.height /= 8.0;
    frame.origin.y += screenRect.size.height*(5.0/8.0);
    self.songLoopback1Slider = [[UISlider alloc] initWithFrame:frame];
    
    [self.songLoopback1Slider setMinimumTrackImage:[UIImage imageNamed:@"slider_minimum.png"] forState:UIControlStateNormal];
    [self.songLoopback1Slider setMaximumTrackImage:[UIImage imageNamed:@"slider_maximum.png"] forState:UIControlStateNormal];
    [self.songLoopback1Slider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateNormal];
    [self.songLoopback1Slider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateHighlighted];
    
    [self.songLoopback1Slider addTarget:self action:@selector(songLoopback1SliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.songLoopback1Slider setBackgroundColor:[UIColor whiteColor]];

    self.songLoopback1Slider.value = 0.0;
    self.songLoopback1Slider.continuous = YES;
    self.songLoopback1Slider.minimumValue = 0.0;
    self.songLoopback1Slider.maximumValue = self.audioPlayer.duration;
    
    [self.view addSubview:self.songLoopback1Slider];
}

-(void)songLoopback2SliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;
    NSLog(@"song loopback slider2 value = %f", slider.value);
}

-(IBAction)createSongLoopback2Slider
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect frame = screenRect;
    frame.size.height /= 8.0;
    frame.origin.y += screenRect.size.height*(6.0/8.0);
    self.songLoopback2Slider = [[UISlider alloc] initWithFrame:frame];
    
    [self.songLoopback2Slider setMinimumTrackImage:[UIImage imageNamed:@"slider_minimum.png"] forState:UIControlStateNormal];
    [self.songLoopback2Slider setMaximumTrackImage:[UIImage imageNamed:@"slider_maximum.png"] forState:UIControlStateNormal];
    [self.songLoopback2Slider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateNormal];
    [self.songLoopback2Slider setThumbImage:[UIImage imageNamed:@"slider_tab.png"] forState:UIControlStateHighlighted];
    
    [self.songLoopback2Slider addTarget:self action:@selector(songLoopback2SliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.songLoopback2Slider setBackgroundColor:[UIColor whiteColor]];

    self.songLoopback2Slider.value = self.audioPlayer.duration;
    self.songLoopback2Slider.continuous = YES;
    self.songLoopback2Slider.minimumValue = 0.0;
    self.songLoopback2Slider.maximumValue = self.audioPlayer.duration;
    
    [self.view addSubview:self.songLoopback2Slider];
}

@end
