//
//  URLBuilder.swift
//  Lunar
//
//  Created by Mani on 23/07/2023.
//

import Foundation
import SwiftUI

/// **Base URL**
/// https://lemmy.world/api/v3/
/// **Communities List**
/// community/list?type_=Local&sort=Active&page=1&limit=10
/// **Community Specific Posts**
/// post/list?type_=Local&sort=Active&page=1&limit=10&community_id=145566
/// **Non Specific Posts**
/// post/list?type_=Local&sort=Active&page=1&limit=10
/// **Comments List**
/// comment/list?type_=Local&sort=Top&max_depth=2&page=1&limit=10&post_id=2021423

class APIEndpointBuilder {
    @AppStorage("instanceHostURL") var instanceHostURL = Settings.instanceHostURL
    @AppStorage("appBundleID") var appBundleID = Settings.appBundleID

    private let endpointPath: String
    private var queryParams: [String: String] = [:]

    init(
        endpointPath: String,
        queryParams: [String: String] = [:]
    ) {
        self.endpointPath = endpointPath
        self.queryParams = queryParams
    }

    func buildURL() -> URLComponents {
        var endpoint = URLComponents()

        if let authTokenUser = queryParams["authTokenUser"] {
            let keychainObject = KeychainHelper.standard.read(service: appBundleID, account: authTokenUser)
            let accessToken = String(data: keychainObject ?? Data(), encoding: .utf8)!
            queryParams["auth"] = accessToken
        }

        endpoint.scheme = "https"
        endpoint.host = instanceHostURL
        endpoint.path = endpointPath
        endpoint.setQueryItems(with: queryParams)

        return endpoint
    }
}

class URLBuilder {
    @AppStorage("instanceHostURL") var instanceHostURL = Settings.instanceHostURL
    @AppStorage("appBundleID") var appBundleID = Settings.appBundleID

    private let endpointPath: String
    private let sortParameter: String?
    private let typeParameter: String?
    private let currentPage: Int?
    private let limitParameter: Int?
    private let communityID: Int?
    private let postID: Int?
    private let maxDepth: Int?
    private let jwt: String?

    init(
        endpointPath: String,
        sortParameter: String? = "",
        typeParameter: String? = "",
        currentPage: Int? = 1,
        limitParameter: Int? = nil,
        communityID: Int? = nil,
        postID: Int? = nil,
        maxDepth: Int? = nil,
        jwt: String? = nil
    ) {
        self.endpointPath = endpointPath
        self.sortParameter = sortParameter
        self.typeParameter = typeParameter
        self.currentPage = currentPage
        self.limitParameter = limitParameter
        self.communityID = communityID
        self.postID = postID
        self.maxDepth = maxDepth
        self.jwt = jwt
    }

    func buildURL() -> URLComponents {
        var endpoint = URLComponents()
        var queryParams: [String: String?] = [:]

        if let sortParameter { queryParams["sort"] = String(sortParameter) }
        if let typeParameter { queryParams["type_"] = String(typeParameter) }
        if let currentPage { queryParams["page"] = String(currentPage) }
        if let limitParameter { queryParams["limit"] = String(limitParameter) }
        if let communityID { queryParams["community_id"] = String(communityID) }
        if let postID { queryParams["post_id"] = String(postID) }
        if let maxDepth { queryParams["max_depth"] = String(maxDepth) }
        if let jwt { queryParams["auth"] = String(jwt) }

        endpoint.scheme = "https"
        endpoint.host = instanceHostURL
        endpoint.path = endpointPath
        endpoint.setQueryItems(with: queryParams)

        return endpoint
    }
}