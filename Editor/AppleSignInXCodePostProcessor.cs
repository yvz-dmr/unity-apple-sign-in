#if UNITY_IOS
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using UnityEngine;

namespace Vuzmir.UnityAppleSignIn.Editor
{

    public class AppleSignInXCodePostProcessor
    {
        [PostProcessBuild]
        public static void ChangeXcodePlist(BuildTarget buildTarget, string pathToBuiltProject)
        {
            if (buildTarget != BuildTarget.iOS) return;

            string projectPath = PBXProject.GetPBXProjectPath(pathToBuiltProject);

            PBXProject project = new PBXProject();
            project.ReadFromFile(projectPath);

            var entitlementFilePath = $"{Application.productName}.entitlements";
            var capabilityManager = new ProjectCapabilityManager(
                projectPath, entitlementFilePath, targetGuid: project.GetUnityMainTargetGuid());

            // Add Sign In with Apple capability
            capabilityManager.AddSignInWithApple();
            capabilityManager.WriteToFile();
        }
    }
}
#endif