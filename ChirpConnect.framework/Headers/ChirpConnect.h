/*------------------------------------------------------------------------------
 *
 *  ChirpConnect.h
 *
 *  This file is part of the Chirp Connect SDK for iOS.
 *  For full information on usage and licensing, see http://chirp.io/
 *
 *  Copyright © 2011-2018, Asio Ltd.
 *  All rights reserved.
 *
 *----------------------------------------------------------------------------*/

@import AudioToolbox;
@import Foundation;

#import "chirp_connect_states.h"
#import "chirp_connect_errors.h"
#import "chirp_connect_version.h"

FOUNDATION_EXPORT double FrameworkVersionNumber;
FOUNDATION_EXPORT const unsigned char FrameworkVersionString[];

/*------------------------------------------------------------------------------
    Chirp classes & extensions
------------------------------------------------------------------------------*/

typedef chirp_connect_state_t CHIRP_CONNECT_STATE;

typedef void (^ChirpSendingBlock)           (NSData * _Nonnull data);
typedef void (^ChirpSentBlock)              (NSData * _Nonnull data);
typedef void (^ChirpReceivingBlock)         (void);
typedef void (^ChirpReceivedBlock)          (NSData * _Nonnull data);
typedef void (^ChirpStateUpdatedBlock)      (CHIRP_CONNECT_STATE oldState,
                                             CHIRP_CONNECT_STATE newState);
typedef void (^ChirpAuthenticationStateUpdatedBlock)(NSError *_Nullable error);

typedef void (^ChirpAudioBufferUpdatedBlock) (AudioBuffer buffer,
                                             NSUInteger numberOfFrames);
typedef void (^ChirpVolumeBlock)            (float volume);
typedef void (^ChirpStoppedBlock)           (void);
typedef void (^ChirpGetLicenceBlock)        (NSString *_Nullable licence,
                                             NSError *_Nullable error);

/**
 The main Chirp Connect SDK class. Use this to send and receive data using
 sound. Only one single instance should be instantiated per application.
 */
@interface ChirpConnect : NSObject

#pragma mark - Properties

/**
 The volume of the Chirp SDK within your application. This is not the overall
 system volume, just the volume of the chirp output into the main audio mix.
 
 Valid values are between 0.0 and 1.0.
 */
@property (nonatomic) float volume;

/**
 The volume of the OS hardware volume.
 
 Valid values are between 0.0 and 1.0.
 
 @warning Not currently supported on macOS
 */
@property (nonatomic, readonly) float systemVolume;

/**
 The maximum payload size, in bytes, that the SDK's current licence permits.
 
 @return The maximum number of bytes able to be sent by the SDK's
 current configuration.
 */
@property (nonatomic, readonly) size_t maxPayloadLength;

/**
 Get the current state of the SDK.
 */
@property (readonly) CHIRP_CONNECT_STATE state;

/**
 The full version string of the SDK and audio engine.
 */
@property (readonly) NSString * _Nonnull version;

/**
 Info on the current audio transmission settings.
 */
@property (readonly)  NSString * _Nonnull info;


#pragma mark - Methods
/*------------------------------------------------------------------------------
    Initialisation
------------------------------------------------------------------------------*/
- (ChirpConnect * _Nullable) initWithAppKey:(NSString * _Nonnull) key
                             andSecret:(NSString * _Nonnull) secret;

/**
 A block called when the SDK's licence is updated after initialisation,
 passed the nullable licence dictionary and error.
 */
@property (nonatomic, copy) ChirpAuthenticationStateUpdatedBlock _Nullable authenticationStateUpdatedBlock;

/**
 Fetch your default licence from the Chirp API. You can use
 setLicenceString: within completion handler.
 
 @param completion a non-nil ChirpGetLicenceBlock completion handler.
 */
- (void) getLicenceStringWithCompletion:(ChirpGetLicenceBlock _Nonnull) completion;

/**
 Manually set a licence. This must be done before starting the SDK via the
 `start` method.
 
 Licence strings can be downloaded using `getLicenceStringWithCompletion:` or,
 if you have been provided a licence to download manually, loaded directly
 using this method.

 @param  licence A valid, non-nil licence NSString
 @return nil if the licence is successfully set, otherwise an NSError.
 */
- (NSError * _Nullable) setLicenceString:(NSString * _Nonnull) licence;

/**
 Start the SDK running. This must be done before sending or receiving data
 using the SDK instance.
 
 @warning A licence must be set before calling this method
 @return nil if the engine is started, otherwise an NSError.
 */
- (NSError * _Nullable) start;

/**
 Stop the SDK running.

 @return nil if the SDK has started successfully, otherwise an NSError.
 */
- (NSError * _Nullable) stop;

/**
 A block called when the SDK has fully finished processing and stopped all
 audio IO.

 @param completion completion
 */
- (void) stopWithCompletion:(ChirpStoppedBlock _Nonnull) completion;

/**
 A block called when *system* volume changes, and when the SDK is started via
 the start: method. This will be a value between 0.0f and 1.0f, or -1.0f in an
 error condition.
 */
