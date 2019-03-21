
public class Cell
{
  private int type;
  private float[][] x;
  private float[][] v;
  // 0 - nothing
  // 1 - block
  // 2 - moving block
  // 3 - rotation base
  // 4+ - powerup
  
  public Cell()
  {
    clear();
    x = new float[10][10];
    v = new float[x.length][x[0].length];
  }
  
  public void setRipple(float height)
  {
    for(int i=0;i<x.length;i++)
    for(int j=0;j<x[0].length;j++)
    {
      x[i][j] = height;
    }
  }
  
  public void transfer(Cell cell)
  {
    this.type = cell.type;
  }
  
  public void clear()
  {
    type = 0;
  }
  
  public int getType()
  {
    return type;
  }
  
}