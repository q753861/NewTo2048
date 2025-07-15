// 数字与颜色对照表
// | 数字  | 颜色     | Swift 颜色代码                        |
// |-------|---------|---------------------------------------|
// | 0     | 白色     | `.white`                              |
// | 2     | 浅绿色   | `Color(red: 0.9, green: 1.0, blue: 0.9)` |
// | 4     | 柠檬黄   | `Color(red: 0.8, green: 1.0, blue: 0.8)` |
// | 8     | 浅橙色   | `Color(red: 0.7, green: 0.9, blue: 0.6)` |
// | 16    | 橙色     | `Color(red: 0.6, green: 0.8, blue: 0.5)` |
// | 32    | 深橙色   | `Color(red: 0.5, green: 0.7, blue: 0.4)` |
// | 64    | 鲜红色   | `Color(red: 0.4, green: 0.6, blue: 0.3)` |
// | 128   | 浅绿色   | `Color(red: 0.3, green: 0.5, blue: 0.25)`|
// | 256   | 亮绿色   | `Color(red: 0.35, green: 0.45, blue: 0.2)`|
// | 512   | 天蓝色   | `Color(red: 0.3, green: 0.4, blue: 0.2)` |
// | 1024  | 亮蓝色   | `Color(red: 0.25, green: 0.35, blue: 0.15)`|
// | 2048  | 鲜紫色   | `Color(red: 0.2, green: 0.3, blue: 0.1)`  |

import SwiftUI

// MARK: Color
func valueToColor(val: Int) -> Color {
    switch val {
        case 0: return .white
        case 2: return Color(red: 0.9, green: 1.0, blue: 0.9)
        case 4: return Color(red: 0.8, green: 1.0, blue: 0.8)
        case 8: return Color(red: 0.7, green: 0.9, blue: 0.6)
        case 16: return Color(red: 0.6, green: 0.8, blue: 0.5)
        case 32: return Color(red: 0.5, green: 0.7, blue: 0.4)
        case 64: return Color(red: 0.4, green: 0.6, blue: 0.3)
        case 128: return Color(red: 0.3, green: 0.5, blue: 0.25)
        case 256: return Color(red: 0.35, green: 0.45, blue: 0.2)
        case 512: return Color(red: 0.3, green: 0.4, blue: 0.2)
        case 1024: return Color(red: 0.25, green: 0.35, blue: 0.15)
        case 2048: return Color(red: 0.2, green: 0.3, blue: 0.1)
        default: return .mint
    }
}

struct cell : Identifiable {
    let id = UUID()
    var value : Int = 0
    var color: Color {
        valueToColor(val: value)
    }
    var pic : String = ""
    var frameSize : CGFloat = 96
    var border : Color = .black
    var row : Int = 9
    var col : Int = 9
    var positionx: CGFloat {
        CGFloat(col) * frameSize
    }
    var positiony: CGFloat {
        CGFloat(row) * frameSize
    }
}


struct ContentView: View {
    let pickFromCell : cell = cell()
    let framesize : CGFloat = cell().frameSize
    
    @State var cells : [cell] = [cell(value: Int.random(in: 1...2) * 2, row: Int.random(in: 0...3), col: Int.random(in: 0...3))]
    @State var theNewCell : cell? = nil
    @State var newCellOpacity: Double = 0.0
    @State var isMoving = false
    
