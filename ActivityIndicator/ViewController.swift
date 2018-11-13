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

class ViewController: UITableViewController {
    var activityIndicatorView: UIActivityIndicatorView!

    var rows: [String]?

    let dispatchQueue = DispatchQueue(label: "Example Queue")

    override func loadView() {
        super.loadView()

        activityIndicatorView = UIActivityIndicatorView(style: .gray)

        tableView.backgroundView = activityIndicatorView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Activity Indicator"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (rows == nil) {
            activityIndicatorView.startAnimating()

            tableView.separatorStyle = .none

            dispatchQueue.async {
                Thread.sleep(forTimeInterval: 3)

                OperationQueue.main.addOperation() {
                    self.rows = ["One", "Two", "Three", "Four", "Five"]

                    self.activityIndicatorView.stopAnimating()

                    self.tableView.separatorStyle = .singleLine
                    self.tableView.reloadData()
                }
            }
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (rows == nil) ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) ?? UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)

        cell.textLabel?.text = rows?[indexPath.row]

        return cell
    }
}

