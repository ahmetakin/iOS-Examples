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
import WebKit

class ViewController: UIViewController {
    var webView: WKWebView!

    override func loadView() {
        webView = WKWebView()

        view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Client-Side CSS"

        if let url = Bundle.main.url(forResource: "example", withExtension: "html"),
            let data = try? Data(contentsOf: url),
            let resourceURL = Bundle.main.resourceURL {
            webView.load(data, mimeType: "text/html", characterEncodingName: "UTF-8", baseURL: resourceURL)
        }
    }
}
