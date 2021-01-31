
import Foundation
import UIKit

extension String{
    func getDataFromStringUrl(urlString :String) -> Data {
        let url = URL(string: urlString )
        var albumart = Data()
        do {
            albumart = try Data(contentsOf: url!)
            } catch {
                print("Log - 앨범아트 이미지 로딩 실패")
            }
        return albumart
    }
}

extension UICollectionView {

    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()

        self.backgroundView = messageLabel;
    }

    func restore() {
        self.backgroundView = nil
    }
}
