//
//  IssueDetailViewController.swift
//  IssuesApp.rx
//
//  Created by leonard on 2017. 12. 4..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class IssueDetailViewController: UIViewController {
    
    typealias CommentSectionModel = SectionModel<Int, Model.Comment>
    typealias DataSourceType = RxCollectionViewSectionedReloadDataSource<CommentSectionModel>
    
    @IBOutlet var collectionView: UICollectionView!
    
    let estimateCell: CommentCell = CommentCell.cellFromNib
    let refreshControl = UIRefreshControl()
    var issue: Model.Issue!
    var loadMoreCell: LoadMoreCell?
    var disposeBag: DisposeBag = DisposeBag()
    var header: IssueDetailHeaderCell?
    var headerSize: CGSize = CGSize.zero
    lazy var loader: IssuesDetailLoader =  { [unowned self] in
        return IssuesDetailLoader(number: self.issue.number)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }

    func setup() {
        collectionView.register(UINib(nibName: "CommentCell", bundle: nil), forCellWithReuseIdentifier: "CommentCell")
        collectionView.refreshControl = refreshControl
        collectionView.alwaysBounceVertical = true
        let owner = GlobalState.instance.owner
        let repo = GlobalState.instance.repo
        self.title = "\(owner)/\(repo)"
    }
}

extension IssueDetailViewController {
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

extension IssueDetailViewController {
    func createDatasource() -> DataSourceType {
        let datasource = DataSourceType(configureCell: { (datasource, collectionView, indexPath, item) -> UICollectionViewCell in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommentCell", for: indexPath) as? CommentCell else {
                assertionFailure()
                return CommentCell()
            }
            cell.update(data: item)
            return cell
        })
        datasource.configureSupplementaryView = { [weak self] datasource, collectionView, kind, indexPath -> UICollectionReusableView in
            guard let `self` = self else { return UICollectionReusableView() }
            switch kind {
            case UICollectionElementKindSectionHeader:
                guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "IssueDetailHeaderCell", for: indexPath) as? IssueDetailHeaderCell else {
                    assertionFailure()
                    return UICollectionViewCell()
                }
                header.update(data: self.issue)
                self.header = header
                return header
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

extension IssueDetailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let data = loader.item(at: indexPath) else { return CGSize.zero }
        estimateCell.update(data: data)
        let estimatedSize = CommentCell.cellSize(collectionView: collectionView, item: data, indexPath: indexPath)
        return estimatedSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if headerSize == CGSize.zero {
            headerSize = IssueDetailHeaderCell.headerSize(issue: issue, width: collectionView.frame.width)    
        }
        return headerSize
    }
}
