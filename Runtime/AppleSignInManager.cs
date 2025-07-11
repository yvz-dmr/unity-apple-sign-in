#if UNITY_IOS
using System.Runtime.InteropServices;
using AOT;
#endif
using UnityEngine;
using System.Threading.Tasks;

namespace Vuzmir.UnityAppleSignIn
{
    public class AppleSignInManager
    {
#if UNITY_IOS
        [DllImport("__Internal")]
        private static extern void _StartAppleSignIn(SignInCallback callback, ErrorCallback errorCallback);

        private delegate void SignInCallback(string userId, string idToken, string fullName, string email);
        private delegate void ErrorCallback(int code, string error);
        private static TaskCompletionSource<AppleSignInResult> activeCompletion;

        [MonoPInvokeCallback(typeof(SignInCallback))]
        private static void OnSignedIn(string userId, string idToken, string fullName, string email)
        {
            activeCompletion?.TrySetResult(new AppleSignInResult(userId, idToken, fullName, email));
            activeCompletion = null;
        }

        [MonoPInvokeCallback(typeof(ErrorCallback))]
        private static void OnSignInError(int code, string error)
        {
            var appleSignInError = code switch
            {                
                1001 => AppleSignInError.Cancelled,
                1002 => AppleSignInError.InvalidResponse,
                1003 => AppleSignInError.RequestNotHandled,
                1004 => AppleSignInError.RequestFailed,
                _ => AppleSignInError.Unknown
            };
            activeCompletion?.TrySetException(new AppleSignInException(appleSignInError, error));
            activeCompletion = null;
        }
#endif

        public Task<AppleSignInResult> SignIn()
        {
#if !UNITY_EDITOR && UNITY_IOS
        activeCompletion = new TaskCompletionSource<AppleSignInResult>();
        _StartAppleSignIn(OnSignedIn, OnSignInError);
        return activeCompletion.Task;
#else
            throw new AppleSignInException(
                            AppleSignInError.NotSupported,
                            $"Apple sign in is not supported on platform {Application.platform}");
#endif
        }

    }
}