    func addNewCell(){
        if cells.count >= 16{
            print("Game Over")
            cells = [cell(value: Int.random(in: 1...2) * 2, row: Int.random(in: 0...3), col: Int.random(in: 0...3))]
            return
        }
        let newCellRow : Int = Int.random(in: 0...3)
        let newCellCol : Int = Int.random(in: 0...3)
        let newCellVal : Int = 2
        for cell in cells {
            if cell.row == newCellRow && cell.col == newCellCol{
                addNewCell()
                return
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                theNewCell = cell(value: newCellVal, row: newCellRow, col: newCellCol)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if theNewCell != nil  {
                cells.append(theNewCell!)
                theNewCell = nil
            }
        }
    }
    
    func cellsSort(){
        cells.sort {
            if $0.row != $1.row {
                return $0.row < $1.row
            } else {
                return $0.col < $1.col
            }
        }
    }
    
    func slide(dir: String){
        cellsSort()
        
        for row in 0...3{
            var j = 0
            let index = dir == "left" || dir == "up" ? Array(0...cells.count-1) : Array(0...cells.count-1).reversed()
            for i in index {
                if dir == "left" || dir == "right"{
                    if cells[i].row == row{
                        cells[i].col = (dir == "right" ? 3-j : j)
                        j += 1
                    }
                }else{
                    if cells[i].col == row{
                        cells[i].row = (dir == "down" ? 3-j : j)
                        j += 1
                    }
                }
            }
        }
    }
    
    func merge(dir: String){
        cellsSort()
        var tempCells : [[cell]] = []
        var dirindex : Int = 0
        var dirTotal : [Int] = []
        
        
        if dir == "left" || dir == "right" {
            for row in 0...3{
                tempCells.append(cells.filter{$0.row == row})
                tempCells[row].sort {$0.col < $1.col}
            }
        }else{
            for col in 0...3{
                tempCells.append(cells.filter{$0.col == col})
                tempCells[col].sort {$0.row < $1.row}
            }
        }
        
        for rowcol in 0...3{
            if tempCells[rowcol].count > 1{
                //from right to left merge
                dirindex = dir == "left" || dir == "up" ? 1 : -1
                dirTotal = dir == "left" || dir == "up" ? Array(0..<tempCells[rowcol].count-1) : Array(1..<tempCells[rowcol].count).reversed()
                for i in dirTotal{
                    if tempCells[rowcol][i].value == tempCells[rowcol][i+dirindex].value{
                        tempCells[rowcol][i].value *= 2
                        tempCells[rowcol][i+dirindex].value = 0
                    }
                }
                tempCells[rowcol] = tempCells[rowcol].filter{$0.value != 0}
            }
        }

        cells.removeAll()
        for row in 0...3 {
            cells.append(contentsOf: tempCells[row])
        }
    }

    func move(dir: String){
        if isMoving { return }
        isMoving = true
        
        withAnimation(.easeInOut(duration: 0.3)) {
            slide(dir: dir)
            //animation trigger
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            withAnimation(.easeInOut(duration: 0.2)) {
                merge(dir: dir)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.2)) {
                slide(dir: dir)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeInOut(duration: 0.2)) {
                addNewCell()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isMoving = false
        }
    }
    
    var body: some View {
        ZStack{
            ZStack{
                GeometryReader{ geometry in
                    //this is background
                    ForEach(0...3, id: \.self){tr in
                        ForEach(0...3, id: \.self){td in
                        Rectangle()
                                .fill(pickFromCell.color)
                                .border(.black, width: 1)
                                .shadow(radius: 3)
                                .frame(width: framesize, height: framesize)
                                .position(x: CGFloat(tr) * framesize, y: CGFloat(td) * framesize)
                            if let c = theNewCell {
                                Rectangle()
                                        .fill(.yellow)
                                        .border(.black, width: 1)
                                        .frame(width: framesize, height: framesize)
                                        .position(x: c.positionx, y: c.positiony)
                                        .opacity(0.3)
                            }
                        }
                    }
                    
                    //this is real value cells
                    ForEach(cells, id: \.id){c in
                        Rectangle()
                            .fill(c.color)
                            .border(.black, width: 1)
                            .shadow(radius: 3)
                            .frame(width: framesize, height: framesize)
                            .position(x: c.positionx, y: c.positiony)
                        
                        Text("\(c.value)")
                            .font(.system(size: 35))
                            .position(x: c.positionx, y: c.positiony)
                         
                        
                    }
                }
            }
            .frame(width: framesize * 4, height: framesize * 4)
            .position(x: UIScreen.main.bounds.width/2 + framesize/2, y:UIScreen.main.bounds.height/2)
            .scaleEffect(CGFloat(1))
            
            //MARK use swipe later
            Image(systemName: "arrow.up")
                .resizable()
                .frame(width: 50, height: 50)
                .position(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/1.4)
                .onTapGesture {
                    move(dir: "up")
                }
            Image(systemName: "arrow.left")
                .resizable()
                .frame(width: 50, height: 50)
                .position(x: UIScreen.main.bounds.width/5, y: UIScreen.main.bounds.height/1.3)
                .onTapGesture {
                    move(dir: "left")
                }
            Image(systemName: "arrow.right")
                .resizable()
                .frame(width: 50, height: 50)
                .position(x: UIScreen.main.bounds.width/1.3, y: UIScreen.main.bounds.height/1.3)
                .onTapGesture {
                    move(dir: "right")
                }
            Image(systemName: "arrow.down")
                .resizable()
                .frame(width: 50, height: 50)
                .position(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/1.2)
                .onTapGesture {
                    move(dir: "down")
                }
        }
        .background(Color(red: 1.0, green: 0.95, blue: 0.8))
    }
}

#Preview {
    ContentView()
}
