//
//  GeneralCommunitiesView.swift
//  Lunar
//
//  Created by Mani on 20/07/2023.
//

import SwiftUI

struct GeneralCommunitiesView: View {
  @AppStorage("quicklinks") var quicklinks = Settings.quicklinks

  var body: some View {
    ForEach(quicklinks, id: \.self) { quicklink in
      NavigationLink {
        ObservedPostsView(
          postsFetcher: ObservablePostsFetcher(
            sortParameter: quicklink.sort,
            typeParameter: quicklink.type
          ),
          title: quicklink.title
        )
      } label: {
        GeneralCommunityQuicklinkButton(
          image: quicklink.icon,
          hexColor: quicklink.iconColor,
          title: quicklink.title,
          brightness: quicklink.brightness,
          saturation: quicklink.saturation
        )
      }
    }
  }
}