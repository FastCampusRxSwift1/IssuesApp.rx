//
//  BitBucketAPI.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 21..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import RxSwift
import OAuthSwift

struct BitbucketAPI: API {
    
    let bitbucketOAuth: OAuth2Swift = OAuth2Swift(
        consumerKey:    "vx2MD5uVaRyLgMxype",
        consumerSecret: "CA9cZxqWEgRDpZCCYy353WG763J8McWH",
        authorizeUrl:   "https://bitbucket.org/site/oauth2/authorize",
        accessTokenUrl: "https://bitbucket.org/site/oauth2/access_token",
        responseType:   "code"
    )
    
    func getToken() -> Observable<Void> {
        return Observable.empty()
    }
    func refreshToken() -> Observable<Void> {
        return Observable.empty()
    }
    
    func repoIssues(owner: String, repo: String) -> (Int) -> Observable<[Model.Issue]> {
        return { page in return Observable.empty() }
    }
}
