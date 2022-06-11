//
//  EasySearchViewController.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/04/28.
//

import UIKit
import Alamofire
import AlamofireImage

class EasySearchViewController: UIViewController, UISearchBarDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionTable: UICollectionView!

    var reloading: Bool = true
    var item: Item?
    
    let semaphore = DispatchSemaphore(value: 1)
    
    private let refreshControl = UIRefreshControl()
    
    private var presenter: EasySearchPresenterInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "簡易検索"
        
        self.navigationItem.hidesBackButton = true
        
        setupLayout()
        
        self.presenter = EasySearchPresenter(output: self, model: EasySearchModel())
    }
    
    private func setupLayout() {
        
        searchBar.delegate = self
        collectionTable.delegate = self
        collectionTable.dataSource = self
        collectionTable.refreshControl = refreshControl
        
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: .valueChanged)
    }
    
    @objc func refresh(sender: UIRefreshControl) {
        
        guard let text = searchBar.text else {
            refreshControl.endRefreshing()
            return
        }
        
        if (Double(presenter.numberOfItems).truncatingRemainder(dividingBy: 30.0)) != 0 {
            refreshControl.endRefreshing()
            return
        }
        
        presenter.addPageCount()
        presenter.didGetRakutenData(keyword: text)
        
        self.reloading = true
        
        refreshControl.endRefreshing()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            if self.reloading {
                self.reloading = false
                refresh(sender: self.refreshControl)
            }
        }
    }
    
    @IBAction func goHomeView(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func goBackView(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func openKeyboard(_ sender: Any) {
        
        searchBar.becomeFirstResponder()
    }
    
    @IBAction func textClear(_ sender: Any) {
        
        self.searchBar.text = ""
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.view.endEditing(true)
        
        if let text = searchBar.text {

            self.reloading = true
            
            presenter.initalizePageCount()
            presenter.deleteCollectionItems()
            presenter.didGetRakutenData(keyword: text)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return presenter.numberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell: UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageUrl = presenter.item(index: indexPath.row).largeImageUrl
        if imageUrl != "" {
            let imageView = cell.contentView.viewWithTag(1) as! UIImageView
            presenter.didGetBookImage(imageUrl: imageUrl) { uiImage in
                imageView.image = uiImage
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        self.item = presenter.item(index: indexPath.row)
        performSegue(withIdentifier: "goSelectBook", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goSelectBook" {
            let isbnView = segue.destination as! IsbnViewController
            isbnView.item = self.item
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let horizontalSpace: CGFloat = 5
        let cellSize: CGFloat = self.view.bounds.width/3 - horizontalSpace * 2
        let heightSize = cellSize * 4 / 3
        
        return CGSize(width: cellSize, height: heightSize)
    }
}

extension EasySearchViewController: EasySearchPresenterOutput {
    
    func updateTable() {
        DispatchQueue.main.async {
            self.collectionTable.reloadData()
        }
    }
}
