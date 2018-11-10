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
import Kilo

class ViewController: UITableViewController {
    // Row data
    var photos: [Photo]?

    // Image cache
    var thumbnailImages: [Int: UIImage] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Photos"
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
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)

        guard let photo = photos?[indexPath.row] else {
            fatalError()
        }

        cell.textLabel?.text = photo.title

        // Attempt to load image from cache
        cell.imageView?.image = thumbnailImages[photo.id]

        if cell.imageView?.image == nil,
            let url = photo.thumbnailUrl,
            let scheme = url.scheme,
            let host = url.host,
            let serverURL = URL(string: String(format: "%@://%@", scheme, host)) {
            let serviceProxy = WebServiceProxy(session: URLSession.shared, serverURL: serverURL)

            serviceProxy.invoke(.get, path: url.path, responseHandler: { content, contentType in
                return UIImage(data: content)
            }) { (result: UIImage?, error: Error?) in
                // If cell is still visible, update image and reload row
                if error == nil,
                    let cell = tableView.cellForRow(at: indexPath),
                    let thumbnailImage = result {
                    self.thumbnailImages[photo.id] = thumbnailImage

                    cell.imageView?.image = thumbnailImage

                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }

        return cell
    }
}

struct Photo: Decodable {
    let id: Int
    let albumId: Int
    let title: String?
    var url: URL?
    var thumbnailUrl: URL?
}
