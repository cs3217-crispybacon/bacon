//
//  PredictionGenerator.swift
//  bacon
//
//  Provides an abstraction over the underlying prediction generation.
//  Localizes any changes needed when swapping out the underlying prediction generator.
//
//  Created by Lizhi Zhang on 14/4/19.
//  Copyright © 2019 nus.CS3217. All rights reserved.
//

import Foundation

class PredictionGenerator {

    private let concretePredictor: BaconPredictionGenerator

    init() {
        log.info("""
            PredictionGenerator initialized using PredictionGenerator.init()
            """)
        concretePredictor = BaconPredictionGenerator()
    }

    func predict(_ time: Date, _ location: CodableCLLocation, _ transactions: [Transaction]) -> Prediction? {
        return concretePredictor.predict(time, location, transactions)
    }
}
