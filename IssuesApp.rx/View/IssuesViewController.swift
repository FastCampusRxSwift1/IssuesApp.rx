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

    @IBOutlet var collectionView: UICollectionView!
    var disposeBag: DisposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
        // Do any additional setup after loading the view.
    }
    
    func setup() {

        self.title = "\(owner)/\(repo)"
    }
    
}

extension IssuesViewController {
    func bind() {
        
    }
}

extension IssuesViewController {
    
    func loadData() {

    }
    
   
}

