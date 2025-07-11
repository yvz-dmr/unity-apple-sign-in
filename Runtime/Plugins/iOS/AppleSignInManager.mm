#import <AuthenticationServices/AuthenticationServices.h>
#import <Foundation/Foundation.h>

@interface AppleSignInManager
    : NSObject <ASAuthorizationControllerDelegate,
                ASAuthorizationControllerPresentationContextProviding>

@property(nonatomic, copy) void (^onSignedIn)
    (const char *userId, const char *idToken, const char *fullName,
     const char *email);
@property(nonatomic, copy) void (^onSignInError)
    (const int code, const char *error);

@end

@implementation AppleSignInManager {
  ASAuthorizationController *_authController;
}

+ (AppleSignInManager *)sharedInstance {
  static AppleSignInManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[AppleSignInManager alloc] init];
  });
  return sharedInstance;
}

- (void)performAppleSignIn:(void (^)(const char *userId, const char *idToken,
                                     const char *fullName,
                                     const char *email))callback
          addErrorCallback:
              (void (^)(const int code, const char *error))errorCallback {
  self.onSignedIn = callback;
  self.onSignInError = errorCallback;

  ASAuthorizationAppleIDProvider *provider =
      [[ASAuthorizationAppleIDProvider alloc] init];
  ASAuthorizationAppleIDRequest *request = [provider createRequest];
  request.requestedScopes =
      @[ ASAuthorizationScopeFullName, ASAuthorizationScopeEmail ];
  _authController = [[ASAuthorizationController alloc]
      initWithAuthorizationRequests:@[ request ]];
  _authController.delegate = self;
  _authController.presentationContextProvider = self;
  [_authController performRequests];
}

// Called when the user successfully completes the Apple Sign-In
- (void)authorizationController:(ASAuthorizationController *)controller
    didCompleteWithAuthorization:(ASAuthorization *)authorization {
  if ([authorization.credential
          isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
    ASAuthorizationAppleIDCredential *credential =
        (ASAuthorizationAppleIDCredential *)authorization.credential;

    NSString *userId = credential.user;
    NSString *email = credential.email ?: @"";
    NSString *fullName = [NSString
        stringWithFormat:@"%@ %@", credential.fullName.givenName ?: @"",
                         credential.fullName.familyName ?: @""];
    NSString *idToken = [[NSString alloc] initWithData:credential.identityToken
                                              encoding:NSUTF8StringEncoding];

    // Allocate memory for the strings and copy the values
    const char *userIdCStr = [userId UTF8String];
    const char *idTokenCStr = [idToken UTF8String];
    const char *fullNameCStr = [fullName UTF8String];
    const char *emailCStr = [email UTF8String];

    // Call the success callback with copied values
    self.onSignedIn(strdup(userIdCStr), strdup(idTokenCStr),
                    strdup(fullNameCStr), strdup(emailCStr));
  }
}

// Called if there is an error with Apple Sign-In
- (void)authorizationController:(ASAuthorizationController *)controller
           didCompleteWithError:(NSError *)error {
  int errorCode = (int)error.code;
  NSString *errorMessage = [error localizedDescription];
  const char *errorCStr = [errorMessage UTF8String];
  self.onSignInError(errorCode, strdup(errorCStr));
}

// Specifies the view to present the authorization
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:
    (ASAuthorizationController *)controller {
  return [UIApplication sharedApplication].keyWindow;
}

@end

// External function to start Apple Sign-In from Unity
extern "C" {

typedef void (*AppleSignInCallback)(const char *, const char *, const char *,
                                    const char *);
typedef void (*AppleSignInErrorCallback)(const int, const char *);

void _StartAppleSignIn(AppleSignInCallback callback,
                       AppleSignInErrorCallback errorCallback) {

  [[AppleSignInManager sharedInstance]
      performAppleSignIn:^(const char *userId, const char *idToken,
                           const char *fullName, const char *email) {
        if (callback != NULL) {
          callback(userId, idToken, fullName, email);
        }
      }
      addErrorCallback:^(const int code, const char *error) {
        if (errorCallback != NULL) {
          errorCallback(code, error);
        }
      }];
}
}
