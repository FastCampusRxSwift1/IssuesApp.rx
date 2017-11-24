//
//  GithubAPI.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 21..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import RxSwift
import OAuthSwift
import Alamofire

struct GitHubAPI: API {
    
    let githubOAuth: OAuth2Swift = OAuth2Swift(
        consumerKey:    "36c48adc3d1433fbd286",
        consumerSecret: "a911bfd178a79f25d14c858a1199cd76d9e92f3b",
        authorizeUrl:   "https://github.com/login/oauth/authorize",
        accessTokenUrl: "https://github.com/login/oauth/access_token",
        responseType:   "code"
    )
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return decoder
    }
    
    func getToken() -> Observable<Void> {
        return  Observable.empty()
    }
    
    func refreshToken() -> Observable<Void> {
        guard let refreshToken = GlobalState.instance.refreshToken else {
            return Observable.empty()
        }
        return  Observable.empty()
    }
    
    func repoIssues(owner: String, repo: String) -> (Int) -> Observable<[Model.Issue]> {
        return { page in
            let parameters: Parameters = ["page": page, "state": "all"]
            return  Observable.empty()
        }
    }
    
}
