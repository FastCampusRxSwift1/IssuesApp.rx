//
//  RepoViewController.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 22..
//  Copyright © 2017년 intmain. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepoViewController: UIViewController {

    @IBOutlet var ownerTextField: UITextField!
    @IBOutlet var repoTextField: UITextField!
    @IBOutlet var enterButton: UIButton!
    @IBOutlet var logoutButton: UIButton!
    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RepoViewController {
    func bind() {
        logoutButton.rx.tap.subscribe(onNext: {
            GlobalState.instance.token = nil
        }).disposed(by: disposeBag)
    }
}
