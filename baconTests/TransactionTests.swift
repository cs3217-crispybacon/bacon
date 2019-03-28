//
//  TransactionTests.swift
//  baconTests
//
//  Created by Fabian Terh on 19/3/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import XCTest
@testable import bacon

class TransactionTests: XCTestCase {
    let testDate = Date()
    // swiftlint:disable force_try
    let testFrequency = try! TransactionFrequency(nature: .oneTime)

    func test_init_validInput_success() {
        let transaction = try! Transaction(date: testDate,
                                           type: .expenditure,
                                           frequency: testFrequency,
                                           category: .bills,
                                           amount: 1)
        // swiftlint:enable force_try
        XCTAssertEqual(transaction.date, testDate)
        XCTAssertEqual(transaction.type, .expenditure)
        XCTAssertEqual(transaction.frequency, testFrequency)
        XCTAssertEqual(transaction.category, .bills)
        XCTAssertEqual(transaction.amount, 1)
        XCTAssertEqual(transaction.description, "")
    }

    func test_init_invalidNegativeAmount() {
        XCTAssertThrowsError(try Transaction(date: testDate,
                                             type: .expenditure,
                                             frequency: testFrequency,
                                             category: .bills,
                                             amount: -1)) { err in
                                                XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_init_invalidZeroAmount() {
        XCTAssertThrowsError(try Transaction(date: testDate,
                                             type: .expenditure,
                                             frequency: testFrequency,
                                             category: .bills,
                                             amount: 0)) { err in
                                                XCTAssertTrue(type(of: err) == InitializationError.self)
        }
    }

    func test_transaction_equal() {
        // swiftlint:disable force_try
        let transaction = try! Transaction(date: testDate,
                                           type: .expenditure,
                                           frequency: testFrequency,
                                           category: .bills,
                                           amount: 1)
        let transaction2 = try! Transaction(date: testDate,
                                            type: .expenditure,
                                            frequency: testFrequency,
                                            category: .bills,
                                            amount: 1)
        let transaction3 = try! Transaction(date: testDate,
                                            type: .income,
                                            frequency: testFrequency,
                                            category: .food,
                                            amount: 3)
        // swiftlint:enable force_try
        XCTAssertEqual(transaction, transaction2)
        XCTAssertNotEqual(transaction, transaction3)
    }

    func test_transactionObservable() {
        // swiftlint:disable force_try
        let transaction = try! Transaction(date: testDate,
                                           type: .expenditure,
                                           frequency: testFrequency,
                                           category: .bills,
                                           amount: 1)
        // swiftlint:enable force_try

        let observer = DummyObserver()
        transaction.registerObserver(observer)

        XCTAssertEqual(observer.notifiedCount, 0)
        transaction.amount = 2 // Set amount to new value
        XCTAssertEqual(observer.notifiedCount, 1)
        transaction.amount = 2 // Set amount to same value
        XCTAssertEqual(observer.notifiedCount, 2)
    }
}
