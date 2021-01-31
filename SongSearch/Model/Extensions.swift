
import Foundation

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
