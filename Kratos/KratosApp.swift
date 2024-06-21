//
//  KratosApp.swift
//  Kratos
//
//  Created by Dhruv Bhagavatula on 6/11/24.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
      
    GIDSignIn.sharedInstance.restorePreviousSignIn()
      
    return true
  }
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}

@main
struct YourApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject private var authViewModel = AuthViewModel()


  var body: some Scene {
    WindowGroup {
      NavigationView {
        LoginView()
            .environmentObject(authViewModel)
      }
    }
  }
}
