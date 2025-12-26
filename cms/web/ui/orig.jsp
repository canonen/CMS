 
<%@ page import="org.apache.commons.fileupload.*,
				 org.apache.commons.fileupload.servlet.ServletFileUpload,
				 org.apache.commons.fileupload.disk.DiskFileItemFactory,
				 org.apache.commons.io.FilenameUtils, 
				 java.util.*,
				 java.io.File,
				java.util.Date,
				java.text.SimpleDateFormat,
				 java.lang.Exception" %>
  <%@page contentType="application/json; charset=UTF-8"%>
 <%@ page isThreadSafe="false" %>

<%@page import="org.json.JSONObject"%>
<%@page import="org.json.JSONException"%>
<%@page import="org.json.JSONArray"%>
<%@page import="org.json.JSONString"%>

 <%  response.setHeader("Access-Control-Allow-Origin", "*");  
 	// response.setHeader("Access-Control-Allow-Methods"," GET, POST, PATCH, PUT, DELETE, OPTIONS");
	// response.setHeader("Access-Control-Allow-Headers", "Origin, Content-Type, X-Auth-Token");
  
	 
	 %>
 
<%!

String getSizeString(float sizeInBytes)
{
	if(sizeInBytes<1024)
		return sizeInBytes+" Bytes";
	else if(sizeInBytes <1024*1024)
	{
		return sizeInBytes/1024+" KB";
	}
	else
	{
		return sizeInBytes/1024*1024+" MB";
	}
}
 

%>
<%


String name=null;
String Cust_id=null;
String Cont_id=null;
int MAXSIZE=1024*1024*1;

String message;
JSONObject json = new JSONObject();


String path=getServletConfig().getServletContext().getRealPath("/ui/drop/uploads");
String DOMAIN_URL="http://cms.revotas.com/cms/ui/drop/uploads";


FileItemFactory factory1 = new DiskFileItemFactory();
ServletFileUpload upload2 = new ServletFileUpload( factory1 );
List<FileItem> uploadItems = upload2.parseRequest( request );

