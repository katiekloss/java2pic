/*******************************************************************************
*
* FILE:  Code_1_6_1.java
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
public class Code_1_6_1 {   
/*
 * main program
 */
  public static void main(String[] args) {   
/*
 * enter the sample code from 1.6.1
 */
 int w, x, y, z;
 int i = 4; int j = 5;
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
/*
 * print the results
 */
 System.out.printf( "w:%d,\tx:%d,\ty:%d,\tz:%d\n", w, x, y, z);
/*
 * no return value for Java
 */
 }
}
