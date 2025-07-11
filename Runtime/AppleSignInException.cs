using System;

namespace Vuzmir.UnityAppleSignIn

{
    public class AppleSignInException : Exception
    {
        public AppleSignInError Error { get; private set; }
        public AppleSignInException(AppleSignInError error, string message) : base(error + " | " + message)
        {
            Error = error;
        }
    }
}