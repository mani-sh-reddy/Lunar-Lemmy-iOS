//
//  PostsFetcher.swift
//  Lunar
//
//  Created by Mani on 23/07/2023.
//

import Alamofire
import Defaults
import Nuke
import SwiftUI

class PostsFetcher: ObservableObject {
  @Default(.activeAccount) var activeAccount
  @Default(.selectedInstance) var selectedInstance

  @Published var isLoading = false

  let imagePrefetcher = ImagePrefetcher(pipeline: ImagePipeline.shared)

  var sort: String
  var type: String
  var communityID: Int?
  var personID: Int?
  var instance: String?
  var filterKey: String
  var endpointPath: String
  //  var page: Int

  @State private var page: Int = 1

  private var parameters: EndpointParameters {
    EndpointParameters(
      endpointPath: endpointPath,
      sortParameter: sort,
      typeParameter: type,
      currentPage: page,
      limitParameter: 50,
      communityID: communityID,
      personID: personID,
      jwt: JWT().getJWTForActiveAccount(),
      instance: instance
    )
  }

  init(
    sort: String,
    type: String,
    communityID: Int? = 0,
    personID: Int? = 0,
    instance: String? = nil,
    page: Int,
    filterKey: String
  ) {
    ///    When getting user specific posts, need to use a different endpoint path.
    if personID == nil || personID == 0 {
      endpointPath = "/api/v3/post/list"
    } else {
      endpointPath = "/api/v3/user"
    }

    self.page = page

    if communityID == 99_999_999_999_999 { // TODO: just a placeholder to prevent running when user posts
      self.communityID = 0
    }

    /// Values that can be passed in explicitly. Reverts to default if not passed in.
    self.sort = sort
    self.type = type
    /// Force an instance if it's different to the one you want
    self.instance = instance
    self.communityID = communityID
    self.personID = personID
    self.filterKey = filterKey
  }

  func loadContent(isRefreshing _: Bool = false) {
    guard !isLoading else { return }

    isLoading = true

    let cacher = ResponseCacher(behavior: .cache)

    AF.request(
      EndpointBuilder(parameters: parameters).build(),
      headers: GenerateHeaders().generate()
    )
    .cacheResponse(using: cacher)
    .validate(statusCode: 200 ..< 300)
    .responseDecodable(of: PostModel.self) { response in

      PulseWriter().write(response, self.parameters, .get)

      switch response.result {
      case let .success(result):

        let imageRequestList = result.imageURLs.compactMap {
          ImageRequest(url: URL(string: $0), processors: [.resize(width: 200)])
        }
        self.imagePrefetcher.startPrefetching(with: imageRequestList)

        RealmWriter().writePost(
          posts: result.posts,
          sort: self.sort,
          type: self.type,
          filterKey: self.filterKey
        )

        self.isLoading = false

      case let .failure(error):
        print("PostsFetcher ERROR: \(error): \(error.errorDescription ?? "")")
        self.isLoading = false
      }
    }
  }
}