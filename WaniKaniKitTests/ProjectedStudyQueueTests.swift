//
//  ProjectedStudyQueueTests.swift
//  WaniKaniKit
//
//  Copyright © 2015 Chris Laverty. All rights reserved.
//

import XCTest
import OHHTTPStubs
import OperationKit
@testable import WaniKaniKit

#if HAS_DOWNLOADED_DATA
class ProjectedStudyQueueTests: DatabaseTestCase, ResourceHTTPStubs {
    
    override func setUp() {
        super.setUp()
        
        let radicalsExpectation = expectationWithDescription("radicals")
        let kanjiExpectation = expectationWithDescription("kanji")
        let vocabularyExpectation = expectationWithDescription("vocabulary")
        let operationQueue = OperationQueue()
        
        self.databaseQueue.inDatabase { database in
            let studyQueue = StudyQueue(lessonsAvailable: 38, reviewsAvailable: 0, nextReviewDate: Date(timeIntervalSince1970: 1443198600), reviewsAvailableNextHour: 19, reviewsAvailableNextDay: 42, lastUpdateTimestamp: Date(timeIntervalSince1970: 1443198500))
            try! StudyQueue.coder.save(studyQueue, toDatabase: database)
        }
        
        stubForResource(Resource.Radicals, file: "SQPTRadicals")
        stubForResource(Resource.Kanji, file: "SQPTKanji")
        stubForResource(Resource.Vocabulary, file: "SQPTVocab")
        defer { OHHTTPStubs.removeAllStubs() }
        
        let radicalsOperation = GetRadicalsOperation(resolver: self.resourceResolver, databaseQueue: self.databaseQueue, downloadStrategy: self.stubDownloadStrategy)
        let kanjiOperation = GetKanjiOperation(resolver: self.resourceResolver, databaseQueue: self.databaseQueue, downloadStrategy: self.stubDownloadStrategy)
        let vocabularyOperation = GetVocabularyOperation(resolver: self.resourceResolver, databaseQueue: self.databaseQueue, downloadStrategy: self.stubDownloadStrategy)
        
        radicalsOperation.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors, but received: \(errors)")
            radicalsExpectation.fulfill()
            })
        kanjiOperation.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors, but received: \(errors)")
            kanjiExpectation.fulfill()
            })
        vocabularyOperation.addObserver(BlockObserver { _, errors in
            XCTAssertTrue(errors.isEmpty, "Expected no errors, but received: \(errors)")
            vocabularyExpectation.fulfill()
            })
        
        print("Loading test data...")
        // We have to set waitUntilFinished = false here since the requisite method in Operation throws a fatalError
        operationQueue.addOperations([radicalsOperation, kanjiOperation, vocabularyOperation], waitUntilFinished: false)
        waitForExpectationsWithTimeout(60.0, handler: nil)
    }
    
    func testUnprojected() {
        let referenceDate = Date(timeIntervalSince1970: 1443198500)
        let expected = StudyQueue(lessonsAvailable: 38, reviewsAvailable: 0, nextReviewDate: Date(timeIntervalSince1970: 1443198600), reviewsAvailableNextHour: 19, reviewsAvailableNextDay: 42)
        
        self.measureBlock() {
            self.databaseQueue.inDatabase { database in
                let projectedStudyQueue = try! SRSDataItemCoder.projectedStudyQueue(database, referenceDate: referenceDate)
                XCTAssertEqual(projectedStudyQueue, expected)
            }
        }
    }
    
    func testProjectedImmediatelyAfterNextReviewDate() {
        let referenceDate = Date(timeIntervalSince1970: 1443198600)
        let expected = StudyQueue(lessonsAvailable: 38, reviewsAvailable: 13, nextReviewDate: referenceDate, reviewsAvailableNextHour: 6, reviewsAvailableNextDay: 29)
        
        self.measureBlock() {
            self.databaseQueue.inDatabase { database in
                let projectedStudyQueue = try! SRSDataItemCoder.projectedStudyQueue(database, referenceDate: referenceDate)
                XCTAssertEqual(projectedStudyQueue, expected)
            }
        }
    }
    
    func testProjectedAfterSecondBatch() {
        let referenceDate = Date(timeIntervalSince1970: 1443199500)
        let expected = StudyQueue(lessonsAvailable: 38, reviewsAvailable: 18, nextReviewDate: referenceDate, reviewsAvailableNextHour: 1, reviewsAvailableNextDay: 27)
        
        self.measureBlock() {
            self.databaseQueue.inDatabase { database in
                let projectedStudyQueue = try! SRSDataItemCoder.projectedStudyQueue(database, referenceDate: referenceDate)
                XCTAssertEqual(projectedStudyQueue, expected)
            }
        }
    }
    
    func testProjectedAfterThirdBatch() {
        let referenceDate = Date(timeIntervalSince1970: 1443200400)
        let expected = StudyQueue(lessonsAvailable: 38, reviewsAvailable: 19, nextReviewDate: referenceDate, reviewsAvailableNextHour: 0, reviewsAvailableNextDay: 34)
        
        self.measureBlock() {
            self.databaseQueue.inDatabase { database in
                let projectedStudyQueue = try! SRSDataItemCoder.projectedStudyQueue(database, referenceDate: referenceDate)
                XCTAssertEqual(projectedStudyQueue, expected)
            }
        }
    }
}
#endif
