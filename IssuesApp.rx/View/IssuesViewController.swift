//
//  IssuesViewController.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 22..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class IssuesViewController: UIViewController, SeguewayConstantable {
    
    enum Constants: String {
        case pushToDetail
        case presentToCreateIssueSegue
    }
    typealias IssueSectionModel = SectionModel<Int, Model.Issue>
    typealias DataSourceType = RxCollectionViewSectionedReloadDataSource<IssueSectionModel>
    
    @IBOutlet var collectionView: UICollectionView!
    
    let estimateCell: IssueCell = IssueCell.cellFromNib
    let datasourceIn: BehaviorSubject<[Model.Issue]> = BehaviorSubject(value: [])
    let datasource: BehaviorSubject<[IssueSectionModel]> = BehaviorSubject(value: [IssueSectionModel(model: 0, items: [])])
    
    var disposeBag: DisposeBag = DisposeBag()
    var isLoading: Bool = false
    var apiCall: PublishSubject<Int> = PublishSubject()
    
    lazy var api: (Int) -> Observable<[Model.Issue]> = { () -> (Int) -> Observable<[Model.Issue]> in
        let owner = GlobalState.instance.owner
        let repo = GlobalState.instance.repo
        return App.api.repoIssues(owner: owner, repo: repo)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
        // Do any additional setup after loading the view.
    }
    
    func setup() {
        collectionView.register(UINib(nibName: "IssueCell", bundle: nil), forCellWithReuseIdentifier: "IssueCell")
        collectionView.alwaysBounceVertical = true
        let owner = GlobalState.instance.owner
        let repo = GlobalState.instance.repo
        self.title = "\(owner)/\(repo)"
    }
    
}

extension IssuesViewController {
    func bind() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        datasource.asObservable()
            .bind(to: collectionView.rx.items(dataSource: createDatasource()))
            .disposed(by: disposeBag)
        
        collectionView.rx.itemSelected.asObservable().subscribe(onNext: { [weak self] indexPath in
            guard let `self` = self else { return }
            guard let issue = try? self.datasource.value().first?.items[indexPath.item] else { return }
            self.performSegue(withIdentifier: Constants.pushToDetail.rawValue, sender: issue)
        }).disposed(by: disposeBag)
        
        apiCall.flatMap {[unowned self ] page -> Observable<[Model.Issue]> in
            return self.api(page)
            }.do(onNext: { [weak self] (_) in
                self?.isLoading = false
                }, onError: { [weak self] _ in
                    self?.isLoading = false
            }).catchError({ (error) -> Observable<[Model.Issue]> in
                return Observable.just([])
            }).map { (issues) -> [IssueSectionModel] in
                return [IssueSectionModel(model: 0, items: issues)]
            }.bind(to: datasource)
            .disposed(by: disposeBag)
        
        loadData()
        
    }
}

extension IssuesViewController {
    
    func loadData() {
        guard isLoading == false else { return }
        isLoading = true
        apiCall.onNext(1)
    }
    
    func createDatasource() -> RxCollectionViewSectionedReloadDataSource<IssueSectionModel> {
        let datasource = RxCollectionViewSectionedReloadDataSource<IssueSectionModel>(configureCell: { (datasource, collectionView, indexPath, item) -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IssueCell", for: indexPath) as? IssueCell else {
                assertionFailure()
                return IssueCell()
            }
            cell.update(data: item)
            return cell
        })
        return datasource
    }
}

extension IssuesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let value = try? datasource.value() else { return CGSize.zero }
        let items: [Model.Issue] = value[0].items
        let data = items[indexPath.item]
        estimateCell.update(data: data)
        let targetSize =  CGSize(width: collectionView.frame.size.width, height: 50)
        let estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        return estimatedSize
    }
}
