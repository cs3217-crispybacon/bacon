//
//  TagManagerTests.swift
//  baconTests
//
//  Created by Fabian Terh on 11/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

// swiftlint:disable force_try

import XCTest
@testable import bacon

class TagManagerTests: XCTestCase {

    var tagManager = TagManager.create(testMode: true)

    let parent1 = "parent1"
    let parent2 = "parent2"
    let child1 = "child1"
    let child2 = "child2"

    override func setUp() {
        tagManager.clearTags()
    }

    func test_persistent_singleton() {
        let tagManager1 = TagManager.create(testMode: true)
        let tagManager2 = TagManager.create(testMode: true)
        XCTAssertTrue(tagManager1 === tagManager2)
    }

    func test_addChildTag_parentTagExists() {
        try! _ = tagManager.addParentTag(parent1)
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent1))

        try! _ = tagManager.addChildTag(child1, to: parent1)
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent1))
    }

    func test_addChildTag_parentTagDoesNotExist() {
        XCTAssertFalse(tagManager.isParentTag(parent1))
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent1))

        XCTAssertThrowsError(try tagManager.addChildTag(child1, to: parent1)) { err in
            XCTAssertTrue(err is InvalidTagError)
        }
    }

    func test_addChildTag_duplicateTags() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addChildTag(child1, to: parent1)
        XCTAssertThrowsError(try _ = tagManager.addChildTag(child1, to: parent1)) { err in
            XCTAssertTrue(err is DuplicateTagError)
        }
    }

    func test_addChildTag_multipleParents() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addParentTag(parent2)
        XCTAssertEqual(try! tagManager.getChildrenTags(of: parent1).count, 0)
        XCTAssertEqual(try! tagManager.getChildrenTags(of: parent2).count, 0)

        try! _ = tagManager.addChildTag(child1, to: parent1)
        XCTAssertEqual(try! tagManager.getChildrenTags(of: parent1).count, 1)
        XCTAssertEqual(try! tagManager.getChildrenTags(of: parent2).count, 0)

        try! _ = tagManager.addChildTag(child2, to: parent1)
        XCTAssertEqual(try! tagManager.getChildrenTags(of: parent1).count, 2)
        XCTAssertEqual(try! tagManager.getChildrenTags(of: parent2).count, 0)

        try! _ = tagManager.addChildTag(child1, to: parent2)
        XCTAssertEqual(try! tagManager.getChildrenTags(of: parent1).count, 2)
        XCTAssertEqual(try! tagManager.getChildrenTags(of: parent2).count, 1)

        try! _ = tagManager.addChildTag(child2, to: parent2)
        XCTAssertEqual(try! tagManager.getChildrenTags(of: parent1).count, 2)
        XCTAssertEqual(try! tagManager.getChildrenTags(of: parent2).count, 2)
    }

    func test_addParentTag_noDuplicateTags() {
        XCTAssertFalse(tagManager.isParentTag(parent1))
        try! _ = tagManager.addParentTag(parent1)
        XCTAssertTrue(tagManager.isParentTag(parent1))
    }

    func test_addParentTag_duplicateTags() {
        try! _ = tagManager.addParentTag(parent1)
        XCTAssertThrowsError(try _ = tagManager.addParentTag(parent1)) { err in
            XCTAssertTrue(err is DuplicateTagError)
        }
    }

    func test_addParentTag_multipleTags() {
        XCTAssertFalse(tagManager.isParentTag(parent1))
        XCTAssertFalse(tagManager.isParentTag(parent2))
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addParentTag(parent2)
        XCTAssertTrue(tagManager.isParentTag(parent1))
        XCTAssertTrue(tagManager.isParentTag(parent2))
    }

    func test_removeChildTag_parentTagExists() {
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent1))
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addChildTag(child1, to: parent1)
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent1))

        try! tagManager.removeChildTag(child1, from: parent1)
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent1))
    }

    func test_removeChildTag_parentTagDoesNotExist() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addParentTag(parent2)
        try! _ = tagManager.addChildTag(child1, to: parent1)
        XCTAssertThrowsError(try tagManager.removeChildTag(child1, from: parent2)) { err in
            XCTAssertTrue(err is InvalidTagError)
        }
    }

    func test_removeChildTag_childTagDoesNotExist() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addChildTag(child1, to: parent1)
        XCTAssertThrowsError(try tagManager.removeChildTag(child2, from: parent1)) { err in
            XCTAssertTrue(err is InvalidTagError)
        }
    }

    func test_removeChildTag_multipleParentTags() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addParentTag(parent2)
        try! _ = tagManager.addChildTag(child1, to: parent1)
        try! _ = tagManager.addChildTag(child1, to: parent2)
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent1))
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent2))

        try! tagManager.removeChildTag(child1, from: parent1)
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent1))
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent2))
    }

    func test_removeParentTag_exists() {
        try! _ = tagManager.addParentTag(parent1)
        XCTAssertTrue(tagManager.isParentTag(parent1))
        try! tagManager.removeParentTag(parent1)
        XCTAssertFalse(tagManager.isParentTag(parent1))
    }
    func test_removeParentTag_doesNotExist() {
        try! _ = tagManager.addParentTag(parent1)
        XCTAssertThrowsError(try tagManager.removeParentTag(parent2)) { err in
            XCTAssertTrue(err is InvalidTagError)
        }
    }

    func test_removeParentTag_hasChildrenTags() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addChildTag(child1, to: parent1)
        try! _ = tagManager.addChildTag(child2, to: parent1)
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent1))
        XCTAssertTrue(tagManager.isChildTag(child2, of: parent1))

        try! tagManager.removeParentTag(parent1)
        XCTAssertFalse(tagManager.isParentTag(parent1))
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent1))
        XCTAssertFalse(tagManager.isChildTag(child2, of: parent1))
    }

    func test_removeParentTag_multipleParentTags() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addParentTag(parent2)
        XCTAssertTrue(tagManager.isParentTag(parent1))
        XCTAssertTrue(tagManager.isParentTag(parent2))

        try! tagManager.removeParentTag(parent1)
        XCTAssertFalse(tagManager.isParentTag(parent1))
        XCTAssertTrue(tagManager.isParentTag(parent2))
    }

    func test_getChildrenTagsOf_noChildrenTags() {
        try! _ = tagManager.addParentTag(parent1)
        XCTAssertEqual(try! tagManager.getChildrenTags(of: parent1), [])
    }

    func test_getChildrenTagsOf_multipleChildrenTags() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addChildTag(child2, to: parent1)
        try! _ = tagManager.addChildTag(child1, to: parent1)
        let childrenTags = try! tagManager.getChildrenTags(of: parent1)

        XCTAssertEqual(childrenTags.count, 2)
        XCTAssertEqual(childrenTags[0].value, child1)
        XCTAssertEqual(childrenTags[0].parentValue, parent1)
        XCTAssertEqual(childrenTags[1].value, child2)
        XCTAssertEqual(childrenTags[1].parentValue, parent1)
    }

    func test_getChildrenTagsOf_parentTagDoesNotExist() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addChildTag(child1, to: parent1)
        try! _ = tagManager.addChildTag(child2, to: parent1)
        XCTAssertThrowsError(try tagManager.getChildrenTags(of: parent2)) { err in
            XCTAssertTrue(err is InvalidTagError)
        }
    }

    func test_parentTags_noParentTags() {
        XCTAssertEqual(tagManager.parentTags, [])
    }

    func test_parentTags_oneParentTags() {
        try! _ = tagManager.addParentTag(parent1)
        XCTAssertEqual(tagManager.parentTags.count, 1)
        XCTAssertEqual(tagManager.parentTags[0].value, parent1)
    }
    func test_parentTags_twoParentTags() {
        try! _ = tagManager.addParentTag(parent2)
        try! _ = tagManager.addParentTag(parent1)
        XCTAssertEqual(tagManager.parentTags.count, 2)
        XCTAssertEqual(tagManager.parentTags[0].value, parent1)
        XCTAssertEqual(tagManager.parentTags[1].value, parent2)
    }

    func test_isChildTag_parentTagExists() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addChildTag(child1, to: parent1)
        XCTAssertTrue(tagManager.isChildTag(child1, of: parent1))
    }
    func test_isChildTag_parentTagDoesNotExist() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addChildTag(child1, to: parent1)
        XCTAssertFalse(tagManager.isChildTag(child1, of: parent2))
    }

    func test_isParentTag_parentTagExists() {
        try! _ = tagManager.addParentTag(parent1)
        XCTAssertTrue(tagManager.isParentTag(parent1))
    }
    func test_isParentTag_parentTagDoesNotExist() {
        try! _ = tagManager.addParentTag(parent1)
        XCTAssertFalse(tagManager.isParentTag(parent2))
    }

    func test_tagDisplayValue_parentTags() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addParentTag(parent2)

        let parentTags = tagManager.parentTags
        XCTAssertEqual(parentTags.count, 2)
        XCTAssertEqual(parentTags[0].value, parent1)
        XCTAssertEqual(parentTags[1].value, parent2)
    }

    func test_tagDisplayValue_childrenTags() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addParentTag(parent2)
        try! _ = tagManager.addChildTag(child1, to: parent1)
        try! _ = tagManager.addChildTag(child2, to: parent1)
        try! _ = tagManager.addChildTag(child1, to: parent2)
        try! _ = tagManager.addChildTag(child2, to: parent2)

        let childrenTags1 = try! tagManager.getChildrenTags(of: parent1)
        XCTAssertEqual(childrenTags1.count, 2)
        XCTAssertEqual(childrenTags1[0].value, child1)
        XCTAssertEqual(childrenTags1[1].value, child2)

        let childrenTags2 = try! tagManager.getChildrenTags(of: parent2)
        XCTAssertEqual(childrenTags2.count, 2)
        XCTAssertEqual(childrenTags2[0].value, child1)
        XCTAssertEqual(childrenTags2[1].value, child2)
    }

    func test_tagParentDisplayValue_parentTags() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addParentTag(parent2)

        let parentTags = tagManager.parentTags
        XCTAssertEqual(parentTags.count, 2)
        XCTAssertEqual(parentTags[0].parentValue, nil)
        XCTAssertEqual(parentTags[1].parentValue, nil)
    }

    func test_tagParentDisplayValue_childrenTags() {
        try! _ = tagManager.addParentTag(parent1)
        try! _ = tagManager.addParentTag(parent2)
        try! _ = tagManager.addChildTag(child1, to: parent1)
        try! _ = tagManager.addChildTag(child2, to: parent1)
        try! _ = tagManager.addChildTag(child1, to: parent2)
        try! _ = tagManager.addChildTag(child2, to: parent2)

        let childrenTags1 = try! tagManager.getChildrenTags(of: parent1)
        XCTAssertEqual(childrenTags1.count, 2)
        XCTAssertEqual(childrenTags1[0].parentValue, parent1)
        XCTAssertEqual(childrenTags1[1].parentValue, parent1)

        let childrenTags2 = try! tagManager.getChildrenTags(of: parent2)
        XCTAssertEqual(childrenTags2.count, 2)
        XCTAssertEqual(childrenTags2[0].parentValue, parent2)
        XCTAssertEqual(childrenTags2[1].parentValue, parent2)
    }

}

// swiftlint:enbable force_try
