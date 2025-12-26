package com.britemoon.cps;

import org.w3c.dom.*;
import java.util.Vector;

final public class XmlElementList extends Vector implements NodeList
{
	 public int getLength()
	 {
	 	return size();
	 }

	 public Node item(int index)
	 {
	 	return (Node)get(index);
	 }
}
