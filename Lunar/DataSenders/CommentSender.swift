//
//  CommentSender.swift
//  Lunar
//
//  Created by Mani on 16/08/2023.
//

import Alamofire
import Foundation
import SwiftUI
import Pulse

class CommentSender: ObservableObject {
  private var content: String
  private var postID: Int
  private var parentID: Int?
  private var jwt: String = ""

  @AppStorage("selectedActorID") var selectedActorID = Settings.selectedActorID
  @AppStorage("appBundleID") var appBundleID = Settings.appBundleID
  @AppStorage("networkInspectorEnabled") var networkInspectorEnabled = Settings.networkInspectorEnabled
  
  let pulse = Pulse.LoggerStore.shared

  init(
    content: String,
    postID: Int,
    parentID: Int?
  ) {
    self.content = content
    self.postID = postID
    self.parentID = parentID
    jwt = getJWTFromKeychain(actorID: selectedActorID) ?? ""
  }

  func fetchCommentResponse(completion: @escaping (String?) -> Void) {
    let parameters =
      [
        "content": content,
        "post_id": postID,
        "parent_id": parentID as Any,
        "auth": jwt,
      ] as [String: Any]
    
    let endpoint = "https://\(URLParser.extractDomain(from: selectedActorID))/api/v3/comment"

    AF.request(
      endpoint,
      method: .post,
      parameters: parameters,
      encoding: JSONEncoding.default
    )
    .validate(statusCode: 200 ..< 300)
    // URLRequest(url: endpoint, method: .post)
    .responseDecodable(of: CommentResponseModel.self) { response in
      
      if self.networkInspectorEnabled {
        self.pulse.storeRequest(
          response.request ?? URLRequest(url: URL(string: endpoint)!),
          response: response.response,
          error: response.error,
          data: response.data
        )
      }
      
      switch response.result {
      case let .success(result):
        print(result.comment.creator.name as Any)
        completion("success")

      case let .failure(error):
        if let data = response.data,
           let fetchError = try? JSONDecoder().decode(ErrorResponseModel.self, from: data)
        {
          print("subscriptionActionSender ERROR: \(fetchError.error)")
          completion(fetchError.error)
        } else {
          let errorDescription = String(describing: error.errorDescription)
          print("subscriptionActionSender JSON DECODE ERROR: \(error): \(errorDescription)")
          completion(error.errorDescription)
        }
      }
    }
  }

  func getJWTFromKeychain(actorID: String) -> String? {
    if let keychainObject = KeychainHelper.standard.read(
      service: appBundleID, account: actorID
    ) {
      let jwt = String(data: keychainObject, encoding: .utf8) ?? ""
      return jwt.replacingOccurrences(of: "\"", with: "")
    } else {
      return nil
    }
  }
}
