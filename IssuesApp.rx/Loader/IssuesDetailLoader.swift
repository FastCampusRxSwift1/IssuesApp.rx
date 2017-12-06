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
    var issue: Model.Issue
    var stateButtonTapSubject: PublishSubject<Observable<()>> = PublishSubject()
    var issueChangedObservable: Observable<Model.Issue>!
    
    init(issue issue_: Model.Issue) {
        self.issue = issue_
    }
    
    override func bind() {
        
        api = { () -> (Int) -> Observable<[Model.Comment]> in
            let owner = GlobalState.instance.owner
            let repo = GlobalState.instance.repo
            return App.api.issueComment(owner: owner, repo: repo, number: issue.number)
        }()
        
        issueChangedObservable = stateButtonTapSubject.switchLatest().flatMap { [weak self] _ -> Observable<Model.Issue> in
            guard let `self` = self else { return Observable.empty() }
            let owner = GlobalState.instance.owner
            let repo = GlobalState.instance.repo
            return App.api.toggleIssueState(owner: owner, repo: repo, number: self.issue.number, issue: self.issue)
        }.share()
        
        issueChangedObservable.subscribe(onNext: { [weak self] issue in
            guard let `self` = self else { return }
            self.issue = issue
        }).disposed(by: disposeBag)
        
        super.bind()
    }
    
}
