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
    override func viewDidLoad() {
        super.viewDidLoad()
        // observer for getiing data
        viewModel.$list.sink {[weak self] list in
            self?.refresData(data: list)
        }.store(in: &bag)
        setUpNavigationBar()
        setUpData()
    }

    //MARK: - Custom Method
    func setUpNavigationBar() {
        let navBar = UINavigationBar()
        navBar.translatesAutoresizingMaskIntoConstraints = false
        let navItem = UINavigationItem(title: "Wethor data")
        navBar.setItems([navItem], animated: false)
        view.addSubview(navBar)

        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        tblWeather.translatesAutoresizingMaskIntoConstraints = false
        if let topConstraint = view.constraints.first(where: {
            ($0.firstItem as? UITableView) == tblWeather && $0.firstAttribute == .top
        }) {
            view.removeConstraint(topConstraint)
        }
        tblWeather.topAnchor.constraint(equalTo: navBar.bottomAnchor).isActive = true
    }

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
