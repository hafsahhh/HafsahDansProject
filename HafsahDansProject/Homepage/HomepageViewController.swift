//
//  HomepageViewController.swift
//  HafsahDansProject
//
//  Created by Siti Hafsah on 27/09/25.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RealmSwift

class HomepageViewController: UIViewController, UICollectionViewDelegate {
    
    private let disposeBag = DisposeBag()
    private let viewModel = HomepageViewModel()
    
    private var isAscendingPrice = true // true = low -> high
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Fake Store"
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    private let bookmarkButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "bookmark")
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        button.setTitle(" Wishlist", for: .normal)
        button.semanticContentAttribute = .forceLeftToRight

        return button
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(systemName: "arrow.down")
        button.setImage(image, for: .normal)
        button.tintColor = .systemBlue
        button.setTitle(" Low Price", for: .normal)
        button.semanticContentAttribute = .forceLeftToRight
        
        return button
    }()

    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        let itemWidth = (UIScreen.main.bounds.width - 32) / 2
        layout.itemSize = CGSize(width: itemWidth, height: 290)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.alwaysBounceVertical = true
        return cv
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .red
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        setupBinding()
        viewModel.fetchAllProducts()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(bookmarkButton)
        view.addSubview(filterButton)
        view.addSubview(collectionView)
        view.addSubview(loadingIndicator)
        view.addSubview(errorLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            make.leading.equalToSuperview().offset(16)
        }
        
        bookmarkButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            make.trailing.equalToSuperview().inset(16)
        }
        
        filterButton.snp.makeConstraints { make in
            make.centerY.equalTo(titleLabel)
            make.trailing.equalTo(bookmarkButton.snp.leading).offset(-12)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        errorLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.identifier)
    }
    
    // MARK: - Binding
    private func setupBinding() {
        // Bind products ke collectionView
        viewModel.products
            .bind(to: collectionView.rx.items(cellIdentifier: ProductCell.identifier, cellType: ProductCell.self)) { index, product, cell in
                
                let realm = try! Realm()
                let isBookmarked = realm.object(ofType: FavoriteProduct.self, forPrimaryKey: product.id) != nil
                
                cell.configure(with: product, isBookmarked: isBookmarked)
                
                cell.onBookmarkTapped = {
                    let realm = try! Realm()
                    if let existing = realm.object(ofType: FavoriteProduct.self, forPrimaryKey: product.id) {
                        try! realm.write { realm.delete(existing) }
                    } else {
                        let fav = FavoriteProduct()
                        fav.id = product.id
                        fav.title = product.title
                        fav.price = product.price
                        fav.image = product.image
                        fav.category = product.category
                        try! realm.write { realm.add(fav, update: .modified) }
                    }
                    // update icon
                    let updated = realm.object(ofType: FavoriteProduct.self, forPrimaryKey: product.id) != nil
                    cell.configure(with: product, isBookmarked: updated)
                }
            }
            .disposed(by: disposeBag)
        
        // Set delegate untuk handle didSelectItemAt
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        // Loading indicator
        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .bind { [weak self] loading in
                loading ? self?.loadingIndicator.startAnimating() : self?.loadingIndicator.stopAnimating()
            }
            .disposed(by: disposeBag)
        
        // Error handling
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .bind { [weak self] message in
                self?.errorLabel.text = message
                self?.errorLabel.isHidden = message.isEmpty
            }
            .disposed(by: disposeBag)
        
        // Infinite scroll
        collectionView.rx.didScroll
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                let offsetY = self.collectionView.contentOffset.y
                let contentHeight = self.collectionView.contentSize.height
                let frameHeight = self.collectionView.frame.size.height
                
                if offsetY > contentHeight - frameHeight - 100 {
                    self.viewModel.loadMore()
                }
            })
            .disposed(by: disposeBag)
        
        // Bookmark button
        bookmarkButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                let favVC = FavoriteViewController()
                self.navigationController?.pushViewController(favVC, animated: true)
            }
            .disposed(by: disposeBag)
        
        // Filter button
        filterButton.rx.tap
            .bind { [weak self] in
                guard let self = self else { return }
                self.isAscendingPrice.toggle()
                
                let title = isAscendingPrice ? " Low Price" : " High Price"
                filterButton.setTitle(title, for: .normal)
                
                let iconName = isAscendingPrice ? "arrow.down" : "arrow.up"
                filterButton.setImage(UIImage(systemName: iconName), for: .normal)
                
                // sort products
                let sorted = self.viewModel.products.value.sorted { first, second in
                    self.isAscendingPrice ? first.price < second.price : first.price > second.price
                }
                self.viewModel.products.accept(sorted)
            }
            .disposed(by: disposeBag)
    }
    
    // MARK: - Handle Cell Tap
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedProduct = viewModel.products.value[indexPath.item]
        let detailVC = ProductDetailViewController()
        detailVC.product = selectedProduct
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
