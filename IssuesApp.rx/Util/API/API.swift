//
//  API.swift
//  IssuesApp.rx
//
//  Created by Leonard on 2017. 11. 21..
//  Copyright © 2017년 intmain. All rights reserved.
//

import Foundation
import RxSwift

protocol API {
    func getToken() -> Observable<Void>
    func refreshToken() -> Observable<Void>
}
