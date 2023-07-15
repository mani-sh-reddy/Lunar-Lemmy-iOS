//
//  MoreCommunitiesView.swift
//  Lunar
//
//  Created by Mani on 15/07/2023.
//

import SwiftUI

struct MoreCommunitiesView: View {
    @StateObject var communityFetcher: CommunityFetcher

    var body: some View {
        List {
            ForEach(communityFetcher.communities, id: \.community.id) { community in
                NavigationLink(destination:
                    PostsListView(postFetcher: PostFetcher(communityID: community.community.id, prop: [:]), prop: [:], communityID: community.community.id, communityHeading: community.community.title)
                ) {
                    CommunityRowView(community: community)
                }
                .onAppear {
                    communityFetcher.loadMoreContentIfNeeded(currentItem: community, loadInfinitely: true)

                }
                
              
            }
            
            .accentColor(Color.primary)
            if communityFetcher.isLoading {
                ProgressView()
            }
        }.navigationTitle("New Communities")
    }
}

struct MoreCommunitiesView_Previews: PreviewProvider {
    static var previews: some View {
        let communityFetcher = CommunityFetcher(loadInfinitely: true, sortParameter: "New", limitParameter: "50")
        MoreCommunitiesView(communityFetcher: communityFetcher)
    }
}
