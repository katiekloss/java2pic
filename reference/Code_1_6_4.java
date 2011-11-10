/*******************************************************************************
*
* FILE:		Code_1_6_4.java
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

public class Code_1_6_4 {

	public static int x = 2;

	public static void b()
	{
		x = x + 1;
		System.out.println(x);
	}

	public static void c()
	{
		int x = 1;
		System.out.println(x + 1);
	}

	public static void main(String[] args)
	{
		b();
		c();
	}
}
