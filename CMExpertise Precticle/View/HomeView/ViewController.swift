//
//  ViewController.swift
//  CMExpertise Precticle
//
//  Created by Dhananjay chauhan on 31/03/24.
//

import UIKit
import Combine
//MARK: - Structure to store data after sorting
struct WData {
    var date: String
    var data: [List]
}


class ViewController: UIViewController {
    
    //MARK: - Outlet
    @IBOutlet weak var tblWeather: UITableView!
    var viewModel = WeatherDataViewModel()
    var arrData = [WData]()
    var bag = Set<AnyCancellable>()
    
    //MARK: - lifecycle Method
    /// Called after the controller's view is loaded into memory.
    /// Sets the navigation title to "My Weather Data", subscribes to the
    /// view model's published list, and triggers initial data loading.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "My Weather Data"
        // observer for getiing data
        viewModel.$list.sink {[weak self] list in
            self?.refresData(data: list)
        }.store(in: &bag)
        setUpData()
    }

    //MARK: - Custom Method
    func setUpData() {
        setTableView()
//        getWeatherData()
//        getDataWithCodeble()
        getDataWithAwait()
    }
    
    func refresData(data: WeatherResModel?) {
        for i in data?.list ?? [] {
            let date = i.dtTxt?.getDate() ?? ""
            if let index = self.arrData.firstIndex(where: {$0.date == date}) {
                self.arrData[index].data.append(i)
            } else {
                self.arrData.append(WData(date: date, data: [i]))
            }
        }
        print("total data found = ",self.arrData.count)
        DispatchQueue.main.async {
            self.tblWeather.reloadData()
        }
    }
    
    func setTableView() {
        tblWeather.dataSource = self
        tblWeather.delegate = self
    }
}

//MARK: - Web service methods
extension ViewController {
    func getWeatherData() {
        viewModel.callWebServiceToGetWeather { data in
            self.refresData(data: data)
        }
    }
    
    func getDataWithCodeble() {
        viewModel.callWebServiceToGetData()
    }
    
    func getDataWithAwait() {
        Task { @MainActor in
            let result = await viewModel.getDataWithAwait()
            if let data = result {
                self.refresData(data: data)
            }
        }
    }
}

//MARK: - TableView DataSourse and delegate
extension ViewController : UITableViewDataSource,UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblWeather.dequeueReusableCell(withIdentifier: "WetherCell", for: indexPath) as! WetherCell
        cell.lblDate.text = arrData[indexPath.row].date
        cell.arrData = arrData[indexPath.row].data
        return cell
    }
}
