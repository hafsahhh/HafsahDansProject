//
//  FavoriteViewController.swift
//  HafsahDansProject
//
//  Created by Siti Hafsah on 27/09/25.
//

import UIKit
import SnapKit
import RealmSwift

class FavoriteViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private var favorites: Results<FavoriteProduct>!
    private var notificationToken: NotificationToken?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Wishlist"
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 24)
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let width = (UIScreen.main.bounds.width - 32) / 2
        layout.itemSize = CGSize(width: width, height: 250)
        layout.minimumInteritemSpacing = 8
        layout.minimumLineSpacing = 8
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.identifier)
        collectionView.frame = view.bounds
        
        view.addSubview(collectionView)
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(0)
            make.leading.trailing.equalToSuperview().offset(16)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(10)
            make.bottom.equalToSuperview()
        }
        loadFavorites()
    }
    
    private func loadFavorites() {
        let realm = try! Realm()
        favorites = realm.objects(FavoriteProduct.self)
        
        notificationToken = favorites.observe { [weak self] changes in
            guard let self = self else { return }
            switch changes {
            case .initial:
                self.collectionView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: deletions.map { IndexPath(item: $0, section: 0) })
                    self.collectionView.insertItems(at: insertions.map { IndexPath(item: $0, section: 0) })
                    self.collectionView.reloadItems(at: modifications.map { IndexPath(item: $0, section: 0) })
                })
            case .error(let error):
                print("Realm error: \(error)")
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let fav = favorites[indexPath.item]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCell.identifier, for: indexPath) as! ProductCell
        
        let product = WelcomeElement(
            id: fav.id,
            title: fav.title,
            price: fav.price,
            description: "",
            category: fav.category,
            image: fav.image,
            rating: Rating(rate: 0, count: 0)
        )
        
        cell.configure(with: product, isBookmarked: true)
        
        cell.onBookmarkTapped = {
            let realm = try! Realm()
            if let existing = realm.object(ofType: FavoriteProduct.self, forPrimaryKey: fav.id) {
                try! realm.write { realm.delete(existing) }
            }
        }
        
        return cell
    }
}

