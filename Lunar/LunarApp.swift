//
//  LunarApp.swift
//  Lunar
//
//  Created by Mani on 04/07/2023.
//

import SwiftUI

@main
struct LunarApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
  
  var body: some Scene {
    WindowGroup {
      EntryView()
        .task {
          AppearanceController.shared.setAppearance()
        }
    }
  }
}
