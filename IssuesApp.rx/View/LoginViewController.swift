//
//  LoginViewController.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 21..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController, ViewControlelrFromStoryBoard {

    @IBOutlet var loginToGitHubButton: UIButton!
    @IBOutlet var loginToBitBucketButton: UIButton!
    var disposeBag: DisposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
    }
}

extension LoginViewController {
    func bind() {


    }
}
