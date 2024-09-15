import UIKit
import CoreData

final class Test: AddTrackerFlowViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Test"
        
        addCoreDataButtons()
    }
    
    private lazy var testLabel: UILabel = {
        let label = UILabel()
        label.text = "Test"
        label.backgroundColor = UIColor(red: 51/255.0, green: 207/255.0, blue: 105/255.0, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var testLabel2: UILabel = {
        let label = UILabel()
        label.text = "Test"
        label.backgroundColor = UIColor(red: 255/255.0, green: 103/255.0, blue: 77/255.0, alpha: 1)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var printCoreDataButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Print CoreData", for: .normal)
        button.addTarget(self, action: #selector(printCoreDataTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var clearButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Clear Core Data", for: .normal)
        button.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func addLabels() {
        view.addSubview(testLabel)
        view.addSubview(testLabel2)
                
        NSLayoutConstraint.activate([
            testLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            testLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            testLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            testLabel.heightAnchor.constraint(equalToConstant: 60),
            
            testLabel2.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            testLabel2.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            testLabel2.topAnchor.constraint(equalTo: testLabel.bottomAnchor),
            testLabel2.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
    
    func addCoreDataButtons() {
        view.addSubview(printCoreDataButton)
        view.addSubview(clearButton)
        
        NSLayoutConstraint.activate([
            printCoreDataButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            printCoreDataButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            printCoreDataButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            printCoreDataButton.heightAnchor.constraint(equalToConstant: 44),
            
            clearButton.topAnchor.constraint(equalTo: printCoreDataButton.bottomAnchor, constant: 16),
            clearButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            clearButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            clearButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func printCoreDataTapped() {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        
        do {
            let categories = try DataController.shared.context.fetch(fetchRequest)
            print("---- Tracker Categories ----")
            for category in categories {
                print("Category Name: \(category.name ?? "Unknown")")
            }
        } catch {
            print("Failed to fetch TrackerCategoryCoreData: \(error)")
        }
        
        print("")
        
        let fetchRequestT: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        
        do {
            let trackers = try DataController.shared.context.fetch(fetchRequestT)
            print("---- Trackers ----")
            for tracker in trackers {
                print("Tracker Name: \(tracker.name ?? "Unknown")")
                print("Tracker ID: \(tracker.id?.uuidString ?? "Unknown")")
                print("Tracker Emoji: \(tracker.emoji ?? "Unknown")")
                print("Tracker Color Hex: \(tracker.colorHex ?? "Unknown")")
                print("Tracker Days Raw: \(tracker.daysRaw ?? "None")")
                print("Category: \(tracker.category?.name ?? "None")")
                print("")
            }
        } catch {
            print("Failed to fetch TrackerCoreData: \(error)")
        }
    }
            
    @objc private func clearTapped() {
        let fetchRequestRecords: NSFetchRequest<NSFetchRequestResult> = TrackerRecordCoreData.fetchRequest()
        let fetchRequestTrackers: NSFetchRequest<NSFetchRequestResult> = TrackerCoreData.fetchRequest()
        let fetchRequestCategories: NSFetchRequest<NSFetchRequestResult> = TrackerCategoryCoreData.fetchRequest()
        
        let batchDeleteRequestRecords = NSBatchDeleteRequest(fetchRequest: fetchRequestRecords)
        let batchDeleteRequestTrackers = NSBatchDeleteRequest(fetchRequest: fetchRequestTrackers)
        let batchDeleteRequestCategories = NSBatchDeleteRequest(fetchRequest: fetchRequestCategories)
                
        do {
            try DataController.shared.context.execute(batchDeleteRequestRecords)
            try DataController.shared.context.execute(batchDeleteRequestTrackers)
            try DataController.shared.context.execute(batchDeleteRequestCategories)
                        
            DataController.shared.context.reset()
                        
            print("All data deleted successfully.")
        } catch {
            print("Failed to delete data: \(error)")
        }
    }
}
