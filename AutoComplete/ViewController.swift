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

class ViewController: UIViewController, UITextFieldDelegate {
    var textField: UITextField!

    let suggestions = [
        "red",
        "orange",
        "yellow",
        "green",
        "blue",
        "purple"
    ]

    override func loadView() {
        view = LMColumnView(margin:16,
            UILabel(text: "What is your favorite color?"),
            UITextField(borderStyle: .roundedRect,
                autocorrectionType: .no,
                autocapitalizationType: .none) { self.textField = $0 },
            LMSpacer()
        )

        textField.delegate = self
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Auto-Complete"

        edgesForExtendedLayout = UIRectEdge()
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return !autoCompleteText(in: textField, using: string, suggestions: suggestions)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        return true
    }

    func autoCompleteText(in textField: UITextField, using string: String, suggestions: [String]) -> Bool {
        if !string.isEmpty,
            let selectedTextRange = textField.selectedTextRange, selectedTextRange.end == textField.endOfDocument,
            let prefixRange = textField.textRange(from: textField.beginningOfDocument, to: selectedTextRange.start),
            let text = textField.text(in: prefixRange) {
            let prefix = text + string
            let matches = suggestions.filter { $0.hasPrefix(prefix) }

            if (matches.count > 0) {
                textField.text = matches[0]

                if let start = textField.position(from: textField.beginningOfDocument, offset: prefix.count) {
                    textField.selectedTextRange = textField.textRange(from: start, to: textField.endOfDocument)

                    return true
                }
            }
        }

        return false
    }
}