for( FileItem uploadItem : uploadItems )
{
	 
	
	if( uploadItem.isFormField() ){
		
		
		if(uploadItem.getFieldName().equals("cust_id"))  {   
		  Cust_id=uploadItem.getString();
		 
        }
	  
		if(uploadItem.getFieldName().equals("cont_id"))  {   
		  Cont_id=uploadItem.getString();
        }
	 
	}else{

       	name = uploadItem.getName();
   		long  SIZE=uploadItem.getSize();
   		
   	 	String contentType = uploadItem.getContentType();
	  	
		String[] UZANTI=contentType.split("/");
   		
   		if(UZANTI[1].equals("png") || UZANTI[1].equals("jpg") || UZANTI[1].equals("jpeg")|| UZANTI[1].equals("gif")  ){
   			
   			 if(SIZE<MAXSIZE){
   				 
   				    
		   		 	  String AnaPath=path+"\\"+Cust_id;
		   			  String AltPath=path+"\\"+Cust_id+"\\"+Cont_id;
		   			   
		   			  File AltKlasor = new File(AltPath);
		   	  	 	  File AnaKlasor = new File(AnaPath);	
		   	  
		   	  	 	  if(AnaKlasor.exists()){
		   	  	 		  
		   	  	 			if(AltKlasor.exists()){
		   	  	 				 	
				      			Date now = new Date();
				 				SimpleDateFormat format = new SimpleDateFormat("dMyyyy-HHmmss");
					           	
					       		File fNew= new File(AltPath+File.separator,format.format(now)+"."+UZANTI[1]);
					       		uploadItem.write(fNew);
				       			
				       			String img_url=DOMAIN_URL+"/"+Cust_id+"/"+Cont_id+"/"+format.format(now)+"."+UZANTI[1];
				       		  	
						        json.put("status_code", "200");
			 		  	    	json.put("status_txt", "OK");

						       					JSONObject data = new JSONObject();
						         				data.put("img_name", format.format(now)+"."+UZANTI[1]);
						         				data.put("img_url", img_url);
				       	 						data.put("thumb_url", img_url);
													
						        json.put("data", data);

						       	message = json.toString();
						      
				       			out.print(message);
			 		  	   		out.flush();
				      			
		   	  	 				
		   	  	 			}else{
					   	  	 			File altolustur = new File(AltPath);
						      			altolustur.mkdir();
						      			
						      			Date now = new Date();
						 				SimpleDateFormat format = new SimpleDateFormat("dMyyyy-HHmmss");
							           	
							       		File fNew= new File(AltPath+File.separator,format.format(now)+"."+UZANTI[1]);
							       		uploadItem.write(fNew);
						       			
						       			String img_url=DOMAIN_URL+"/"+Cust_id+"/"+Cont_id+"/"+format.format(now)+"."+UZANTI[1];
						       		 
						       		 
								        json.put("status_code", "200");
					 		  	    	json.put("status_txt", "OK");
			
											JSONObject data = new JSONObject();
											data.put("img_name", format.format(now)+"."+UZANTI[1]);
											data.put("img_url", img_url);
											data.put("thumb_url", img_url);
								        json.put("data", data);
			
								       	message = json.toString();
								      
						       			out.print(message);
					 		  	   		out.flush();
		   	  	 				
		   	  	 				
		   	  	 			}
		   	  		 
		   	  	 	  }else{
				   	  	 	File anaolustur = new File(AnaPath);
			      			anaolustur.mkdir();
			      			  
			      			File altolustur = new File(AltPath);
			      			altolustur.mkdir();
			      			 	
					      			Date now = new Date();
					 				SimpleDateFormat format = new SimpleDateFormat("dMyyyy-HHmmss");
						           	
						       		File fNew= new File(AltPath+File.separator,format.format(now)+"."+UZANTI[1]);
						       		uploadItem.write(fNew);
					       			
					       			String img_url=DOMAIN_URL+"/"+Cust_id+"/"+Cont_id+"/"+format.format(now)+"."+UZANTI[1];
					     	       	
							        json.put("status_code", "200");
				 		  	    	json.put("status_txt", "OK");
		
							       					JSONObject data = new JSONObject();
							         				data.put("img_name", format.format(now)+"."+UZANTI[1]);
							         				data.put("img_url", img_url);
					       	 						data.put("thumb_url", img_url);
							        json.put("data", data);
		
							       	message = json.toString();
							      
					       			out.print(message);
				 		  	   		out.flush();
					   		  
		   	  	 		  
		   	  	 	  }
   			 		
   						
   				
   			}else{
   				
   				//out.println("Dosya Boyutu Buyuk");
   				json.put("status_code", "403");
  		  	    json.put("status_txt", "Dosya Boyutu Buyuk");
  		  	    
  		  		 message = json.toString();
			      
     			 out.print(message);
  		  	     out.flush();
   				
   			}
   			 
   		 }else{
   			 
   			// out.println("Uzanti Dogru Degil");
   			 
   				json.put("status_code", "403");
		  	    json.put("status_txt", "Uzanti Dogru Degil");
		  	    
		  		  message = json.toString();
		      
 			 	out.print(message);
		  	    out.flush();
				
   		 }
		
	}
}
/*
if (ServletFileUpload.isMultipartContent(request)){
		try {
		 
		  int MAXSIZE=1024*1024*1;
		  String DOMAIN_URL="http://localhost:9090/drop/uploads";
		  
	 	  String AnaPath=path+"\\"+Cust_id;
		  String AltPath=path+"\\"+Cust_id+"\\"+Cont_id;
		   
		  File AltKlasor = new File(AltPath);
  	 	  File AnaKlasor = new File(AnaPath);
  	 
  	if(AnaKlasor.exists()){
  		 		 out.println("ANA DOSYA VAR");
			      		if(AltKlasor.exists()){
			      	 	  // DOSYA TASIMA YOLLARI
			      		   out.println("ALT DOSYA VAR");
			      	 	  
			      	 	  
			      		  DiskFileItemFactory factory = new DiskFileItemFactory();
			      		  factory.setRepository(new File(AltPath));
			      		  ServletFileUpload upload = new ServletFileUpload(factory);
			      		  
			      		  upload.setFileSizeMax(1024*1024*1);//1MB
			      		  List<FileItem> items = upload.parseRequest(request);
			      		  
						  Iterator<FileItem> itr =items.iterator();

			      		  while(itr.hasNext()){	
			      		  	
			      			  FileItem fileItem = itr.next();
			      		  	   
			      		  	  String contentType = fileItem.getContentType();
			      		  	 out.println(contentType);
			      			  String[] UZANTI=contentType.split("/");
			      			  
			      		    if(!fileItem.isFormField())   {
			      		    	
			      		         	name = fileItem.getName();
			      		     		long  SIZE=fileItem.getSize();
			      		     	 
			      		     	 
						      			     	 if(UZANTI[1].equals("png") || UZANTI[1].equals("jpg") || UZANTI[1].equals("jpeg")|| UZANTI[1].equals("gif")  ){
						      			       		
										      	    		       		if(SIZE<MAXSIZE){
										      	    		       			
										      	    		       			 
										      	    		       		 Date now = new Date();
										      	    	 				 SimpleDateFormat format = new SimpleDateFormat("dMyyyy-HHmm");
										      	    		           	
										      	    		       		File fNew= new File(AltPath+File.separator,format.format(now)+"."+UZANTI[1]);
										      			       			fileItem.write(fNew);
										      			       			
										      			       			String img_url=DOMAIN_URL+"/"+Cust_id+"/"+Cont_id+"/"+format.format(now)+"."+UZANTI[1];
										      			       		 
										      			       			String message;
												      			       	JSONObject json = new JSONObject();
												      			       	
												      			        json.put("status_code", "200");
											      	    		  	    json.put("status_txt", "OK");
									 
												      			       					JSONObject data = new JSONObject();
												      			         				data.put("img_name", format.format(now)+"."+UZANTI[1]);
												      			         				data.put("img_url", img_url);
											    			       	 					data.put("thumb_url", img_url);
												      			       	
							  			       	 								//array.add(data);
							  			       	 							
												      			        json.put("data", data);
									
												      			       	message = json.toString();
												      			      
										      			       			out.print(message);
											      	    		  	    out.flush();
										      			       			
										      			       	 		  
										      	    		       				
										      	    		       		}else{
										      	    		       			 
										      	    		       			JSONObject json = new JSONObject();
												      	    		       	json.put("status_code", "200");
												      	    		  	    json.put("status_txt", "_ERROR_MSG_");
												      	    		  	    
												      	    		  		String message = json.toString();
													      			      
										      			       				out.print(message);
												      	    		  	    out.flush();
										      	    		       			
										      	    		       			
										      	    		       		
										      	    		       		}
						      			       		
						      			       		
						      			       	}else{
						      			       		
								      			       	JSONObject json = new JSONObject();
							      	    		       	json.put("status_code", "200");
							      	    		  	    json.put("status_txt", "_ERROR_MSG_");
							      	    		  	    
							      	    		  		String message = json.toString();
								      			      
					      			       				out.print(message);
							      	    		  	    out.flush();
								      			       		
						      			       		 
						      			       		
						      			       	}
			      		       	
			      		        
			      		     	
			      		      }else {
			      		    	 
			      		    	JSONObject json = new JSONObject();
	      	    		       	json.put("status_code", "200");
	      	    		  	    json.put("status_txt", "_ERROR_MSG_");
	      	    		  	    
	      	    		  		String message = json.toString();
		      			      
			       				out.print(message);
	      	    		  	    out.flush();
			      		    	  
			      		    	  
			      		       }
			      		  }

			      		 // END DOSYA TASIMA YOLLARI
			      			
			      			
			    		 	  
			    		  }else{
			    			  
			    			  // ALT KLASOR YOK 
			    			  
			    			  
			    			  File altolustur = new File(AltPath);
			      			  altolustur.mkdir();
			      			 
			      			  
			      			  
			      			// DOSYA TASIMA YOLLARI
			      			  
				      		  DiskFileItemFactory factory = new DiskFileItemFactory();
				      		  factory.setRepository(new File(AltPath));
				      		  ServletFileUpload upload = new ServletFileUpload(factory);
				      		  
				      		  upload.setFileSizeMax(1024*1024*1);//1MB
				      		  List<FileItem> items = upload.parseRequest(request);
				      		  
				        
				        	  Iterator<FileItem> itr =items.iterator();
				       
				      		  while(itr.hasNext()){	
				      		  	
				      			  FileItem fileItem = itr.next();
				      		  	   
				      		  	  String contentType = fileItem.getContentType();
				      		 
				      			  String[] UZANTI=contentType.split("/");
				      			  
				      		    if(!fileItem.isFormField())   {
				      		    	
				      		         	name = fileItem.getName();
				      		     		long  SIZE=fileItem.getSize();
				      		     	 
				      		     	 
					      		     	 if(UZANTI[1].equals("png") || UZANTI[1].equals("jpg") || UZANTI[1].equals("jpeg")|| UZANTI[1].equals("gif")  ){
					      		       		
						      		       		if(SIZE<MAXSIZE){
						      		       			
						      		       			 
						      		       		 Date now = new Date();
						      	 				 SimpleDateFormat format = new SimpleDateFormat("dMyyyy-HHmm");
						      		           	
						      		       		File fNew= new File(AltPath+File.separator,
						      		       			format.format(now)+"."+UZANTI[1]);
					      		       			fileItem.write(fNew);
					      		       			
						      		       		String img_url=DOMAIN_URL+"/"+Cust_id+"/"+Cont_id+"/"+format.format(now)+"."+UZANTI[1];
					      			       		 
				      			       			String message;
						      			       	JSONObject json = new JSONObject();
						      			       	
						      			        json.put("status_code", "200");
					      	    		  	    json.put("status_txt", "OK");
			 
						      			       					JSONObject data = new JSONObject();
						      			         				data.put("img_name", format.format(now)+"."+UZANTI[1]);
						      			         				data.put("img_url", img_url);
					    			       	 					data.put("thumb_url", img_url);
						      			       	 
	    			       	 							
						      			        json.put("data", data);
			
						      			       	message = json.toString();
						      			      
				      			       			out.print(message);
					      	    		  	    out.flush();
				      			       			 
						      		      	 			
						      		       		}else{
								      		       		JSONObject json = new JSONObject();
							      	    		       	json.put("status_code", "200");
							      	    		  	    json.put("status_txt", "_ERROR_MSG_");
							      	    		  	    
							      	    		  		String message = json.toString();
								      			      
						  			       				out.print(message);
							      	    		  	    out.flush();
						      		       		}
					      		       		
					      		       		
					      		       	}else{
					      		       		
							      		       	JSONObject json = new JSONObject();
					      	    		       	json.put("status_code", "200");
					      	    		  	    json.put("status_txt", "_ERROR_MSG_");
					      	    		  	    
					      	    		  		String message = json.toString();
						      			      
				  			       				out.print(message);
					      	    		  	    out.flush();
					      		       		
					      		       	}
				      		       	
				      		        
				      		     	
				      		      }
				      		      else {
				      		    	  
						      		    	JSONObject json = new JSONObject();
				      	    		       	json.put("status_code", "200");
				      	    		  	    json.put("status_txt", "_ERROR_MSG_");
				      	    		  	    
				      	    		  		String message = json.toString();
					      			      
			  			       				out.print(message);
				      	    		  	    out.flush();
				      		    	  
				      		    	  
				      		       }
				      		  }
	        
				      		 // END DOSYA TASIMA YOLLARI
			    			  
			    			  
			    		 	  
			    			  
			    			  
			    			  
			    			  
			    		  }
  	 	 
  	  }else{ 
				      		  	   
				      			  
				      			  File anaolustur = new File(AnaPath);
				      			  anaolustur.mkdir();
				      			  
				      			  File altolustur = new File(AltPath);
				      			  altolustur.mkdir();
				      			   
				      			// DOSYA TASIMA YOLLARI
				      			  
					      		  DiskFileItemFactory factory = new DiskFileItemFactory();
					      		  factory.setRepository(new File(AltPath));
					      		  ServletFileUpload upload = new ServletFileUpload(factory);
					      		  
					      		  upload.setFileSizeMax(1024*1024*1);//1MB
					      		  List<FileItem> items = upload.parseRequest(request);
					      		  
					         	  Iterator<FileItem> itr =items.iterator();
					       
					      		  while(itr.hasNext()){	
					      		  	
					      			  FileItem fileItem = itr.next();
					      		  	   
					      		  	  String contentType = fileItem.getContentType();
					      		 
					      			  String[] UZANTI=contentType.split("/");
					      			  
					      		    if(!fileItem.isFormField())   {
					      		    	
					      		         	name = fileItem.getName();
					      		     		long  SIZE=fileItem.getSize();
					      		     	 
					      		     	 
						      		     	 if(UZANTI[1].equals("png") || UZANTI[1].equals("jpg") || UZANTI[1].equals("jpeg")|| UZANTI[1].equals("gif")  ){
						      		       		
							      		       		if(SIZE<MAXSIZE){
							      		       			
							      		       			 
							      		       		 Date now = new Date();
							      	 				 SimpleDateFormat format = new SimpleDateFormat("dMyyyy-HHmm");
							      		           	
							      		       		File fNew= new File(AltPath+File.separator,
							      		       			format.format(now)+"."+UZANTI[1]);
						      		       			fileItem.write(fNew);
						      		       			
							      		       		String img_url=DOMAIN_URL+"/"+Cust_id+"/"+Cont_id+"/"+format.format(now)+"."+UZANTI[1];
						      			       		 
					      			       			String message;
							      			       	JSONObject json = new JSONObject();
							      			       	
							      			        json.put("status_code", "200");
						      	    		  	    json.put("status_txt", "OK");
				 
							      			       					JSONObject data = new JSONObject();
							      			         				data.put("img_name", format.format(now)+"."+UZANTI[1]);
							      			         				data.put("img_url", img_url);
						    			       	 					data.put("thumb_url", img_url);
							      			       	 
		    			       	 							
							      			        json.put("data", data);
				
							      			       	message = json.toString();
							      			      
					      			       			out.print(message);
						      	    		  	    out.flush();
					      			       			 
					      			       			
							      		       			
							      		       		}else{
									      		       		JSONObject json = new JSONObject();
								      	    		       	json.put("status_code", "200");
								      	    		  	    json.put("status_txt", "_ERROR_MSG_");
								      	    		  	    
								      	    		  		String message = json.toString();
									      			      
							  			       				out.print(message);
								      	    		  	    out.flush();
							      		       		
							      		       		}
						      		       		
						      		       		
						      		       	}else{
						      		       		
								      		       	JSONObject json = new JSONObject();
						      	    		       	json.put("status_code", "200");
						      	    		  	    json.put("status_txt", "_ERROR_MSG_");
						      	    		  	    
						      	    		  		String message = json.toString();
							      			      
					  			       				out.print(message);
						      	    		  	    out.flush();
								      		       		
						      		       	}
					      		       	
					      		        
					      		     	
					      		      }
					      		      else {
							      		    	JSONObject json = new JSONObject();
					      	    		       	json.put("status_code", "200");
					      	    		  	    json.put("status_txt", "_ERROR_MSG_");
					      	    		  	    
					      	    		  		String message = json.toString();
						      			      
				  			       				out.print(message);
					      	    		  	    out.flush();
					      		       }
					      		  }
		        
					      		 // END DOSYA TASIMA YOLLARI
				      		 	  
				      		   
  	 	  
  	      
  	 }
		  
		 	 
		  

	} catch (Exception ex) {
			JSONObject json = new JSONObject();
	       	json.put("status_code", "200");
	  	    json.put("status_txt", "_ERROR_MSG_");
	  	    
	  		String message = json.toString();
	      
			out.print(message);
	  	    out.flush();
	}
	
}
*/
%>

    