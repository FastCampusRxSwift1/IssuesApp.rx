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

class IssuesViewController: UIViewController {

    typealias IssueSectionModel = SectionModel<Int, Model.Issue>
    typealias DataSourceType = RxCollectionViewSectionedReloadDataSource<IssueSectionModel>
    
    @IBOutlet var collectionView: UICollectionView!
    
    let estimateCell: IssueCell = IssueCell.cellFromNib
    let refreshControl = UIRefreshControl()
    
    var loadMoreCell: LoadMoreCell?
    var disposeBag: DisposeBag = DisposeBag()
    var loader: IssuesLoader = IssuesLoader()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
        // Do any additional setup after loading the view.
    }
    
    func setup() {
        collectionView.register(UINib(nibName: "IssueCell", bundle: nil), forCellWithReuseIdentifier: "IssueCell")
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
        let owner = GlobalState.instance.owner
        let repo = GlobalState.instance.repo
        self.title = "\(owner)/\(repo)"
    }
    
}

extension IssuesViewController {
    func bind() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        loader.bind()
        loader.datasource
            .bind(to: collectionView.rx.items(dataSource: createDatasource()))
            .disposed(by: disposeBag)
        loader.register(refreshControl: refreshControl)
        loader.registerLoadMore(collectionView: collectionView)
    }
}

extension IssuesViewController {
    func createDatasource() -> DataSourceType {
        let datasource = DataSourceType(configureCell: { (datasource, collectionView, indexPath, item) -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "IssueCell", for: indexPath) as? IssueCell else {
                assertionFailure()
                return IssueCell()
            }
            cell.update(data: item)
            return cell
        })
        datasource.configureSupplementaryView = { [weak self] datasource, collectionView, kind, indexPath -> UICollectionReusableView in
            guard let `self` = self else { return UICollectionReusableView() }
            switch kind {
            case UICollectionElementKindSectionHeader:
                assertionFailure()
                return UICollectionReusableView()
            case UICollectionElementKindSectionFooter:
                let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "LoadMoreCell", for: indexPath) as? LoadMoreCell ?? LoadMoreCell()
                self.loader.register(loadMoreCell: footerView)
                return footerView
            default:
                assertionFailure()
                return UICollectionReusableView()
            }
        }
        return datasource
    }
}

extension IssuesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let data = loader.item(at: indexPath) else { return CGSize.zero }
        estimateCell.update(data: data)
        let targetSize =  CGSize(width: collectionView.frame.size.width, height: 50)
        let estimatedSize = estimateCell.contentView.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        return estimatedSize
    }
}


