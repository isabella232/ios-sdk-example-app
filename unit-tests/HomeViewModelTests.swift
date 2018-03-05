//
//  unit_tests.swift
//  unit-tests
//
//  Created by Jean-Michel Barbieri on 10/6/17.
//  Copyright © 2017 Vibes Media. All rights reserved.
//

import XCTest
import OHHTTPStubs
import RxSwift

class HomeViewModelTests: XCTestCase {
    fileprivate let sentRequest: URLRequest? = nil
    fileprivate let baseURL = "public-api.vibescm.com"
    fileprivate let pathRegisterDevice = ""
    fileprivate var viewModel: HomeViewModel? = nil
    fileprivate let registerDeviceButtonTap = Variable("")
    fileprivate let registerPushButtonTap = Variable("")
    fileprivate let bag = DisposeBag()
    fileprivate let appleTokenSubject = Variable("0FAYjqS3PA8sVvnuHsa4TVTydSZGw5qiXUF1z28X-x_di079aCDe3RmiTOI6DPpWp3n9geCrZpfHlCFrR1gzblt26oaP86BTWiVVeIsw3zN4HuT_FPWkHglmKV3OMGZ".data(using: .utf8)!)
    
    func setUpBackendResponse() {
        stub(condition: (isHost(baseURL) && pathEndsWith("devices"))) { request -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("registerDevice201Response.json", type(of: self))
            return fixture(filePath: stubPath!, status: 201, headers: ["Content-Type":"application/json"])
        }
        
        stub(condition: (isHost(baseURL) && pathEndsWith("push_registration"))) { request -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("registerPush204Response.json", type(of: self))
            return fixture(filePath: stubPath!, status: 201, headers: ["Content-Type":"application/json"])
        }
        
        stub(condition: (isHost(baseURL) && pathEndsWith("push_registration"))) { request -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("registerPush204Response.json", type(of: self))
            // same fixture for registerPush and unregisterPush
            return fixture(filePath: stubPath!, status: 201, headers: ["Content-Type":"application/json"])
        }
        
        stub(condition: (isHost(baseURL) && pathEndsWith("c038bdc0-0ba7-435c-a124-ae234d971aca"))) { request -> OHHTTPStubsResponse in
            let stubPath = OHPathForFile("unregisterDevice200Response.json", type(of: self))
            return fixture(filePath: stubPath!, status: 201, headers: ["Content-Type":"application/json"])
        }
    }
    
    override func setUp() {
        super.setUp()
        setUpBackendResponse()
        viewModel = HomeViewModel()
    }
    
