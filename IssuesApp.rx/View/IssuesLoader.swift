//
//  IssuesLoader.swift
//  IssuesApp.rx
//
//  Created by leonard on 2017. 12. 4..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class IssuesLoader {
    fileprivate var nextPageID: Int = 1
    
    fileprivate var canLoadMore: Bool = true
    fileprivate var apiCall: PublishSubject<Int> = PublishSubject()
    fileprivate var disposeBag: DisposeBag = DisposeBag()
    
    fileprivate let datasourceIn: BehaviorSubject<[Model.Issue]> = BehaviorSubject(value: [])
    fileprivate let datasourceOut: BehaviorSubject<[IssuesViewController.IssueSectionModel]> = BehaviorSubject(value: [IssuesViewController.IssueSectionModel(model: 0, items: [])])
    
    fileprivate var isLoading: Bool = false
    fileprivate var refreshControl: UIRefreshControl?
    fileprivate var loadMoreCell: LoadMoreCell?
    
    var datasource: Observable<[IssuesViewController.IssueSectionModel]> {
        get {
            return datasourceOut.asObservable()
        }
    }
    
    private lazy var api: (Int) -> Observable<[Model.Issue]> = { () -> (Int) -> Observable<[Model.Issue]> in
        let owner = GlobalState.instance.owner
        let repo = GlobalState.instance.repo
        return App.api.repoIssues(owner: owner, repo: repo)
    }()
    
    func bind() {
        datasourceIn.asObservable().skip(1)
            .scan([], accumulator: { [weak self] (old: [Model.Issue], new: [Model.Issue]) -> [Model.Issue] in
                if self?.nextPageID == 1 {
                    return new
                }
                return old + new
            }).map { (issues) -> [IssuesViewController.IssueSectionModel] in
                return [IssuesViewController.IssueSectionModel(model: 0, items: issues)]
            }.bind(to: datasourceOut).disposed(by: disposeBag)
        
        datasourceOut.asObservable().skip(1)
            .subscribe(onNext: { [weak self] (issues) in
                guard let `self` = self else { return }
                self.nextPageID += 1
                self.refreshControl?.endRefreshing()
                if issues.isEmpty {
                    self.canLoadMore = false
                    self.loadMoreCell?.loadDone()
                }
            }).disposed(by: disposeBag)
        
        
        apiCall.flatMap {[unowned self ] page -> Observable<[Model.Issue]> in
            return self.api(self.nextPageID)
            }.do(onNext: { [weak self] (_) in
                self?.isLoading = false
                }, onError: { [weak self] _ in
                    self?.isLoading = false
            }).catchError({ (error) -> Observable<[Model.Issue]> in
                return Observable.just([])
            }).bind(to: datasourceIn)
            .disposed(by: disposeBag)
        
        loadData()
        
    }
    
    func loadData() {
        guard isLoading == false else { return }
        isLoading = true
        apiCall.onNext(nextPageID)
    }
    
    func refresh() {
        nextPageID = 1
        canLoadMore = true
        loadMoreCell?.load()
        loadData()
    }
    
    func loadMore(indexPath: IndexPath) {
        guard let value = try? datasourceOut.value() else { return }
        guard  indexPath.item == value[0].items.count - 1 && !isLoading && canLoadMore else { return }
        loadData()
    }
    
    func item(at indexPath: IndexPath) -> Model.Issue? {
        guard let value = try? datasourceOut.value() else { return nil }
        let items: [Model.Issue] = value[0].items
        let data = items[indexPath.item]
        return data
    }
}

extension IssuesLoader {
    func registerLoadMore(collectionView: UICollectionView) {
        collectionView.rx.willDisplayCell.asObservable()
            .subscribe(onNext: { [weak self] (_, indexPath: IndexPath) in
                self?.loadMore(indexPath: indexPath)
            }).disposed(by: disposeBag)
    }
    
    func register(refreshControl: UIRefreshControl) {
        refreshControl.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] () in
                self?.refresh()
            }).disposed(by: disposeBag)
        self.refreshControl = refreshControl
    }
    
    func register(loadMoreCell: LoadMoreCell) {
        self.loadMoreCell = loadMoreCell
    }
}
