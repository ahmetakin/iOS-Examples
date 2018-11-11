//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import UIKit
import Lima
import Kilo

class ViewController: UITableViewController {
    // Row data
    var photos: [Photo]?

    // Image cache
    var thumbnailImages: [Int: UIImage] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Table View Images"

        tableView.estimatedRowHeight = 2
        tableView.register(PhotoCell.self, forCellReuseIdentifier: PhotoCell.description())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Load photo data
        if (photos == nil) {
            let serviceProxy = WebServiceProxy(session: URLSession.shared, serverURL: URL(string: "https://jsonplaceholder.typicode.com")!)

            serviceProxy.invoke(.get, path: "/photos") { (result: [Photo]?, error: Error?) in
                self.photos = result ?? []

                self.tableView.reloadData()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

        // Clear image cache
        thumbnailImages.removeAll()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoCell = tableView.dequeueReusableCell(withIdentifier: PhotoCell.description(), for: indexPath) as! PhotoCell

        guard let photo = photos?[indexPath.row] else {
            fatalError()
        }

        // Attempt to load image from cache
        photoCell.thumbnailImageView.image = thumbnailImages[photo.id]

        if photoCell.thumbnailImageView.image == nil,
            let url = photo.thumbnailUrl,
            let scheme = url.scheme,
            let host = url.host,
            let serverURL = URL(string: String(format: "%@://%@", scheme, host)) {
            let serviceProxy = WebServiceProxy(session: URLSession.shared, serverURL: serverURL)

            serviceProxy.invoke(.get, path: url.path, responseHandler: { content, contentType in
                return UIImage(data: content)
            }) { (result: UIImage?, error: Error?) in
                // Add image to cache and update cell, if visible
                if let thumbnailImage = result {
                    self.thumbnailImages[photo.id] = thumbnailImage

                    if let cell = tableView.cellForRow(at: indexPath) as? PhotoCell {
                        cell.thumbnailImageView.image = thumbnailImage
                    }
                }
            }
        }

        photoCell.titleLabel.text = photo.title

        return photoCell
    }
}

struct Photo: Decodable {
    let id: Int
    let albumId: Int
    let title: String?
    var url: URL?
    var thumbnailUrl: URL?
}

class PhotoCell: LMTableViewCell {
    var thumbnailImageView: UIImageView!
    var titleLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setContent(LMRowView(
            UIImageView(contentMode: .scaleAspectFit, width: 50, height: 50) { self.thumbnailImageView = $0 },
            LMSpacer(width: 0.5, backgroundColor: UIColor.lightGray),
            LMColumnView(spacing: 0,
                UILabel(font: UIFont.preferredFont(forTextStyle: .body), numberOfLines: 2) { self.titleLabel = $0 },
                LMSpacer()
            )
        ), ignoreMargins: false)
    }

    required init?(coder decoder: NSCoder) {
        return nil
    }
}
