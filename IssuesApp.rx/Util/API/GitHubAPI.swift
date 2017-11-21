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

struct GitHubAPI: API {
    
    let githubOAuth: OAuth2Swift = OAuth2Swift(
        consumerKey:    "36c48adc3d1433fbd286",
        consumerSecret: "a911bfd178a79f25d14c858a1199cd76d9e92f3b",
        authorizeUrl:   "https://github.com/login/oauth/authorize",
        accessTokenUrl: "https://github.com/login/oauth/access_token",
        responseType:   "code"
    )
    
    
    func getToken() -> Observable<Void> {
        return Observable<Void>.create { (observer) -> Disposable in
            self.githubOAuth.authorize(
                withCallbackURL: URL(string: "ISSAPP://oauth-callback/github")!,
                scope: "user,repo", state:"state",
                success: { credential, _, _ in
                    GlobalState.instance.token = credential.oauthToken
                    GlobalState.instance.refreshToken = credential.oauthRefreshToken
                    App.api = GitHubAPI()
                    observer.onNext(())
                    observer.onCompleted()
            },
                failure: { error in
                    print(error.localizedDescription)
                    observer.onError(error)
            })
            
            return Disposables.create()
        }
    }
    
    func refreshToken() -> Observable<Void> {
        guard let refreshToken = GlobalState.instance.refreshToken else {
            return Observable.empty()
        }
        return Observable<Void>.create { anyObserver -> Disposable in
            self.githubOAuth.renewAccessToken(
                withRefreshToken: refreshToken,
                success: { (credential, _, _) in
                    GlobalState.instance.token = credential.oauthToken
                    GlobalState.instance.refreshToken = credential.oauthRefreshToken
                    anyObserver.onNext(())
                    anyObserver.onCompleted()
            },
                failure: { error in
                    print(error.localizedDescription)
            })
            return Disposables.create()
        }
    }
}
