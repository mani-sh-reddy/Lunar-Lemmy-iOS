//
//  PostsListFetcher.swift
//  Lunar
//
//  Created by Mani on 09/07/2023.
//

import Alamofire
import Foundation
import Kingfisher
import SwiftUI

class PostsListFetcher: ObservableObject {
    @Published var posts: [PostElement] = []
    @Published var imageURLs: [String] = []
    @Published var isLoaded: Bool = false

    func fetch(endpoint: String) {
        guard let url = URL(string: endpoint) else {
            return
        }
        AF.request(url)
//        WILL BE USEFUL FOR IMAGES
//            .downloadProgress { progress in
//                // Update your progress indicator here
//                let loadingProgress = progress.fractionCompleted * 100
//                print("Download progress: \(loadingProgress)%")
//                DispatchQueue.main.async {
//                    if loadingProgress >= 100 {
//
//                    }
//                }
//            }
            .responseDecodable(of: PostsModel.self) { [weak self] response in
//            debugPrint("Response: \(response)")
                switch response.result {
                case let .success(result):

                    let imageURLStrings = result.avatarURLs + result.thumbnailURLs

                    let imageURLs = imageURLStrings.compactMap { URL(string: $0) }

                    let prefetcher = ImagePrefetcher(urls: imageURLs) {
                        skippedResources, failedResources, completedResources in
                        print("COMPLETED: \(completedResources.count)")
                        print("FAILED: \(failedResources.count)")
                        print("SKIPPED: \(skippedResources.count)")
                    }
                    prefetcher.start()

                    self?.posts = result.posts
                    self?.isLoaded = true

                case let .failure(error):
                    print("ERROR: \(error): \(error.errorDescription ?? "")")
                }
            }
    }
}
