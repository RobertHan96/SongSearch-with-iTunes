import UIKit
import Kingfisher

class SearchResultCell: UICollectionViewCell {
    @IBOutlet weak var albumImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(track: Track, dataSourceSize: Int) {
        if dataSourceSize != 0 {
            titleLabel.text = track.title
            artistLabel.text = track.artistName
            let url = URL(string: track.thumbnail)
            albumImageView.kf.setImage(with: url)
        } else {
            titleLabel.text = "검색 결과가 없습니다."
            artistLabel.text = ""
            albumImageView.image = UIImage()
        }
    }
}
