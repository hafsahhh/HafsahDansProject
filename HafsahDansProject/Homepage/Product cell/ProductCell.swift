//
//  ProductCell.swift
//  HafsahDansProject
//
//  Created by Siti Hafsah on 27/09/25.
//

import UIKit
import SnapKit

class ProductCell: UICollectionViewCell {
    static let identifier = "ProductCell"
    
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    let bookmarkButton = UIButton(type: .system)
    
    var onBookmarkTapped: (() -> Void)?
    private var currentProduct: WelcomeElement?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // MARK: - ContentView
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.clipsToBounds = true

        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true

        titleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        titleLabel.numberOfLines = 0

        priceLabel.font = .boldSystemFont(ofSize: 14)
        priceLabel.textColor = .systemGreen

        bookmarkButton.tintColor = .systemBlue
        bookmarkButton.addTarget(self, action: #selector(didTapBookmark), for: .touchUpInside)

        // MARK: - Nested Stack for Title & Price
        let titlePriceStack = UIStackView(arrangedSubviews: [titleLabel, priceLabel])
        titlePriceStack.axis = .vertical
        titlePriceStack.spacing = 2
        titlePriceStack.alignment = .center

        // MARK: - Main Vertical Stack
        let vStack = UIStackView(arrangedSubviews: [imageView, titlePriceStack])
        vStack.axis = .vertical
        vStack.spacing = 8                 
        vStack.alignment = .fill

        contentView.addSubview(vStack)
        contentView.addSubview(bookmarkButton)

        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(8)
        }

        imageView.snp.makeConstraints { make in
            make.height.equalTo(imageView.snp.width)
        }

        bookmarkButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.trailing.equalToSuperview().inset(8)
            make.width.height.equalTo(24)
        }
    }

    
    func configure(with product: WelcomeElement, isBookmarked: Bool = false) {
        self.currentProduct = product
        titleLabel.text = product.title
        priceLabel.text = "$ \(product.price)"
        
        let iconName = isBookmarked ? "bookmark.fill" : "bookmark"
        bookmarkButton.setImage(UIImage(systemName: iconName), for: .normal)
        
        imageView.image = nil
        if let url = URL(string: product.image) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url),
                   let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.imageView.image = img
                    }
                }
            }
        }
    }
    
    @objc private func didTapBookmark() {
        onBookmarkTapped?()
    }
    
}