@property (nonatomic, copy) ChirpVolumeBlock _Nullable systemVolumeChangedBlock;

/**
 A block called when audio samples are ready.
 */
@property (nonatomic, copy) ChirpAudioBufferUpdatedBlock _Nullable audioBufferUpdatedBlock;

/*------------------------------------------------------------------------------
    Send / Receive
------------------------------------------------------------------------------*/

/**
 Send data. The data parameter must be a non-nil NSData instance that is valid
 for the currently configured SDK. The data instance's validity for sending
 can be checked using the isValidPayload: instance method.

 @param  data The data to be sent
 @return CHIRP_CONNECT_OK will start sending the data.
 */
- (NSError * _Nullable) send:(NSData *_Nonnull) data;

/**
 A block called when sending starts.
 It is passed the NSData being sent.
 */
@property (nonatomic, copy) ChirpSendingBlock _Nullable sendingBlock;

/**
 A block called when sending ends.
 It is passed the NSData that was sent.
 */
@property (nonatomic, copy) ChirpSentBlock _Nullable sentBlock;

/**
 A block called when receiving starts.
 */
@property (nonatomic, copy) ChirpReceivingBlock _Nullable receivingBlock;

/**
 A block called when receiving ends.
 It is passed the received NSData, or nil if the decode operation has failed.
 */
@property (nonatomic, copy) ChirpReceivedBlock _Nullable receivedBlock;

/**
 A block called when sending/receiving state changes.
 It is passed the old and new states.
 */
@property (nonatomic, copy) ChirpStateUpdatedBlock _Nullable stateUpdatedBlock;


/*------------------------------------------------------------------------------
    Configuration
------------------------------------------------------------------------------*/

/**
 Set whether or not to route audio to connected bluetooth audio accessories.
 Defaults to NO.
 @warning This must be set before calling `start`.
 */
@property (nonatomic, assign) BOOL shouldRouteAudioToBluetoothPeripherals;


/*------------------------------------------------------------------------------
    Convenience
------------------------------------------------------------------------------*/
/**
 The duration in seconds for a specified payload length in bytes.
 */
- (NSTimeInterval) durationForPayloadLength:(NSUInteger)length;

/**
 Check whether a non-nil NSData instance is valid and able to be sent using the
 Connect SDK as it is currently configured via its licence file.

 @param  data A non-nil NSData instance
 @return YES is the data instance is valid for sending
 */
- (BOOL) isValidPayload:(NSData *_Nonnull)data;

/**
 Generate random data which is guaranteed to be valid for the Connect SDK's
 current licence configuration.

 @param length the length of the payload to generate in bytes.
 @return NSData A non-nil, valid NSData instance with random bytes.
 */
- (NSData * _Nonnull)randomPayloadWithLength:(NSUInteger)length;

/**
 Generate random data with random length which is guaranteed to be valid for the Connect SDK's
 current licence configuration.
 Similar to running the randomPayloadWithLength:0
 
 @return NSData A non-nil, valid NSData instance with random bytes.
 */
- (NSData * _Nonnull)randomPayloadWithRandomLength;

/**
 Set the random seed used by the SDK. This is useful if you want to control
 the sequence of random payloads generated by `randomData`.
 
 @param  seed A positive integer.
 */
- (void) setRandomSeed:(NSUInteger) seed;

@end

/*------------------------------------------------------------------------------
    Notifications
------------------------------------------------------------------------------*/
#define CHIRP_STATIC_STRING static NSString * _Nonnull

CHIRP_STATIC_STRING CONNECT_NOTIFICATION_SENDING =
@"io.chirp.notification.sending";

CHIRP_STATIC_STRING CONNECT_NOTIFICATION_SENT =
@"io.chirp.notification.sent";

CHIRP_STATIC_STRING CONNECT_NOTIFICATION_RECEIVING =
@"io.chirp.notification.receiving";

CHIRP_STATIC_STRING CONNECT_NOTIFICATION_RECEIVED =
@"io.chirp.notification.received";

CHIRP_STATIC_STRING CONNECT_NOTIFICATION_VOLUME =
@"io.chirp.notification.volume";
CHIRP_STATIC_STRING CONNECT_NOTIFICATION_VOLUME_KEY_STATE =
@"volume";

CHIRP_STATIC_STRING CONNECT_NOTIFICATION_STATE =
@"io.chirp.notification.state";
CHIRP_STATIC_STRING CONNECT_NOTIFICATION_STATE_KEY_STATE =
@"state";

CHIRP_STATIC_STRING CONNECT_NOTIFICATION_LICENCE_UPDATED =
@"io.chirp.notification.licence";

CHIRP_STATIC_STRING CONNECT_NOTIFICATION_ANALYTIC_SENT =
@"io.chirp.notification.analytic";
CHIRP_STATIC_STRING CONNECT_NOTIFICATION_ANALYTIC_KEY_METRIC =
@"metric";

/*------------------------------------------------------------------------------
    Errors
------------------------------------------------------------------------------*/
CHIRP_STATIC_STRING CONNECT_ERROR_DOMAIN = @"io.chirp.error";
