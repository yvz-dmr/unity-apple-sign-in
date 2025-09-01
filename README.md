# Apple Sign In Plugin for Unity

## Overview
This plugin provides seamless Apple sign in support for Unity applications targeting iOS. It handles native setup automatically and provides a simple C# API to sign in users and retrieve their profile info.

## Installation

### By [pckgs.io](https://pckgs.io)

Add the following **scoped registry** to your project's `Packages/manifest.json` file:

```json
"scopedRegistries" : [
  {
    "name": "pckgs.io",
    "url": "https://upm.pckgs.io",
    "scopes": [
      "com.vuzmir"
    ]
  }
],
```

Then add the package dependency under the "dependencies" section:

```json
"dependencies" : {
  "com.vuzmir.apple-sign-in": "1.0.0"
}
```

### By Git Url
You can install this plugin via Git URL using Unity Package Manager.

```
https://github.com/yvz-dmr/unity-apple-sign-in.git
```

## Configuration

Sign in with Apple must be properly set up for your app’s Bundle ID in the Apple Developer Portal.

No additional configuration is required in Unity.

## Usage

Here’s a basic example of how to use it in a MonoBehaviour:

```csharp
using System.Threading.Tasks;
using UnityEngine;
using Vuzmir.UnityAppleSignIn;

public class LoginManager : MonoBehaviour
{
    public async void SignInWithApple()
    {
        try
        {
            var result = await new AppleSignInManager().SignIn();
            // Handle result
            Debug.Log(result.IdToken);
        }
        catch (AppleSignInException ex)
        {
            // Handle error
            Debug.LogError($"Apple Sign-In failed: {ex.Message}");
        }
    }
}
```
