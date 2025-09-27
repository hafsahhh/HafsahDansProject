//
//  NetworkManager.swift
//  HafsahDansProject
//
//  Created by Siti Hafsah on 27/09/25.
//

import Foundation
import Alamofire
import RxSwift

class NetworkManager {
    static let shared = NetworkManager()
    private let baseURL = "https://fakestoreapi.com"
    
    private init() {}
    
    func fetchAllProducts() -> Single<[WelcomeElement]> {
        let url = "\(baseURL)/products"
        
        return Single.create { single in
            let request = AF.request(url)
                .validate()
                .responseDecodable(of: [WelcomeElement].self) { response in
                    switch response.result {
                    case .success(let products):
                        single(.success(products))
                    case .failure(let error):
                        single(.failure(error))
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
