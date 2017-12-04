//
//  IssuesDetailLoader.swift
//  IssuesApp.rx
//
//  Created by leonard on 2017. 12. 5..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

class IssuesDetailLoader: Loader<Model.Comment> {
    var number: Int
    init(number number_: Int) {
        number  = number_
        super.init()
        api = { () -> (Int) -> Observable<[Model.Comment]> in
            let owner = GlobalState.instance.owner
            let repo = GlobalState.instance.repo
            return App.api.issueComment(owner: owner, repo: repo, number: number)
        }()
    }
}
