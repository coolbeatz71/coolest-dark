//
//  15-objective-c.m
//  Objective-C tour: interfaces, categories, protocols, blocks, ARC.
//

#import <Foundation/Foundation.h>

/** Severity levels for a log line. */
typedef NS_ENUM(NSInteger, Severity) {
    SeverityDebug = 0,
    SeverityInfo,
    SeverityWarning,
    SeverityError
};

NS_ASSUME_NONNULL_BEGIN

/**
 *  A repository contract.
 *
 *  @param identifier the identifier to look up
 *  @return the entity, or nil
 */
@protocol Repository <NSObject>
@required
- (nullable id)findById:(NSInteger)identifier error:(NSError **)error;
@optional
- (void)watchAllWithLimit:(NSUInteger)limit completion:(void (^)(NSArray *entries))completion;
@end

/** An immutable value type. */
@interface LogEntry : NSObject <NSCopying>

@property (nonatomic, copy, readonly) NSString *message;
@property (nonatomic, assign, readonly) Severity severity;
@property (nonatomic, copy, readonly) NSArray<NSString *> *tags;

- (instancetype)initWithMessage:(NSString *)message
                       severity:(Severity)severity NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end

@implementation LogEntry

- (instancetype)initWithMessage:(NSString *)message severity:(Severity)severity {
    self = [super init];
    if (self) {
        _message = [message copy];  // inline comment
        _severity = severity;
        _tags = @[];
    }
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    return [[LogEntry allocWithZone:zone] initWithMessage:self.message severity:self.severity];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"[%ld] %@ (%lu tags)",
            (long)self.severity, self.message, (unsigned long)self.tags.count];
}

@end

/** Category adding convenience behaviour. */
@interface LogEntry (Shouting)
- (NSString *)shout;
@end

@implementation LogEntry (Shouting)
- (NSString *)shout { return [self.message uppercaseString]; }
@end

NS_ASSUME_NONNULL_END
