//
//  CoinManager.swift
//  CoinApp
//
//  Created by いわし on 2020/09/13.
//  Copyright © 2020 abetkma.com. All rights reserved.
//

import Foundation

protocol CoinManegerDelegate {
    func didUpdatePrice(price: String, virtualCurrency: String,currency:String)
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate"
    let apiKey = "8878D9DA-AEB9-43A5-ADF8-07EC295FDF58"
    
    let currencyArray = ["USD","CNY","EUR","JPY","HKD",]
    let virtualCurrencyArray = ["BTC","BCH","ETH","XRP","XEM"]
    
//    プロトコル にアクセスするため
    var delegate:CoinManegerDelegate?
    
    func getCoinPrice(currency:String,virtualcurrency:String){
        print(currency,"これこれ")
        print(virtualcurrency)
        let urlString = "\(baseURL)/\(virtualcurrency)/\(currency)?apikey=\(apiKey)"
        print(urlString)
        if let url = URL(string: urlString) {
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url){ (data,responce,error)in
                
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data{
                    if let bitcoinPrice = self.parseJSON(safeData){
                        let priceString = String(format: "%.2f", bitcoinPrice)
                        self.delegate?.didUpdatePrice(price: priceString, virtualCurrency:virtualcurrency,currency: currency)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJSON(_ data: Data) -> Double? {
        
//        JSONの解析用に定義
        let decoder = JSONDecoder()
        
        do {
            let decodeData = try decoder.decode(CoinData.self, from: data)
            
            let lastPrice = decodeData.rate
            
            print(lastPrice)
            return lastPrice
            
        } catch {
            
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
