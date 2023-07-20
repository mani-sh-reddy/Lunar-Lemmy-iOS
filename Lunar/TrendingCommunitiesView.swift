//
//  TrendingCommunitiesView.swift
//  Lunar
//
//  Created by Mani on 20/07/2023.
//

import SwiftUI

struct TrendingCommunitiesView: View {
    @StateObject var trendingCommunitiesFetcher: TrendingCommunitiesFetcher

    var body: some View {
        ForEach(trendingCommunitiesFetcher.communities, id: \.community.id) { community in
            NavigationLink(destination: PostsListView(postFetcher: PostFetcher(communityID: community.community.id, prop: [:]), prop: [:], communityID: community.community.id, title: community.community.title)) {
                CommunityRowView(community: community)
            }
        }
        if trendingCommunitiesFetcher.isLoading {
            ProgressView()
        }
        MoreCommunitiesLinkView()
    }
}