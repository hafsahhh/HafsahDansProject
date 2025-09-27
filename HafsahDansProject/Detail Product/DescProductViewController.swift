//
//  DescProductViewController.swift
//  HafsahDansProject
//
//  Created by Siti Hafsah on 27/09/25.
//

import UIKit
import SnapKit

class ProductDetailViewController: UIViewController {
    
    var product: WelcomeElement?
    
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    
    private let priceLbl: UILabel = {
        let label = UILabel()
        label.text = "Price"
        label.textColor = .blue
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let priceDataLabel = UILabel()
    
    private let categoryLbl: UILabel = {
        let label = UILabel()
        label.text = "Category"
        label.textColor = .blue
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let categoryDataLabel = UILabel()
    
    private let ratingLbl: UILabel = {
        let label = UILabel()
        label.text = "Rating"
        label.textColor = .blue
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let ratingDataLabel = UILabel()
    
    private let descLbl: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = .blue
        label.font = .boldSystemFont(ofSize: 14)
        return label
    }()
    
    private let descriptionLabel = UILabel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        configure()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [titleLabel, imageView, priceLbl, priceDataLabel,
         categoryLbl, categoryDataLabel,
         ratingLbl, ratingDataLabel,
         descLbl, descriptionLabel].forEach { contentView.addSubview($0) }
        
        // ScrollView & ContentView
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        
        imageView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(300)
        }
        imageView.contentMode = .scaleAspectFit

        priceLbl.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        priceDataLabel.snp.makeConstraints { make in
            make.top.equalTo(priceLbl.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        categoryLbl.snp.makeConstraints { make in
            make.top.equalTo(priceDataLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        categoryDataLabel.snp.makeConstraints { make in
            make.top.equalTo(categoryLbl.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }

        ratingLbl.snp.makeConstraints { make in
            make.top.equalTo(categoryDataLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        ratingDataLabel.snp.makeConstraints { make in
            make.top.equalTo(ratingLbl.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        descLbl.snp.makeConstraints { make in
            make.top.equalTo(ratingDataLabel.snp.bottom).offset(16)
            make.leading.trailing.equalToSuperview().inset(16)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(descLbl.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview().inset(16)
            make.bottom.equalTo(contentView.snp.bottom).inset(16)
        }
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .natural
    }
    
    // MARK: - Configure Data
    private func configure() {
        guard let product = product else { return }
        titleLabel.text = product.title
        priceDataLabel.text = "$ \(product.price)"
        categoryDataLabel.text = product.category
        ratingDataLabel.text = String(format: "%.1f", product.rating.rate)
        descriptionLabel.text = product.description
        
        // Load image async
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
}
