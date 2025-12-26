<%@ page 
          language="java"
          import="org.apache.log4j.*"
          import="com.britemoon.*"
          import="com.britemoon.cps.*"
          import="com.britemoon.cps.ctm.*"
          import="java.util.*"
          import="java.sql.*" 
          errorPage="../../error_page.jsp"
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
				Burada en çok sorulan bazı soruların yanıtlarını bulacaksınız. Bize formunuzu iletmeden önce sorunuz ya da görüşünüzün yanıtı için alt tarafta yer alan SSS listesini ziyaret etmenizi öneririz.
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
				24 saat içerisinde teknik ekibiz sizinle iletişime geçecektir.

			</p>
			<div><a href="http://www.revotas.com/support/open.php?cust_id=<%=cust.s_cust_id%>" target="_blank"><span></span> Talep Yarat</a></div>
		</div>
		<div style="clear:both;"></div>
	</div>
	
	<div class="help-section">
		<img src="images/1340180026_add1-.png" class="help-icon">
		<div class="help-fbox">
			<div class="help-headers">Revotas Plus</div>
			<p>
				Revotas Plus'da Revotas Mail ara yüzüyle gerçekletirmek isteyip ancak gerçekleştiremediğiniz tüm fonksiyonlara ulaşabilirsiniz.			
			</p>
			<p>
				Revotas Plus sağladığı yüksek geri dönüşüm ve ölçülebilirliği sayesinde hedef kitleniz ile doğru zamanda doğru iletişim kurmanızı sağlayan gelişmiş bir platformdur. 
				Tüm CRM, veritabanı yönetimi ve çok kanallı pazarlama ihtiyaçlarınızda size gereken altyapı desteğini sağlar.			
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

<div id="faq">
	<h1>Sıkça Sorulan Sorular</h1>
	
	<div class="faq-cat">
	<h2>Hesap Özeti</h2>
<ul>
	<li>
		<a class="faq-item" href="#" onclick="showFaq(this);">
			Toplam, Aktif, Geri Dönen, Listeden Çıkan, Okuyan, Okumayan sayıları ne anlama geliyor ?</a>
		<p style="display:none">
			
			Hesap özeti Sayfası, sisteminize ait  genel bilgilerin bulunduğu  sayfadır. Bu alan üzerinde sisteminizde tanımlı email adreslerin sayısını, listenizden çıkan kişiler gibi genel bilgilere ulaşabilirsiniz.<br><br>

			Toplam ne anlama geliyor ?<br>
			Sisteminizde tanımlı email adreslerinin sayısıdır.<br><br>

			Aktif ne anlama geliyor ?<br> 
			Sisteminizde tanımlı ve kullanılabilir [geçerli-aktif] gönderim yapabileceğiniz email sayısıdır.<br><br>

			Geri dönen ne anlama geliyor ? <br> 
			Gönderim yapılmış ve sistem tarafında geçersiz olduğu belirlenen inactive – pasif email adresleridir. Bu adreslere bir daha gönderim yapılmaz.<br><br>

			Listeden Çıkan ne anlama geliyor ?  <br>
			Listenizden çıkmış  email listesidir. Kişi listeden çıkmak istiyorum linkine tıkladığında otomatik olarak sistemde pasif duruma getirilir ve bir daha gönderim yapılmaz.<br><br>

			Okuyan ne anlama geliyor ? <br> 
			Gönderilerinizi 1 veya 1 den fazla açmış kişilerin listesidir. Bu sayı tüm gönderilerinizi kapsamaktadır.  <br><br>

			Okumayan ne anlama geliyor ?  <br>
			Gönderilerinizi hiç açmamış ve tıklamamış kişilerin sayısıdır. Bu sayı tüm gönderilerinizi kapsamaktadır.  

		</p>
	</li>
	<li>
		<a class="faq-item" href="#" onclick="showFaq(this);">
			Kredi ne anlama geliyor ?</a>
		<p style="display:none">
			Gönderim yapabilmeniz için sisteminize tanımlanan kontör miktarıdır. <br>

			Örneğin; 5.000 krediniz mevcut, sisteminizden 5.000 adet email adresine gönderim yapabilirsiniz. Total email sayısından bağımsız olarak çalışmaktadır. 10.000 email adresiniz var ve 5.000 krediniz var gönderimi başlattığınızda gönderi 5.000 e ulaştığında kampanya otomatik olarak sonlandırılır.<br><br>

			Toplam kredi ne anlama geliyor ? <br> 
			Sisteminize tanımlanmış  kontör miktarıdır.<br><br>

			Örneğin; 5.000 krediniz mevcut, sisteminizden 5.000 adet email adresine gönderim yapabilirsiniz.<br><br>

			Harcanan kredi ne anlama geliyor ?<br>
			Sisteminizden gönderim yapılan email sayısıdır. Siz gönderim yaptıkça toplam kredi üzerinden düşülecektir.<br><br>

			Kalan kredi ne anlama geliyor ?  <br>
			Toplam kredi-kontör üzerinden düşülen kredilerin hesap özetidir. Siz gönderim yaptıkça kalan kredinizi bu alandan takip edebilirsiniz.<br><br>
			
			Kredi satın al ne anlama geliyor ? <br>
			Yeni kontör-kredi satın almak için kullanılır. Kredi satın aldııınızda hesabınıza yeni kontörler yüklenir ve gönderim yapmaya devam edebilirsiniz. Eğer kredi sıfır sayısına ulaşmış ise sisteminizden gönderim yapamazsınız. Yeni kredi almanız gerekir.
		</p>
	</li>
	<li>
		<a class="faq-item" href="#" onclick="showFaq(this);">
			Sistemde bulunan kullancıların kimler olduklarını görüp,  sistemden masaüstüne nasıl alabilirim ?</a>
		<p style="display:none">
			Sistemde bulunan kullanıcıları (okuyan,tıklayan) kimler olduğunu görebilir veya masaüstüne alabilir miyim ?
			Bu özelliklerden faydalanabilmeniz için Revotas Plus özelliıine geçmeniz gerekiyor.

		</p>
	</li>
