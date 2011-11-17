/*******************************************************************************
*
* FILE:		Code_1_6_2.java
*
* DESC:		EECS 337 Homework Assignment 1
*
* AUTHOR:	dxo4
*
* DATE:		August 30, 2011
*
* EDIT HISTORY:	
*
*******************************************************************************/

public class Code_1_6_2 {   
/*
 * main program
 */
  public static void main(String[] args) {   
/*
 *	enter the sample code from 1.6.2
 */
	int	w, x, y, z;
	int i = 3; int j = 4;
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
/*
 *	print the results
 */
	System.out.printf( "w:%d,\tx:%d,\ty:%d,\tz:%d\n", w, x, y, z);
/*
 *	no return value for Java
 */
 }
}