    func testRegisterDeviceTextIsUpdatedAfterSuccess() {
        let expectation1 = expectation(description: "Register button text is updated after register device success")
        _ = viewModel?.regDevBtnTitleSubj
            .asObservable()
            .filter { $0 == NSLocalizedString("homeView.unregisterButton", comment: "")}
            .subscribe(onNext: { _ in
                expectation1.fulfill()
            })
            .disposed(by: bag)
        
        viewModel?.registerOrUnregisterDevice()
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testUnRegisterDeviceTextIsUpdatedAfterSuccess() {
        let expectation1 = expectation(description: "Register button text is updated after register device success")
        _ = viewModel?.regDevBtnTitleSubj
            .asObservable()
            .filter { $0 == NSLocalizedString("homeView.unregisterButton", comment: "")}
            .subscribe(onNext: { _ in
                expectation1.fulfill()
            })
            .disposed(by: bag)
        
        viewModel?.registerOrUnregisterDevice()
        registerDeviceButtonTap.value = "click" // Register device
        waitForExpectations(timeout: 2, handler: { error in
            XCTAssertNil(error)
            let expectation2 = self.expectation(description: "Register button text is updated after unregister device success")
            
            _ = self.viewModel?.regDevBtnTitleSubj
                .asObservable()
                .filter { $0 == NSLocalizedString("homeView.registerButton", comment: "")}
                .subscribe(onNext: { _ in
                    expectation2.fulfill()
                })
                .disposed(by: self.bag)
            
            self.viewModel?.registerOrUnregisterDevice()
            
            self.waitForExpectations(timeout: 10, handler: nil)
        })
    }
    
    func testDeviceIdLabelUpdated() {
        let expectation1 = expectation(description: "Device id label is updated after register device success")
        _ = viewModel?.deviceIdValueSubj
            .asObservable()
            .filter { $0 == "c038bdc0-0ba7-435c-a124-ae234d971aca" }
            .take(1)
            .subscribe(onNext: { text in
                expectation1.fulfill()
            })
            .disposed(by: bag)
        self.viewModel?.registerOrUnregisterDevice()
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testPushButtonEnabled() {
        let expectation1 = expectation(description: "Register push button is enabled after register device success")
        _ = viewModel?.pushButtonEnableStateSubj
            .asObservable()
            .filter { $0 }
            .subscribe(onNext: { _ in
                expectation1.fulfill()
            })
            .disposed(by: bag)
        
        viewModel?.registerOrUnregisterDevice()
        waitForExpectations(timeout: 2, handler: nil)
    }
    
    func testRegisterPush() {
        let expectation1 = expectation(description: "Register push button is enabled after register device success")
        let expectation2 = expectation(description: "Register push text is updated after register push success")
        
        _ = viewModel?.pushButtonEnableStateSubj
            .asObservable()
            .filter { $0 }
            .subscribe(onNext: { _ in
                expectation1.fulfill()
                self.registerPushButtonTap.value = "click"
            })
            .disposed(by: bag)
        
        _ = viewModel?.regPushLabelTitleSubj
            .asObservable()
            .filter { $0.0 == NSLocalizedString("homeView.pushregistered", comment: "")}
            .filter { $0.1 == UIColor.green}
            .subscribe(onNext: { (text, color) in
                expectation2.fulfill()
            })
            .disposed(by: bag)
        
        self.viewModel?.registerOrUnregisterDevice()
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testUnRegisterPush() {
        let expectation1 = expectation(description: "Register push button is enabled after register device success")
        let expectation2 = expectation(description: "Register push text is updated after register push success")
        
        _ = viewModel?.pushButtonEnableStateSubj
            .asObservable()
            .filter { $0 }
            .subscribe(onNext: { _ in
                expectation1.fulfill()
                self.registerPushButtonTap.value = "click"
            })
            .disposed(by: bag)
        
        _ = viewModel?.regPushLabelTitleSubj
            .asObservable()
            .filter { $0.0 == NSLocalizedString("homeView.pushregistered", comment: "")}
            .filter { $0.1 == UIColor.green}
            .subscribe(onNext: { (text, color) in
                expectation2.fulfill()
            })
            .disposed(by: bag)
        
        self.viewModel?.registerOrUnregisterDevice()
        waitForExpectations(timeout: 10, handler: { error in
            XCTAssertNil(error)
            
            let expectation3 = self.expectation(description: "Register push text is updated after unregister push success")
            _ = self.viewModel?.regPushLabelTitleSubj
                .asObservable()
                .filter { $0.0 == NSLocalizedString("homeView.pushunregistered", comment: "")}
                .filter { $0.1 == UIColor.red}
                .subscribe(onNext: { (text, color) in
                    expectation3.fulfill()
                })
                .disposed(by: self.bag)
            
            self.viewModel?.registerOrUnregisterPush()
            self.waitForExpectations(timeout: 10, handler: nil)
        })
    }
    
    func testRegisterPushTextUpdated() {
        let expectation1 = expectation(description: "Register push button is enabled after register device success")
        let expectation2 = expectation(description: "Register push text is updated after register push success")
        let expectation3 = expectation(description: "Register push button text is updated after register push success")
        
        _ = viewModel?.pushButtonEnableStateSubj
            .asObservable()
            .filter { $0 }
            .subscribe(onNext: { _ in
                expectation1.fulfill()
                self.registerPushButtonTap.value = "click"
            })
            .disposed(by: bag)
        
        _ = viewModel?.regPushLabelTitleSubj
            .asObservable()
            .filter { $0.0 == NSLocalizedString("homeView.pushregistered", comment: "")}
            .filter { $0.1 == UIColor.green}
            .subscribe(onNext: { (text, color) in
                expectation2.fulfill()
            })
            .disposed(by: bag)
        
        _ = viewModel?.regPushBtnTitleSubj
            .asObservable()
            .filter { $0 == NSLocalizedString("homeView.unregisterPushButton", comment: "")}
            .subscribe(onNext: { _ in
                expectation3.fulfill()
            })
        
        viewModel?.registerOrUnregisterDevice()
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    func testRegisterPushThenUnregisterDevice() {
        let expectation1 = expectation(description: "Register push button is enabled after register device success")
        let expectation2 = expectation(description: "Register push text is updated after register push success")
        
        _ = viewModel?.pushButtonEnableStateSubj
            .asObservable()
            .filter { $0 }
            .take(1)
            .subscribe(onNext: { _ in
                expectation1.fulfill()
                self.registerPushButtonTap.value = "click"
            })
            .disposed(by: bag)
        
        _ = viewModel?.regPushLabelTitleSubj
            .asObservable()
            .filter { $0.0 == NSLocalizedString("homeView.pushregistered", comment: "")}
            .filter { $0.1 == UIColor.green}
            .take(1)
            .subscribe(onNext: { (text, color) in
                expectation2.fulfill()
            })
            .disposed(by: bag)
        
        viewModel?.registerOrUnregisterDevice()
        
        waitForExpectations(timeout: 10) { error in
            XCTAssertNil(error)
            // When register PUSH == OK and user clicks on 'unregister device'
            let expectation3 = self.expectation(description: "register push must be reset")
            let expectation4 = self.expectation(description: "register push button must be disabled")
            let expectation5 = self.expectation(description: "register device text must be register")
            let expectation6 = self.expectation(description: "register push label must be red and 'unregistered'")
            
            _ = self.viewModel?.regPushBtnTitleSubj
                .asObservable()
                .filter {$0 == NSLocalizedString("homeView.registerPushButton", comment: "")}
                .subscribe(onNext: { text in
                    expectation3.fulfill()
                })
                .disposed(by: self.bag)
            
            _ = self.viewModel?.pushButtonEnableStateSubj
                .asObservable()
                .filter {!$0}
                .subscribe(onNext: { text in
                    expectation4.fulfill()
                })
                .disposed(by: self.bag)
            
            _ = self.viewModel?.regDevBtnTitleSubj
                .asObservable()
                .filter { $0 == NSLocalizedString("homeView.registerButton", comment: "")}
                .subscribe(onNext: { _ in
                    expectation5.fulfill()
                })
                .disposed(by: self.bag)
            
            _ = self.viewModel?.regPushLabelTitleSubj
                .asObservable()
                .filter { $0.0 == NSLocalizedString("homeView.pushunregistered", comment: "")}
                .filter { $0.1 == UIColor.red}
                .subscribe(onNext: { (text, color) in
                    expectation6.fulfill()
                })
                .disposed(by: self.bag)
            
            self.viewModel?.registerOrUnregisterDevice()
            self.waitForExpectations(timeout: 10, handler: { error in
                XCTAssertNil(error)
            })
        }
    }
}
