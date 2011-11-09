/*******************************************************************************
*
* FILE:		Code_1_6_1.java
*
* DESC:		EECS 337 Homework Assignment 1
*
* AUTHOR:	ajk108
*
* DATE:		September 6, 2011
*
* EDIT HISTORY:	
*
*******************************************************************************/

public class Code_1_6_1 {

    //public static void main(String[] args)
	public static void main()
    	{
		int w, x, y, z;
		int i = 4;
		int j = 5;
		{
			int j2 = 7;
			i = 6;
			w = i + j2;
		}

		x = i + j;

		{
			int i2 = 8;
			y = i2 + j;
		}

		z = i + j;

//		System.out.println("w:" + w + ",\tx:" + x + ",\ty:" + y + ",\tz:" + z);
	}
}
