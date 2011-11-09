/*******************************************************************************
*
* FILE:		Code_1_6_2.java
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

public class Code_1_6_2 {
	public static void main(String[] args)
	{
		int w, x, y, z;
		int i = 3;
		int j = 4;

		{
			int i2 = 5;
			w = i2 + j;
		}

		x = i + j;

		{
			int j2 = 6;
			i = 7;
			y = i + j2;
		}

		z = i + j;

		System.out.println("w:" + w + ",\tx:" + x + ",\ty:" + y + ",\tz:" + z);
	}
}
