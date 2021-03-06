#import <XCTest/XCTest.h>
#import "SentrySession.h"

@interface SentrySessionTests : XCTestCase

@end

@implementation SentrySessionTests

- (void)testInitDefaultValues {
    SentrySession *session = [[SentrySession alloc] init];
    XCTAssertNotNil(session.sessionId);
    XCTAssertEqual(1, session.sequence);
    XCTAssertEqual(0, session.errors);
    XCTAssertTrue(session.init);
    XCTAssertNotNil(session.started);
    XCTAssertEqual(kSentrySessionStatusOk, session.status);
    XCTAssertNotNil(session.distinctId);

    XCTAssertNil(session.timestamp);
    XCTAssertNil(session.releaseName);
    XCTAssertNil(session.environment);
    XCTAssertNil(session.duration);
}

- (void)testSerializeDefaultValues {
    SentrySession *expected = [[SentrySession alloc] init];
    NSDictionary<NSString *, id>  *json = [expected serialize];
    SentrySession *actual = [[SentrySession alloc] initWithJSONObject:json];

    XCTAssertTrue([expected.sessionId isEqual:actual.sessionId]);
    XCTAssertEqual(expected.sequence, actual.sequence);
    XCTAssertEqual(expected.errors, actual.errors);
    // TODO: get XCT happy XCTAssertEqual(expected.init, actual.init);
    XCTAssertEqualWithAccuracy([expected.started timeIntervalSinceReferenceDate], [actual.started timeIntervalSinceReferenceDate], 1);
    XCTAssertEqual(expected.status, actual.status);
    XCTAssertEqual(expected.distinctId, actual.distinctId);
    XCTAssertNil(expected.timestamp);
    // Serialize session always have a timestamp (time of serialization)
    XCTAssertNotNil(actual.timestamp);
    XCTAssertNil(expected.releaseName);
    XCTAssertNil(actual.releaseName);
    XCTAssertNil(expected.environment);
    XCTAssertNil(actual.environment);
    XCTAssertNil(expected.duration);
    XCTAssertNil(actual.duration);
}

- (void)testSerializeExtraFieldsEndedSessionWithNilStatus {
    SentrySession *expected = [[SentrySession alloc] init];
    NSDate *timestamp = [NSDate date];
    [expected endSession];
    expected.environment = @"prod";
    expected.releaseName = @"io.sentry@5.0.0-test";
    NSDictionary<NSString *, id>  *json = [expected serialize];
    SentrySession *actual = [[SentrySession alloc] initWithJSONObject:json];

    XCTAssertTrue([expected.sessionId isEqual:actual.sessionId]);
    XCTAssertEqual(expected.sequence, actual.sequence);
    XCTAssertEqual(expected.errors, actual.errors);
    // TODO: get XCT happy XCTAssertEqual(expected.init, actual.init);
    XCTAssertEqualWithAccuracy([expected.started timeIntervalSinceReferenceDate], [actual.started timeIntervalSinceReferenceDate], 1);
    XCTAssertEqualWithAccuracy([timestamp timeIntervalSinceReferenceDate], [expected.timestamp timeIntervalSinceReferenceDate], 1);
    XCTAssertEqualWithAccuracy([expected.timestamp timeIntervalSinceReferenceDate], [actual.timestamp timeIntervalSinceReferenceDate], 1);
    XCTAssertEqual(expected.status, actual.status);
    XCTAssertEqual(expected.distinctId, actual.distinctId);
    XCTAssertEqual(expected.releaseName, actual.releaseName);
    XCTAssertEqual(expected.environment, actual.environment);
    XCTAssertEqual(expected.duration, actual.duration);
}

- (void)testSerializeErrorIncremented {
    SentrySession *expected = [[SentrySession alloc] init];
    [expected incrementErrors];
    [expected endSession];
    NSDictionary<NSString *, id>  *json = [expected serialize];
    SentrySession *actual = [[SentrySession alloc] initWithJSONObject:json];

    XCTAssertTrue([expected.sessionId isEqual:actual.sessionId]);
    XCTAssertEqual(expected.sequence, actual.sequence);
    XCTAssertEqual(expected.errors, actual.errors);
    // TODO: get XCT happy XCTAssertEqual(expected.init, actual.init);
    XCTAssertEqualWithAccuracy([expected.started timeIntervalSinceReferenceDate], [actual.started timeIntervalSinceReferenceDate], 1);
    XCTAssertEqualWithAccuracy([expected.timestamp timeIntervalSinceReferenceDate], [actual.timestamp timeIntervalSinceReferenceDate], 1);
    XCTAssertEqual(expected.status, actual.status);
    XCTAssertEqual(expected.distinctId, actual.distinctId);
    XCTAssertEqual(expected.releaseName, actual.releaseName);
    XCTAssertEqual(expected.environment, actual.environment);
    XCTAssertEqual(expected.duration, actual.duration);
}

- (void)testAbnormalSession {
    SentrySession *expected = [[SentrySession alloc] init];
    XCTAssertEqual(0, expected.errors);
    XCTAssertEqual(kSentrySessionStatusOk, expected.status);
    XCTAssertEqual(1, expected.sequence);
    [expected incrementErrors];
    XCTAssertEqual(1, expected.errors);
    XCTAssertEqual(kSentrySessionStatusAbnormal, expected.status);
    XCTAssertEqual(2, expected.sequence);
    [expected endSession];
    XCTAssertEqual(1, expected.errors);
    XCTAssertEqual(kSentrySessionStatusAbnormal, expected.status);
    XCTAssertEqual(3, expected.sequence);
}

- (void)testAbnormalExited {
    SentrySession *expected = [[SentrySession alloc] init];
    XCTAssertEqual(0, expected.errors);
    XCTAssertEqual(kSentrySessionStatusOk, expected.status);
    XCTAssertEqual(1, expected.sequence);
    [expected endSession];
    XCTAssertEqual(0, expected.errors);
    XCTAssertEqual(kSentrySessionStatusExited, expected.status);
    XCTAssertEqual(2, expected.sequence);
}

- (void)testExplicitStatus {
    SentrySession *expected = [[SentrySession alloc] init];
    XCTAssertEqual(kSentrySessionStatusOk, expected.status);
    XCTAssertEqual(1, expected.sequence);
    [expected crashedSession];
    XCTAssertEqual(0, expected.errors);
    XCTAssertEqual(kSentrySessionStatusCrashed, expected.status);
    XCTAssertEqual(2, expected.sequence);
}

@end
