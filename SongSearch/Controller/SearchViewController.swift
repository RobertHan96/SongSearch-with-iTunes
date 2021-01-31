import UIKit
import AVKit

class SearchViewController: UIViewController {
    let maxHeight: CGFloat = 70.0
    let minHeight: CGFloat = 0.0
    let titleLabel = UILabel()
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerViewHeight: NSLayoutConstraint! {
        didSet {
            headerViewHeight.constant = maxHeight
        }
    }
    @IBOutlet weak var searchCollectionView: UICollectionView! {
        didSet {
            searchCollectionView.contentInset = UIEdgeInsets(top: maxHeight, left: 0, bottom: 0, right: 0)
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    var tracks: [Track] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        setupSearchBar()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func dismissKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    private func setupSearchBar() {
        searchBar.searchBarStyle = .prominent
        searchBar.placeholder = "검색"
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.clipsToBounds = true
    }
    
    private func setupCollectionView() {
        self.searchCollectionView.delegate = self
        self.searchCollectionView.dataSource = self
        searchCollectionView.register(UINib(nibName: "SearchResultCell", bundle: nil),
            forCellWithReuseIdentifier: "SearchResultCell")
        searchCollectionView.register(UINib(nibName: "EmptyResultCell", bundle: nil),
            forCellWithReuseIdentifier: "EmptyResultCell")
        setupFlowLayout()
    }
    
    private func setupFlowLayout() {
      let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = UIEdgeInsets.zero
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.minimumLineSpacing = 10
        let height = self.searchCollectionView.layer.bounds.height / 5
        let width = self.searchCollectionView.layer.bounds.width
        flowLayout.itemSize = CGSize(width: width , height: 70)
      self.searchCollectionView.collectionViewLayout = flowLayout
    }
    
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = searchCollectionView.dequeueReusableCell(withReuseIdentifier: "SearchResultCell", for: indexPath) as? SearchResultCell else {
            return UICollectionViewCell()
        }
        cell.configure(track: tracks[indexPath.row], dataSourceSize: tracks.count)
        return cell
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismissKeyboard()
        guard let previewUrl = URL(string: tracks[indexPath.row].previewUrl) else { return }
        let playerViewController = AVPlayerViewController()
        present(playerViewController, animated: true, completion: nil)
        let player = AVPlayer(url: previewUrl)
        playerViewController.player = player
        player.play()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            print("LLOG", scrollView.contentOffset.y)
            headerViewHeight.constant = max(abs(scrollView.contentOffset.y), minHeight)
        } else {
            headerViewHeight.constant = minHeight
        }
    }

}


extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        print("LOG - 검색 시작...")
        // TODO: Search Code
        guard let searchText = searchBar.text, searchText.isEmpty == false else { return }
        
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search?media=music&entity=musicVideo")!
        let queryItem = URLQueryItem(name: "term", value: searchText)
        urlComponents.queryItems?.append(queryItem)
        
        
        guard let requestURL = urlComponents.url else { return }
        URLSession.shared.dataTask(with: requestURL) { [weak self] (data, response, error) in
            guard let strongSelf = self else { return }
            print(requestURL)
            
            // Client-side Error
            guard error == nil else { return }
            
            // Server-side Error
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else { return }
            let successRange = 200..<300
            
            guard successRange.contains(statusCode) else {
                // serverside error handle
                return
            }
            
            guard let resultData = data else { return }
            strongSelf.tracks = strongSelf.parse(data: resultData) ?? []
            DispatchQueue.main.async {
                strongSelf.searchCollectionView.reloadData()
                strongSelf.searchCollectionView.setContentOffset(CGPoint.zero, animated: false)
            }
        }.resume()
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController {
    func parse(data: Data) -> [Track]? {
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode(Response.self, from: data)
            let trackList = response.results
            return trackList
        } catch let error {
            print("---> error:\(error.localizedDescription)")
            return nil
        }
    }
}


