//
//  SettingsFeedView.swift
//  Lunar
//
//  Created by Mani on 08/09/2023.
//

import Defaults
import Foundation
import SwiftUI

struct SettingsFeedView: View {
  @Default(.autoCollapseBots) var autoCollapseBots

  var body: some View {
    List {
      // MARK: - Posts Section

      Section {
        Toggle(isOn: $autoCollapseBots) {
          Text("Auto-collapse Bots")
        }
      } header: {
        Text("Comments")
      }
    }
    .navigationTitle("Feed Options")
  }
}

struct SettingsFeedView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsFeedView()
  }
}
