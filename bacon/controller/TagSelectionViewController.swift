//
//  TagSelectionViewController.swift
//  bacon
//
//  Created by Lizhi Zhang on 11/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import UIKit

class TagSelectionViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    var core: CoreLogic?
    var tags = [Tag: [Tag]]()
    var parentTags = [Tag]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Populate tags with the previously stored ones
        tags = core?.getAllTags() ?? [Tag: [Tag]]()
        parentTags = core?.getAllParentTags() ?? [Tag]()
    }

    @IBAction func addParentTagButtonPressed(_ sender: UIButton) {
        guard let core = core else {
            // something
            return
        }
        self.promptUserForInput(title: Constants.tagNameInputTitle,
                                message: Constants.tagNameInputMessage,
                                inputValidator: { userInput in
            return userInput.trimmingCharacters(in: CharacterSet.whitespaces) != ""
        }, successHandler: { userInput in
            do {
                let parentTagAdded = try core.addParentTag(userInput)
                self.parentTags.insert(parentTagAdded, at: 0)
                self.tableView.reloadData()
            } catch {
                self.handleError(error: error, customMessage: Constants.tagAddFailureMessage)
            }
        }, failureHandler: { _ in
            self.alertUser(title: Constants.warningTitle, message: Constants.InvalidTagNameWarning)
        })
    }
}

extension TagSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return parentTags.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rawCell = tableView.dequeueReusableCell(withIdentifier: "ParentTagCell", for: indexPath)
        guard let parentCell = rawCell as? ParentTagCell else {
            return rawCell
        }
        parentCell.parentTagLabel.text = parentTags[indexPath.row].value
        parentCell.childTags = tags[parentTags[indexPath.row]] ?? [Tag]()
        return parentCell
    }

    func  tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150.0
    }
}
