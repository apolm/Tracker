import Foundation

struct GeometricParams {
    let columnCount: Int
    let rowCount: Int
    
    let leftInset: CGFloat
    let rightInset: CGFloat
    let topInset: CGFloat
    let bottomInset: CGFloat
    
    let columnSpacing: CGFloat
    let rowSpacing: CGFloat
    
    let totalInsetWidth: CGFloat
    let totalInsetHeight: CGFloat
    
    init(
        columnCount: Int,
        rowCount: Int,
        leftInset: CGFloat,
        rightInset: CGFloat,
        topInset: CGFloat,
        bottomInset: CGFloat,
        columnSpacing: CGFloat,
        rowSpacing: CGFloat
    ) {
        self.columnCount = columnCount
        self.rowCount = rowCount
        
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.topInset = topInset
        self.bottomInset = bottomInset
        
        self.columnSpacing = columnSpacing
        self.rowSpacing = rowSpacing
        
        self.totalInsetWidth = leftInset + rightInset + CGFloat(columnCount - 1) * columnSpacing
        self.totalInsetHeight = topInset + bottomInset + CGFloat(rowCount - 1) * rowSpacing
    }
}
