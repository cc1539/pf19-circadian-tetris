
public class TetrisGrid
{
  private Cell[][] grid;
  private int lastPiece;
  private int[] pieceList;
  private float changing;
  
  public TetrisGrid(int w, int h)
  {
    grid = new Cell[w][h];
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      grid[x][y] = new Cell();
    }
    pieceList = new int[5];
    changing = -1;
    reset();
  }
  
  public int getRandomPieceId()
  {
    return (int)random(0,pieces.length);
  }
  
  public void newPieceList()
  {
    int lastPiece = getRandomPieceId();
    for(int i=0;i<pieceList.length;i++) {
      do {
        pieceList[i] = getRandomPieceId();
      } while(pieceList[i]==lastPiece);
      lastPiece = pieceList[i];
    }
  }
  
  public void shiftPieceList()
  {
    addPiece(pieces[pieceList[0]]);
    for(int i=0;i<pieceList.length-1;i++) {
      pieceList[i] = pieceList[i+1];
    }
    do {
      pieceList[pieceList.length-1] = getRandomPieceId();
    } while(pieceList[pieceList.length-2]==pieceList[pieceList.length-1]);
  }
  
  public void moveDown()
  {
    if(shiftValid(0,1)) {
      for(int y=grid[0].length-1;y>=1;y--)
      for(int x=0;x<grid.length;x++)
      {
        if(grid[x][y-1].type>=2) {
          grid[x][y].transfer(grid[x][y-1]);
          grid[x][y-1].clear();
        }
      }
    } else {
      solidify();
    }
  }
  
  public void moveUp()
  {
    if(shiftValid(0,-1)) {
      for(int y=0;y<grid[0].length-1;y++)
      for(int x=0;x<grid.length;x++)
      {
        if(grid[x][y+1].type>=2) {
          grid[x][y].transfer(grid[x][y+1]);
          grid[x][y+1].clear();
        }
      }
    }
  }
  
  public void moveRight()
  {
    if(shiftValid(1,0)) {
      for(int x=grid.length-1;x>=1;x--)
      for(int y=0;y<grid[0].length;y++)
      {
        if(grid[x-1][y].type>=2) {
          grid[x][y].transfer(grid[x-1][y]);
          grid[x-1][y].clear();
        }
      }
    }
  }
  
  public void moveLeft()
  {
    if(shiftValid(-1,0)) {
      for(int x=0;x<grid.length-1;x++)
      for(int y=0;y<grid[0].length;y++)
      {
        if(grid[x+1][y].type>=2) {
          grid[x][y].transfer(grid[x+1][y]);
          grid[x+1][y].clear();
        }
      }
    }
  }
  
  public boolean rowContainsAnything(int y)
  {
    for(int x=0;x<grid.length;x++) {
      if(grid[x][y].type>0) {
        return true;
      }
    }
    return false;
  }
  
  public void solidify()
  {
    score += 1;
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      if(grid[x][y].type>=2) {
        /*
        if(x+1>=grid.length||grid[x+1][y].getType()==1) {
          for(int i=0;i<grid[x][y].x[0].length;i++) {
            grid[x][y].x[grid[x][y].x.length-1][i] = 1;
          }
        }
        if(x-1<0||grid[x-1][y].getType()==1) {
          for(int i=0;i<grid[x][y].x[0].length;i++) {
            grid[x][y].x[0][i] = 1;
          }
        }
        if(y+1>=grid[0].length||grid[x][y+1].getType()==1) {
          for(int i=0;i<grid[x][y].x.length;i++) {
            grid[x][y].x[i][grid[x][y].x[0].length-1] = 1;
          }
        }
        if(y-1<0||grid[x][y-1].getType()==1) {
          for(int i=0;i<grid[x][y].x.length;i++) {
            grid[x][y].x[i][0] = 1;
          }
        }
        */
        grid[x][y].setRipple(1);
      }
    }
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      if(grid[x][y].type>=2) {
        grid[x][y].type = 1;
      }
    }
    if(!piecePlacable(pieces[pieceList[0]])) {
      clearAll();
      gameOver = true;
    } else {
      //clearRows();
      shiftPieceList();
    }
  }
  
  public void clearRows()
  {
    int rowsFilled = 0;
    for(int y=0;y<grid[0].length;y++) {
      boolean rowFilled = true;
      for(int x=0;x<grid.length;x++) {
        if(grid[x][y].type!=1) {
          rowFilled = false;
          break;
        }
      }
      if(rowFilled) {
        rowsFilled++;
        if((lines+rowsFilled)%4==0) {
          //interval /= 2;
          interval = max(1,interval-2);
        }
        for(int i=y;i>=1;i--) {
          for(int x=0;x<grid.length;x++) {
            grid[x][i].transfer(grid[x][i-1]);
          }
        }
      }
    }
    score += rowsFilled * rowsFilled;
    lines += rowsFilled;
  }
  
  public int[] getPivotPosition()
  {
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      if(grid[x][y].type==3) {
        return new int[]{x,y};
      }
    }
    return null;
  }
  
  public void rotateRight()
  {
    if(rotateRightValid()) {
      int[] pivot = getPivotPosition();
      if(pivot!=null) {
        ArrayList<int[]> newPositions = new ArrayList<int[]>();
        for(int x=0;x<grid.length;x++)
        for(int y=0;y<grid[0].length;y++)
        {
          if(grid[x][y].type==2) {
            int dx = pivot[1] - y;
            int dy = x - pivot[0];
            newPositions.add(new int[]{pivot[0]+dx,pivot[1]+dy});
          }
        }
        for(int x=0;x<grid.length;x++)
        for(int y=0;y<grid[0].length;y++)
        {
          if(grid[x][y].type==2) {
            grid[x][y].clear();
          }
        }
        for(int[] pos : newPositions) {
          grid[pos[0]][pos[1]].type = 2;
        }
      }
    }
  }
  
  public void rotateLeft()
  {
    if(rotateLeftValid()) {
      int[] pivot = getPivotPosition();
      if(pivot!=null) {
        ArrayList<int[]> newPositions = new ArrayList<int[]>();
        for(int x=0;x<grid.length;x++)
        for(int y=0;y<grid[0].length;y++)
        {
          if(grid[x][y].type==2) {
            int dx = -(pivot[1] - y);
            int dy = -(x - pivot[0]);
            newPositions.add(new int[]{pivot[0]+dx,pivot[1]+dy});
          }
        }
        for(int x=0;x<grid.length;x++)
        for(int y=0;y<grid[0].length;y++)
        {
          if(grid[x][y].type==2) {
            grid[x][y].clear();
          }
        }
        for(int[] pos : newPositions) {
          grid[pos[0]][pos[1]].type = 2;
        }
      }
    }
  }
  
  public boolean positionValid(int x, int y)
  {
    return !(x<0||y<0||x>=grid.length||y>=grid[0].length||grid[x][y].type==1);
  }
  
  public boolean shiftValid(int dx, int dy)
  {
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      if(grid[x][y].getType()>=2) {
        if(!positionValid(x+dx,y+dy)) {
          return false;
        }
      }
    }
    return true;
  }
  
  public boolean rotateRightValid()
  {
    int[] pivot = getPivotPosition();
    if(pivot!=null) {
      for(int x=0;x<grid.length;x++)
      for(int y=0;y<grid[0].length;y++)
      {
        if(grid[x][y].type==2) {
          int dx = pivot[1] - y;
          int dy = x - pivot[0];
          if(!positionValid(pivot[0]+dx,pivot[1]+dy)) {
            return false;
          }
        }
      }
      return true;
    }
    return false;
  }
  
  public boolean rotateLeftValid()
  {
    int[] pivot = getPivotPosition();
    if(pivot!=null) {
      for(int x=0;x<grid.length;x++)
      for(int y=0;y<grid[0].length;y++)
      {
        if(grid[x][y].type==2) {
          int dx = -(pivot[1] - y);
          int dy = -(x - pivot[0]);
          if(!positionValid(pivot[0]+dx,pivot[1]+dy)) {
            return false;
          }
        }
      }
      return true;
    }
    return false;
  }
  
  public void reset()
  {
    clearAll();
    newPieceList();
    shiftPieceList();
    interval = 64;
    score = 0;
    lines = 0;
    gameOver = false;
    frameCount = 0;
    day = true;
    for(int x=0;x<grid.length;x++)
    for(int y=4+(grid[0].length-2)/2;y<grid[0].length;y++)
    {
      grid[x][y].type = 1;
    }
    changing = -1;
  }
  
  public void flip()
  {
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      grid[x][y].type = grid[x][y].getType()==1?0:1;
    }
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length/2;y++)
    {
      int type = grid[x][y].type;
      grid[x][y].type = grid[x][grid[0].length-y-1].type;
      grid[x][grid[0].length-y-1].type = type;
    }
    for(int x=0;x<grid.length/2;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      int type = grid[x][y].type;
      grid[x][y].type = grid[grid.length-x-1][y].type;
      grid[grid.length-x-1][y].type = type;
    }
    for(int x=0;x<grid.length;x++)
    for(int y=grid[0].length-1;y>=2;y--)
    {
      grid[x][y].type = grid[x][y-2].type;
    }
    shiftPieceList();
    //clearRows();
  }
  
  public void draw(float xp, float yp, float w, float h)
  {
    pushMatrix();
    if(changing>=0) {
      translate(xp+w/2,yp+h/2);
      rotate(changing>HALF_PI?changing-PI:changing);
      translate(-xp-w/2,-yp-h/2);
      if((changing>HALF_PI)!=((changing+=(PI-changing)*0.05)>HALF_PI)) {
        flip();
      }
      if(PI-changing<=.01) {
        changing = -1;
      }
    }
    float cellw = w/grid.length;
    float cellh = h/(grid[0].length-2);
    stroke(0);
    PGraphics graphic = createGraphics((int)w+1,(int)h+1,JAVA2D);
    graphic.beginDraw();
    for(int x=0;x<grid.length;x++)
    for(int y=2;y<grid[0].length;y++)
    {
      if(grid[x][y].getType()==1) {
        graphic.noStroke();
        float miniw = cellw/grid[x][y].x.length;
        float minih = cellh/grid[x][y].x[0].length;
        for(int i=0;i<grid[x][y].x.length;i++)
        for(int j=0;j<grid[x][y].x[0].length;j++)
        {
          //fill(grid[x][y].x[i][j]*512);
          graphic.colorMode(HSB);
          graphic.fill((grid[x][y].x[i][j]*512)%255,grid[x][y].x[i][j]*512,grid[x][y].x[i][j]*512);
          graphic.rect(x*cellw+i*miniw,(y-2)*cellh+j*minih,miniw,minih);
        }
      } else if(grid[x][y].getType()>1||grid[x][y].getType()==-1) {
        graphic.stroke(day?0:255);
        graphic.colorMode(HSB);
        graphic.fill(255,255,255);
        graphic.rect(x*cellw,(y-2)*cellh,cellw,cellh);
        if(grid[x][y].getType()>=4) {
          graphic.fill(frameCount%255,255,255);
          graphic.rect(x*cellw+cellw/4,(y-2)*cellh+cellh/4,cellw/2,cellh/2);
        }
      }
    }
    graphic.endDraw();
    imageMode(CORNER);
    if(changing>0) {
      tint(255,255*(1-sin(changing)));
    }
    image(graphic.get(),xp,yp);
    tint(255);
    graphic.clear();
    graphic.beginDraw();
    graphic.stroke(day?0:255);
    for(int x=0;x<grid.length;x++)
    for(int y=2;y<grid[0].length;y++)
    {
      if(grid[x][y].getType()>=1) {
        if(x+1<grid.length&&grid[x+1][y].getType()<1) { graphic.line((x+1)*cellw,(y-2)*cellh,(x+1)*cellw,(y-1)*cellh); }
        if(x-1>=0&&grid[x-1][y].getType()<1) { graphic.line(x*cellw,(y-2)*cellh,x*cellw,(y-1)*cellh); }
        if(y+1<grid[0].length&&grid[x][y+1].getType()<1) { graphic.line(x*cellw,(y-1)*cellh,(x+1)*cellw,(y-1)*cellh); }
        if(y-1>=0&&grid[x][y-1].getType()<1) { graphic.line(x*cellw,(y-2)*cellh,(x+1)*cellw,(y-2)*cellh); }
      }
    }
    graphic.endDraw();
    image(graphic.get(),xp,yp);
    stroke(day?0:255);
    noFill();
    rect(xp,yp,w,h);
    showGhost(xp,yp,w,h);
    popMatrix();
  }
  
  public void addPiece(int[][] piece)
  {
    for(int i=0;i<piece.length;i++) {
      int x = piece[i][0];
      int y = piece[i][1]+2;
      grid[x][y].type = i==0?3:2;
    }
  }
  
  public boolean piecePlacable(int[][] piece)
  {
    for(int i=0;i<piece.length;i++) {
      int x = piece[i][0];
      int y = piece[i][1]+2;
      if(grid[x][y].getType()>=1) {
        return false;
      }
    }
    return true;
  }
  
  public void addRandomPiece()
  {
    int piece = 0;
    do {
      piece = getRandomPieceId();
    } while(piece==lastPiece);
    addPiece(pieces[piece]);
  }
  
  public void clearAll()
  {
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      grid[x][y].clear();
    }
  }
  
  public void shoot()
  {
    do {
      moveDown();
    } while(shiftValid(0,1));
    moveDown();
  }
  
  public void showGhost(float xp, float yp, float w, float h)
  {
    int minDistance = grid[0].length;
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      if(grid[x][y].getType()>=2) {
        int distance = 0;
        while(distance+y+1<grid[0].length && grid[x][y+distance+1].getType()!=1) {
          distance++;
        }
        distance-=2;
        minDistance = min(minDistance,distance);
      }
    }
    float cellw = w/grid.length;
    float cellh = h/(grid[0].length-2);
    stroke(day?0:255);
    noFill();
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      if(grid[x][y].getType()>=2) {
        rect(xp+x*cellw,yp+(y+minDistance)*cellh,cellw,cellh);
      }
    }
  }
  
  public void propagateWave()
  {
    float[][][][] waveData = new float
      [grid.length]
      [grid[0].length]
      [grid[0][0].x.length]
      [grid[0][0].x[0].length];
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      if(grid[x][y].getType()==1) {
        for(int i=0;i<grid[x][y].x.length;i++)
        for(int j=0;j<grid[x][y].x[0].length;j++)
        {
          waveData[x][y][i][j] = grid[x][y].x[i][j];
        }
      }
    }
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      if(grid[x][y].getType()==1) {
        for(int i=0;i<grid[x][y].x.length;i++)
        for(int j=0;j<grid[x][y].x[0].length;j++)
        {
          float avg = 0;
          int neighbors = 0;
          for(int u=-1;u<=1;u++)
          for(int v=-1;v<=1;v++)
          {
            int nu = i + u;
            int nv = j + v;
            int nx = x; if(nu<0){nu+=waveData[0][0].length;nx--;}else if(nu>=waveData[0][0].length){nu-=waveData[0][0].length;nx++;}
            int ny = y; if(nv<0){nv+=waveData[0][0][0].length;ny--;}else if(nv>=waveData[0][0][0].length){nv-=waveData[0][0][0].length;ny++;}
            if(nx<0||ny<0||nx>=grid.length||ny>=grid[0].length||grid[nx][ny].getType()!=1) continue;
            neighbors++;
            avg += waveData[nx][ny][nu][nv];
          }
          grid[x][y].x[i][j] += (grid[x][y].v[i][j] += (avg/neighbors-waveData[x][y][i][j])*.5);
        }
      }
    }
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      if(grid[x][y].getType()==1) {
        for(int i=0;i<grid[x][y].x.length;i++)
        for(int j=0;j<grid[x][y].x[0].length;j++)
        {
          grid[x][y].x[i][j] *= .995;
        }
      }
    }
    /*
    float average = 0;
    int avgN = 0;
    
    float[][] waveData = new float[grid.length][grid[0].length];
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      if(grid[x][y].getType()==1) {
        float laplace = 0;
        int neighbors = 0;
        for(int i=-1;i<=1;i++)
        for(int j=-1;j<=1;j++)
        {
          int u = x + i; if(u<0||u>=grid.length) continue;
          int v = y + j; if(v<0||v>=grid[0].length) continue;
          if(grid[u][v].getType()!=1) continue;
          neighbors++;
          laplace+=grid[u][v].scale;
        }
        if(neighbors>=1) {
          waveData[x][y] = grid[x][y].scale +
            (grid[x][y].riseSpeed += (laplace/neighbors-grid[x][y].scale)*.2);
        }
      } else {
        waveData[x][y] = 1;
      }
    }
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      grid[x][y].scale = waveData[x][y]*.95;
      average += grid[x][y].scale;
      avgN++;
    }
    */
  }
  
  public int powerupsAlreadyOnScreen()
  {
    int powerups = 0;
    for(int x=0;x<grid.length;x++)
    for(int y=0;y<grid[0].length;y++)
    {
      if(grid[x][y].getType()==-1) {
        powerups++;
      }
    }
    return powerups;
  }
  
  public void addPowerup()
  {
    if(powerupsAlreadyOnScreen()<maxPowerups) {
      int x = 0;
      int y = 0;
      while(true) {
        x = (int)random(0,grid.length);
        y = (int)random(0,grid[0].length);
        if(grid[x][y].getType()==1) {
          grid[x][y].type = -1;
          break;
        }
      }
    }
  }
  
}