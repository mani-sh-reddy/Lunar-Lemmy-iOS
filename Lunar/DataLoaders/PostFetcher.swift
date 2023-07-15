//
//  PostFetcher.swift
//  Lunar
//
//  Created by Mani on 09/07/2023.
//

import Alamofire
import Combine
import Foundation
import Kingfisher

@MainActor class PostFetcher: ObservableObject {
    @Published var posts = [PostElement]()
    @Published var isLoading = false

    private var currentPage = 1

    private var communityID: Int = 0
    private var prop: [String: String] = [:]

    init(communityID: Int, prop: [String: String]) {
        self.communityID = communityID
        self.prop = prop
        loadMoreContent()
    }

    func refreshContent() async {
        do {
            try await Task.sleep(nanoseconds: 2_000_000_000)
            posts = []
            currentPage = 1
            loadMoreContent()

        } catch {
            // TODO: do some error handling
        }
    }

    func loadMoreContentIfNeeded(currentItem item: PostElement?) {
        guard let item = item else {
            loadMoreContent()
            return
        }
        let thresholdIndex = posts.index(posts.endIndex, offsetBy: -3)
        if posts.firstIndex(where: { $0.post.id == item.post.id }) == thresholdIndex {
            loadMoreContent()
        }
    }

    private func loadMoreContent() {
        guard !isLoading else { return }

        isLoading = true

        let url = URL(string: buildEndpoint())!
        let cacher = ResponseCacher(behavior: .cache)

        AF.request(url) { urlRequest in
            urlRequest.cachePolicy = .returnCacheDataElseLoad
        }
        .cacheResponse(using: cacher)
        .validate(statusCode: 200 ..< 300)
        .responseDecodable(of: PostsModel.self) { response in
            switch response.result {
            case let .success(result):
                self.posts += result.posts
                self.isLoading = false
                self.currentPage += 1

                let cachableImageURLs = result.thumbnailURLs.compactMap { URL(string: $0) }
                    + result.avatarURLs.compactMap { URL(string: $0) }
                let prefetcher = ImagePrefetcher(urls: cachableImageURLs) { _, _, _ in }
                prefetcher.start()

            case let .failure(error):
                print("ERROR: \(error): \(error.errorDescription ?? "")")
            }
        }
    }

    private func buildEndpoint() -> String {
        let sortParameter = prop["sort"] ?? "Active"
        let typeParameter = prop["type"] ?? "All"

        let baseURL = "https://lemmy.world/api/v3/post/list"
        let sortQuery = "sort=\(sortParameter)"
        let limitQuery = "limit=5"
        let pageQuery = "page=\(currentPage)"

        var prefixQuery = ""

        if communityID == 0 {
            prefixQuery = "type_=\(typeParameter)"
        } else {
            prefixQuery = "community_id=\(communityID)"
        }

        let endpoint = "\(baseURL)?\(sortQuery)&\(limitQuery)&\(pageQuery)&\(prefixQuery)"
        print("ENDPOINT: \(endpoint)")
        return endpoint
    }
}