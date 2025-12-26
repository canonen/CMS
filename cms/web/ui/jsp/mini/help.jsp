<%@ page 
          language="java"
          import="org.apache.log4j.*"
          import="com.britemoon.*"
          import="com.britemoon.cps.*"
          import="com.britemoon.cps.ctm.*"
          import="java.util.*"
          import="java.sql.*" 
          contentType="text/html;charset=UTF-8"
%>
<%@ include file="header.jsp"%>
<%@ include file="../wvalidator.jsp"%>
<div id="help-featured">
	
	<div class="help-section">
		<img src="images/1340180041_Help.png" class="help-icon">
		<div class="help-fbox">
			<div class="help-headers">Sıkça Sorulan Sorular</div>
			<p>
				Burada en çok sorulan bazı soruların yanıtlarını bulacaksınız.
 Bize ticket yaratmadan önce sorunuz ya da görüşünüzün yanıtı için alt tarafta yer alan SSS listesini ziyaret etmenizi öneririz.
<br>
			<ul>
				<li>Sıkça Sorulan Sorular</li>
				<li>Yardım Dokümanı</li>
				<li>Yardım Video</li>
			</ul>
			</p>
			<div><a href="http://www.revotas.com/support/open.php?cust_id=XXXX"> <span></span>Gözat</a></div>
		</div>
		<div style="clear:both;"></div>
	</div>
	
	<div class="help-section">
		<img src="images/1340180093_call-group.png" class="help-icon">
		<div class="help-fbox">
			<div class="help-headers">Teknik Destek</div>
			<p>
				Revotas olarak teknik destek ile iletişim kurabilmeniz için aşağıdaki linkten bizimle ileşime geçebilirsiniz.</br>
				Not: Teknik bir sorun bildirmek istiyorsanız bize kampanya, içerik veya rapor isimlerini göndermeniz yardımcı olacaktır.</br>
				<br>24 saat içerisinde teknik ekibiz sizinle iletişime geçecektir.

			</p>
			<div><a href="http://www.revotas.com/support/open.php?cust_id=<%=cust.s_cust_id%>" target="_blank"><span></span> Talep Yarat</a></div>
		</div>
		<div style="clear:both;"></div>
	</div>
	
	<div class="help-section">
		<img src="images/1340180026_add1-.png" class="help-icon">
		<div class="help-fbox">
			<div class="help-headers">Revotas Basic</div>
			<p>
				Revotas Basic'da mini ara yüzüyle gerçekletirmek isteyip ancak gerçekleştiremediğiniz tüm fonksiyonlara ulaşabilirsiniz.			
			</p>
			<ul>
				<li>Detaylı raporlama</li>
				<li>Güçlü segmantasyon</li>
				<li>Moduler Yapı</li>
				<li>Kolay kullanım ve kullanıcı dostu arayüz</li>
			</ul>
			<div><a target="_blank" href="http://revotas.com/Bize-Ulasin/Bilgi"><span></span> Özellikler</a></div>
		</div>
		<div style="clear:both;"></div>
	</div>
	
	<div style="clear:both;"></div>
</div>

</body>
</html>