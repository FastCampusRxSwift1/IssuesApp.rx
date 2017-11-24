//
//  ReposViewController.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 22..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ReposViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var closeButton: UIBarButtonItem!
    var repoSelectedSubject: PublishSubject<Repo>!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

extension ReposViewController {
    func bind() {

    }
}
