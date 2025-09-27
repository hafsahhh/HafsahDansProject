//
//  HomepageViewModell.swift
//  HafsahDansProject
//
//  Created by Siti Hafsah on 27/09/25.
//

import Foundation
import RxSwift
import RxCocoa

class HomepageViewModel {
    private let disposeBag = DisposeBag()
    
    let products = BehaviorRelay<[WelcomeElement]>(value: [])
    let isLoading = BehaviorRelay<Bool>(value: false)
    let errorMessage = PublishRelay<String>()
    
    var allProducts: [WelcomeElement] = []
    private var currentIndex = 0
    private let pageSize = 6
    
    // MARK: - Fetch all products
    func fetchAllProducts() {
        guard !isLoading.value else { return }
        isLoading.accept(true)
        
        NetworkManager.shared.fetchAllProducts()
            .subscribe { [weak self] event in
                guard let self = self else { return }
                self.isLoading.accept(false)
                
                switch event {
                case .success(let products):
                    self.allProducts = products
                    self.currentIndex = 0
                    self.products.accept([])
                    self.loadMore()
                    
                case .failure(let error):
                    self.errorMessage.accept(error.localizedDescription)
                }
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Load more products (pagination)
    func loadMore() {
        guard currentIndex < allProducts.count else { return }
        
        let nextIndex = min(currentIndex + pageSize, allProducts.count)
        let newProducts = Array(allProducts[currentIndex..<nextIndex])
        
        // Append new products to current list
        products.accept(products.value + newProducts)
        currentIndex = nextIndex
    }
    
    // MARK: - Sort products by price
    func sortByPrice(ascending: Bool) {
        let sorted = allProducts.sorted { ascending ? $0.price < $1.price : $0.price > $1.price }
     
        currentIndex = min(pageSize, sorted.count)
        products.accept(Array(sorted[0..<currentIndex]))
        allProducts = sorted
    }
}
