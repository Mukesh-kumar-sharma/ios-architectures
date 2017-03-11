//
//  View.swift
//  ios-architectures
//
//  Created by 田中 達也 on 2016/11/30.
//  Copyright © 2016年 tattn. All rights reserved.
//

import UIKit
import Kingfisher

class CatListVC: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let cellWidth = self.view.frame.width / 3
        let layout = CatCollectionViewLayout(itemSize: cellWidth)

        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.register(CatListCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        return collectionView
    }()

    var viewModel: CatViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Cat List"

        setupUI()
        viewModel.bind { [weak self] in
            self?.collectionView.refreshControl?.endRefreshing()
            self?.collectionView.reloadData()
        }
        viewModel.reloadData()
    }

    private func setupUI() {
        view.addSubview(collectionView)
    }

    @objc private func pullToRefresh() {
        viewModel.reloadData()
    }
}

extension CatListVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CatListCell else {
            return UICollectionViewCell()
        }
        
        cell.configure(with: viewModel[indexPath.row])
        
        return cell
    }
}

class CatListCell: UICollectionViewCell {
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView.frame         = bounds
        imageView.contentMode   = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.kf.cancelDownloadTask()
        imageView.image = nil
    }
    
    func configure(with url: URL?) {
        imageView.kf.setImage(with: url)
    }
}
