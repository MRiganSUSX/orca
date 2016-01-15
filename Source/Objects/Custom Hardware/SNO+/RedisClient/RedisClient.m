//
//  RedisClient.m
//  Orca
//
//  Created by Eric Marzec on 1/15/16.
//
//

#import "RedisClient.h"

#define DEFUALT_PORT -1
@implementation RedisClient

@synthesize port;
@synthesize timeout;

- (instancetype)init
{
    self = [self initWithHostName: @"" withPort: DEFUALT_PORT];
    return self;
}
- (id)initWithHostName: (NSString*) _host withPort: (int) _port{
    self = [super init];
    if (self) {
        host = _host;
        port = _port;
        timeout = 1000; // Initialize timeout to 1 second
    }
    return self;
}
- (void) connect {
    // Separate the seconds and microseconds value
    // timeout is in milliseconds
    struct timeval tv = {timeout/1000, (timeout%1000)*1000};
    context = redisConnectWithTimeout([host UTF8String], port, tv);
    if (context == NULL) {
        NSException *excep = [NSException exceptionWithName:@"RedisClient"
                         reason:@"Connection failed" 
                         userInfo: nil];
        [excep raise];
    }
    else if (context->err) {
       NSString *err = [NSString stringWithUTF8String:context->errstr]; 
       [self disconnect];
       NSException *excep = [NSException exceptionWithName:@"RedisClient"
                         reason:err
                         userInfo: nil];
        [excep raise];
    }
}
- (void) disconnect{
   if(context) {
       redisFree(context);
       context = NULL;
   }
}
- (redisReply*) vcommand:(char *)fmt args:(va_list)ap{
    if (context == NULL) {
        [self connect];
    }
    redisReply *r = redisvCommand(context,fmt,ap);
    if (r == NULL) {
        NSString *err = [NSString stringWithUTF8String:context->errstr];
        [self disconnect];
        NSException *excep = [NSException exceptionWithName:@"RedisClient"
                           reason:err 
                           userInfo:nil];
        [excep raise];
    }
    
    if(r->type == REDIS_REPLY_ERROR) {
        NSString *err = [NSString stringWithUTF8String:r->str];
        freeReplyObject(r);
        NSException *excep = [NSException exceptionWithName:@"RedisClient"
                             reason:err
                             userInfo:nil];
        [excep raise];
    }
    return r;
}
- (redisReply*) command: (char *) fmt, ... {
    /*
     *  Sends a command to host using the Redis protocol. 
     *  Takes a variable number of arguements with a similar format to printf().
     *
     *       e.g.
     *      redisReply *r = [self command:"mtcd_read 0x34"];
     *      freeReplyObject(r);
     *
     *  Replies should be freed by calling the freeReplyObject function.
     */
    va_list ap;
    va_start(ap,fmt);
    redisReply *r = [self vcommand:fmt args:ap];
    va_end(ap);
    return r;
}
- (void) okCommand: (char *) fmt, ... {
    va_list ap;
    va_start(ap,fmt);
    redisReply *r = [self vcommand:fmt args:ap];
    va_end(ap);
    if (r->type != REDIS_REPLY_STATUS) {
        NSException *excep = [NSException exceptionWithName:@"RedisClient"
                           reason:@"unexpected response type" 
                           userInfo:nil];
        [excep raise];
    }
    freeReplyObject(r);
}
- (int) intCommand: (char *) fmt, ... {
    va_list ap;
    va_start(ap,fmt);
    redisReply *r = [self vcommand:fmt args:ap];
    va_end(ap);
    if (r->type != REDIS_REPLY_INTEGER) {
        NSException *excep = [NSException exceptionWithName:@"RedisClient"
                           reason:@"unexpected response type" 
                           userInfo:nil];
        [excep raise];
    }
    int responseVal = r->integer;
    freeReplyObject(r);
    return responseVal;
}
@end
