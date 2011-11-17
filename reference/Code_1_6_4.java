/*******************************************************************************
*
* FILE:  Code_1_6_4.java
*
* DESC:  EECS 337 Homework Assignment 1
*
* AUTHOR: dxo4
*
* DATE:  August 30, 2011
*
* EDIT HISTORY: 
*
*******************************************************************************/

public class Code_1_6_4 {   
/*
 * enter the sample code from 1.6.4
 */
public static int x = 2;

public static void b()
{
 x = (x+1);
 System.out.printf( "%d\n", x);
}

public static void c()
{
 int x = 1;
 System.out.printf( "%d\n", (x+1));
}

/*
 * main program
 */
  public static void main(String[] args) {   
 b();
 c();
}
}