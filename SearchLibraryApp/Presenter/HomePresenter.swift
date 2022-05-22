//
//  HomePresenter.swift
//  SearchLibraryApp
//
//  Created by t032fj on 2022/05/14.
//

import Foundation

protocol HomePresenterInput: AnyObject {
    
    func didSearchLocationLibrary(latitude: Double, logitude: Double)
    func didFetchAllItem()
    func didDistributeItem()
}

protocol HomePresenterOutput: AnyObject {
    
    func makingChart(counts: [Int], labels: [String])
    func updateTotalLabels(days: [Date])
}

class HomePresenter {
    
    private weak var output: HomePresenterOutput?
    private var model: HomeModelInput
    
    var cartItems: [CartItem] = []
    
    init(output: HomePresenterOutput, model: HomeModelInput) {
        self.output = output
        self.model = model
    }
}

extension HomePresenter: HomePresenterInput {
    
    func didFetchAllItem() {
        
        model.fetchAllItem { days, items  in
            if days != [] {
                self.output?.updateTotalLabels(days: days)
                self.cartItems = items
            }
        }
    }

    func didSearchLocationLibrary(latitude: Double, logitude: Double) {
        
        model.searchLocationLibrary(latitude: latitude, longitude: logitude)
    }
    
    func didDistributeItem() {
        
        model.distributeItem(cartItems: self.cartItems) { counts, chartLabels in
            self.output?.makingChart(counts: counts, labels: chartLabels)
        }
    }
}