</ul>
		<h2>Kampanyalar</h2>
		<ul>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Kampanya ne anlama geliyor ?</a>
				<p style="display:none">
					Bir firmanın ürün ve hizmetleriyle ilgili bilgi ve özelliklerin tüketiciye email yolu ile aktarılmasıdır.
				</p>
			</li>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Nasıl yeni bir kampanya yaratabilirim ?</a>
				<p style="display:none">
					Kampanyalar sekmesine tıklayın. Yeni kampanya butonunu tıklayın. Kampanyanıza isim verin ve sistem adımlarını sırasıyla takip edin. 
				</p>
			</li>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Gönderen adını değiştirmek istiyorum, nasıl yapabilirim ?</a>
				<p style="display:none">
					Bu özelliklerden faydalanabilmeniz için Revotas Plus özelliğine geçmeniz gerekiyor.
				</p>
			</li>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Cevap email adresini (Reply to) değiştirmek istiyorum, nasıl yapabilirim ?</a>
				<p style="display:none">
					Bu özelliklerden faydalanabilmeniz için Revotas Plus özelliğine geçmeniz gerekiyor.
				</p>
			</li>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Hedef grup ne anlama geliyor ?</a>
				<p style="display:none">
					Kampanya gönderimi yapılabilir email listesidir.
				</p>
			</li>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Başka hedef gruplar yaratalabilir miyim ?</a>
				<p style="display:none">
					Okuyan ve okumayan isimli 2 hedef grup kullanabilirsiniz. Daha detaylı grup oluşturmak için Revotas Plus özelliıine geçmeniz gerekiyor.
				</p>
			</li>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Email başlığı nasıl özelleştiriliyor ?</a>
				<p style="display:none">
					Sistemde isme özel özelleştirme yapabilirsiniz. Örneğin: Merhaba ESRA AKSU. Merhaba alanı sabittir. Farklı kelimeler kullanmak için Revotas Plus özelliğine geçmeniz gerekiyor.
				</p>
			</li>
		</ul>
		<h2>Raporlar</h2>
		<ul>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Ulaşan, ulaşmayan, okuyan, listeden çıkan sayıları ne anlama geliyor ?</a>
				<p style="display:none">
					Ulaşan, email teslim edilebilen çalışır durumdaki email adresleridir.<br>
					Ulaşmayan, çeşitli nedenlere bağlı olarak email ulaştırılamamış email adresleridir. (domain hatalı, username hatalı, inbox dolu, hesabı geçiçi pasif vb.) bunların detaylarını görmek için Revotas Plus özelliğine geçmeniz gerekiyor.<br>
					Okuyan, Email’i açmış kişilerin listesidir.<br>
					Listeden çıkan, Email almak istemeyen kişilerin listesidir. Unsubscribe linkine tıklayan kişiler otomatik olarak listenizden çıkarılır ve bir daha email gönderilmez.

				</p>
			</li>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Bu sayılara ait kişilerin kim olduklarını nasil öğrenebilirim ?</a>
				<p style="display:none">
					Bu özelliklerden faydalanabilmeniz için Revotas Plus özelliğine geçmeniz gerekiyor. 
				</p>
			</li>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Bu kullanıcıları sistemden nasıl masaüstüne alabilirim ?</a>
				<p style="display:none">
					Bu özelliklerden faydalanabilmeniz için Revotas Plus özelliğine geçmeniz gerekiyor.
				</p>
			</li>
		</ul>
		<h2>Listeden Çıkmak için</h2>
		<ul>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Neden listeden çıkma (unsubscribe) linki kullanmak zorundayım ?</a>
				<p style="display:none">
					Listeden çıkmak isteyen kişilere yeniden email göndermek spam yaptığınız anlamına gelir ve şikâyet alırsınız. Aynı zamanda bu bir yasal zorunluluktur.
				</p>
			</li>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Açık adresim neden Unsubcribe-listeden çıkma bölümünde bulunuyor ?</a>
				<p style="display:none">
					Bu bir yasal zorunluluktur. Birçok ISP emailinizde unsub mesajının varlığını ve şirket bilgilerinizi kontrol ederek emaillerinizi kabul etmektedir.
				</p>
			</li>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Listeden çıkan kullanıcılar sistemden siliniyor mu ?</a>
				<p style="display:none">
					Listeden çıkan kullanıcılar sistemde otomatik olarak inactive konuma getirilir ve bir daha email gönderim yapılmaz. Sistemden silinmezler sadece statüleri değişir.
				</p>
			</li>
			<li>
				<a class="faq-item" href="#" onclick="showFaq(this);">
					Bu kullanıcıları sistemden nasıl alabilirim ?</a>
				<p style="display:none">
					Bu özelliklerden faydalanabilmeniz için Revotas Plus özelliğine geçmeniz gerekiyor.
				</p>
			</li>
		</ul>
		
	</div>
</div>

<script type="text/javascript">
	
    $(".faq-cat a").click(function() {
	  $(this).next().toggle();
	});

</script>
</body>
</html>