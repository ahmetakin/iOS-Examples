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
    var users: [User]?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Response Data Cache"

        tableView.estimatedRowHeight = 2
        tableView.register(UserCell.self, forCellReuseIdentifier: UserCell.description())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Load user data
        if (users == nil) {
            let serviceProxy = WebServiceProxy(session: URLSession.shared, serverURL: URL(string: "https://jsonplaceholder.typicode.com")!)

            serviceProxy.invoke(.get, path: "/users") { (result: [User]?, error: Error?) in
                self.users = result ?? []

                self.tableView.reloadData()
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let userCell = tableView.dequeueReusableCell(withIdentifier: UserCell.description(), for: indexPath) as! UserCell

        userCell.user = users?[indexPath.row]

        return userCell
    }
}

struct User: Codable {
    struct Address: Codable {
        let street: String
        let suite: String
        let city: String
        let zipcode: String

        struct Geo: Codable {
            let lat: String
            let lng: String
        }

        let geo: Geo
    }

    struct Company: Codable {
        let name: String
        let catchPhrase: String
        let bs: String
    }

    let id: Int
    let name: String
    let username: String
    let email: String
    let address: Address
    let phone: String
    let website: String
    let company: Company
}

class UserCell: LMTableViewCell {
    var nameLabel: UILabel!
    var usernameLabel: UILabel!
    var emailLabel: UILabel!
    var streetLabel: UILabel!
    var suiteLabel: UILabel!
    var cityLabel: UILabel!
    var zipcodeLabel: UILabel!
    var geoLabel: UILabel!
    var companyNameLabel: UILabel!
    var companyCatchPhraseLabel: UILabel!
    var companyBSLabel: UILabel!

    var user: User! {
        didSet {
            nameLabel.text = user.name
            usernameLabel.text = "(\(user.username))"
            emailLabel.text = user.email
            streetLabel.text = user.address.street
            suiteLabel.text = user.address.suite
            cityLabel.text = user.address.city
            zipcodeLabel.text = user.address.zipcode
            geoLabel.text = "\(user.address.geo.lat), \(user.address.geo.lng)"
            companyNameLabel.text = user.company.name
            companyCatchPhraseLabel.text = user.company.catchPhrase
            companyBSLabel.text = user.company.bs
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setContent(LMColumnView(spacing: 8,
            LMRowView(
                UILabel(font: UIFont.preferredFont(forTextStyle: .headline)) { self.nameLabel = $0 },
                UILabel() { self.usernameLabel = $0 },
                LMSpacer()
            ),

            UILabel(font: UIFont.preferredFont(forTextStyle: .subheadline), weight: 1) { self.emailLabel = $0 },

            LMSpacer(height: 0.5, backgroundColor: UIColor.lightGray),

            LMRowView(
                LMColumnView(topMargin: 4, bottomMargin: 4, spacing: 2, weight: 1,
                    UILabel() { self.streetLabel = $0 },
                    UILabel() { self.suiteLabel = $0 },
                    UILabel() { self.cityLabel = $0 },
                    UILabel() { self.zipcodeLabel = $0 },
                    LMSpacer(),
                    LMSpacer(height: 8),
                    UILabel(font: UIFont.preferredFont(forTextStyle: .caption1)) { self.geoLabel = $0 }
                ),

                LMColumnView(margin: 4, spacing: 2, weight: 1,
                    UILabel(font: UIFont.preferredFont(forTextStyle: .headline)) { self.companyNameLabel = $0 },
                    UILabel(font: UIFont.preferredFont(forTextStyle: .subheadline), numberOfLines: 0) { self.companyCatchPhraseLabel = $0 },
                    LMSpacer(height: 8),
                    UILabel(numberOfLines: 0) { self.companyBSLabel = $0 },
                    LMSpacer()
                ) {
                    $0.layer.borderWidth = 0.5
                    $0.layer.borderColor = UIColor.lightGray.cgColor
                    $0.layer.cornerRadius = 4
                }
            )
        ), ignoreMargins: false)
    }

    required init?(coder decoder: NSCoder) {
        return nil
    }
}
