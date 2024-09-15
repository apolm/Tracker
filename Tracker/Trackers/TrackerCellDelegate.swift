import Foundation

protocol TrackerCellDelegate: AnyObject {
    func trackerCellDidChangeCompletion(for cell: TrackerCell, to isCompleted: Bool)
}
