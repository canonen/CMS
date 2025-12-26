<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<%@ page import="java.net.*" %>
<%@ page import="java.io.*" %>
<%@ page import="java.util.*" %>
<%@ page import="com.google.common.collect.*" %>
<%
	Multimap<Integer, String> cityTown = ArrayListMultimap.create();
	
	cityTown.put(1,"ALADAĞ");
	cityTown.put(1,"CEYHAN");
	cityTown.put(1,"FEKE");
	cityTown.put(1,"KARAİSALI");
	cityTown.put(1,"KOZAN");
	cityTown.put(1,"POZANTI");
	cityTown.put(1,"SAİMBEYLİ");
	cityTown.put(1,"SEYHAN");
	cityTown.put(1,"YUMURTALIK");
	cityTown.put(1,"YÜREĞİR");
	cityTown.put(2,"ANAMUR");
	cityTown.put(2,"BOZYAZI");
	cityTown.put(2,"ÇAMLIYAYLA");
	cityTown.put(2,"ERDEMLİ");
	cityTown.put(2,"GÜLNAR");
	cityTown.put(2,"MERKEZ");
	cityTown.put(2,"MUT");
	cityTown.put(2,"SİLİFKE");
	cityTown.put(2,"TARSUS");
	cityTown.put(3,"BAHÇE");
	cityTown.put(3,"KADİRLİ");
	cityTown.put(3,"MERKEZ");
	cityTown.put(4,"ALTINDAĞ");
	cityTown.put(4,"AYAŞ");
	cityTown.put(4,"BALA");
	cityTown.put(4,"BEYPAZARI");
	cityTown.put(4,"ÇAMLIDERE");
	cityTown.put(4,"ÇANKAYA");
	cityTown.put(4,"ÇUBUK");
	cityTown.put(4,"ETİMESGUT");
	cityTown.put(4,"HAYMANA");
	cityTown.put(4,"KALECİK");
	cityTown.put(4,"KEÇİÖREN");
	cityTown.put(4,"KIZILCAHAMAM");
	cityTown.put(4,"MAMAK");
	cityTown.put(4,"NALLIHAN");
	cityTown.put(4,"POLATLI");
	cityTown.put(4,"SİNCAN");
	cityTown.put(4,"ŞEREFLİKOÇHİSAR");
	cityTown.put(4,"YENİMAHALLE");
	cityTown.put(5,"DÖRTDİVAN");
	cityTown.put(5,"GEREDE");
	cityTown.put(5,"GÖYNÜK");
	cityTown.put(5,"MENGEN");
	cityTown.put(5,"MERKEZ");
	cityTown.put(5,"MUDURNU");
	cityTown.put(5,"YENİÇAĞA");
	cityTown.put(6,"ATKARACALAR");
	cityTown.put(6,"BAYRAMÖREN");
	cityTown.put(6,"ÇERKEŞ");
	cityTown.put(6,"ELDİVAN");
	cityTown.put(6,"ILGAZ");
	cityTown.put(6,"KURŞUNLU");
	cityTown.put(6,"MERKEZ");
	cityTown.put(6,"ORTA");
	cityTown.put(6,"ŞABANÖZÜ");
	cityTown.put(6,"YAPRAKLI");
	cityTown.put(7,"AKÇAKOCA");
	cityTown.put(7,"ÇİLİMLİ");
	cityTown.put(7,"MERKEZ");
	cityTown.put(7,"YIĞILCA");
	cityTown.put(8,"KARAKEÇİLİ");
	cityTown.put(8,"KESKİN");
	cityTown.put(8,"MERKEZ");
	cityTown.put(8,"SULAKYURT");
	cityTown.put(9,"AKSEKİ");
	cityTown.put(9,"ALANYA");
	cityTown.put(9,"ELMALI");
	cityTown.put(9,"FİNİKE");
	cityTown.put(9,"GAZİPAŞA");
	cityTown.put(9,"İBRADİ");
	cityTown.put(9,"KALE");
	cityTown.put(9,"KAŞ");
	cityTown.put(9,"KORKUTELİ");
	cityTown.put(9,"KUMLUCA");
	cityTown.put(9,"MANAVGAT");
	cityTown.put(9,"MERKEZ");
	cityTown.put(9,"SERİK");
	cityTown.put(10,"AĞLASUN");
	cityTown.put(10,"BUCAK");
	cityTown.put(10,"ÇAVDIR");
	cityTown.put(10,"GÖLHİSAR");
	cityTown.put(10,"KARAMANLI");
	cityTown.put(10,"MERKEZ");
	cityTown.put(10,"TEFENNİ");
	cityTown.put(10,"YEŞİLOVA");
	cityTown.put(11,"AKSU");
	cityTown.put(11,"ATABEY");
	cityTown.put(11,"EĞİRDİR");
	cityTown.put(11,"GELENDOST");
	cityTown.put(11,"GÖNEN");
	cityTown.put(11,"KEÇİBORLU");
	cityTown.put(11,"MERKEZ");
	cityTown.put(11,"SARKIKARAAĞAÇ");
	cityTown.put(11,"SENİRKENT");
	cityTown.put(11,"SÜTÇÜLER");
	cityTown.put(11,"ULUBORLU");
	cityTown.put(11,"YALVAÇ");
	cityTown.put(12,"BOZDOĞAN");
	cityTown.put(12,"BUHARKENT");
	cityTown.put(12,"ÇİNE");
	cityTown.put(12,"GERMENCİK");
	cityTown.put(12,"İNCİRLİOVA");
	cityTown.put(12,"KARACASU");
	cityTown.put(12,"KARPUZLU");
	cityTown.put(12,"KOÇARLI");
	cityTown.put(12,"KÖŞK");
	cityTown.put(12,"KUŞADASI");
	cityTown.put(12,"KUYUCAK");
	cityTown.put(12,"MERKEZ");
	cityTown.put(12,"NAZİLLİ");
	cityTown.put(12,"SÖKE");
	cityTown.put(12,"SULTANHİSAR");
	cityTown.put(12,"YENİHİSAR");
	cityTown.put(12,"YENİPAZAR");
	cityTown.put(13,"ACIPAYAM");
	cityTown.put(13,"BABADAĞ");
	cityTown.put(13,"BULDAN");
	cityTown.put(13,"ÇAL");
	cityTown.put(13,"ÇARDAK");
	cityTown.put(13,"ÇİVRİL");
	cityTown.put(13,"GÜNEY");
	cityTown.put(13,"HONAZ");
	cityTown.put(13,"KALE");
	cityTown.put(13,"MERKEZ");
	cityTown.put(13,"SARAYKÖY");
	cityTown.put(13,"TAVAŞ");
	cityTown.put(14,"BODRUM");
	cityTown.put(14,"DATÇA");
	cityTown.put(14,"FETHİYE");
	cityTown.put(14,"KAVAKLIDERE");
	cityTown.put(14,"KÖYCEGİZ");
	cityTown.put(14,"MARMARİS");
	cityTown.put(14,"MERKEZ");
	cityTown.put(14,"MİLAS");
	cityTown.put(14,"ORTACA");
	cityTown.put(14,"ULA");
	cityTown.put(14,"YATAĞAN");
	cityTown.put(15,"AYVALIK");
	cityTown.put(15,"BALYA");
	cityTown.put(15,"BANDIRMA");
	cityTown.put(15,"BİGADİÇ");
	cityTown.put(15,"BURHANİYE");
	cityTown.put(15,"DURSUNBEY");
	cityTown.put(15,"EDREMİT");
	cityTown.put(15,"ERDEK");
	cityTown.put(15,"GÖMEÇ");
	cityTown.put(15,"GÖNEN");
	cityTown.put(15,"HAVRAN");
	cityTown.put(15,"İVRİNDİ");
	cityTown.put(15,"KEPSUT");
	cityTown.put(15,"MANYAS");
	cityTown.put(15,"MERKEZ");
	cityTown.put(15,"SAVAŞTEPE");
	cityTown.put(15,"SINDIRGI");
	cityTown.put(15,"SUSURLUK");
	cityTown.put(16,"AYVACIK");
	cityTown.put(16,"BAYRAMİÇ");
	cityTown.put(16,"BİGA");
	cityTown.put(16,"BOZCAADA");
	cityTown.put(16,"ÇAN");
	cityTown.put(16,"ECEABAT");
	cityTown.put(16,"EZİNE");
	cityTown.put(16,"GELİBOLU");
	cityTown.put(16,"GÖKCEADA");
	cityTown.put(16,"LAPSEKİ");
	cityTown.put(16,"MERKEZ");
	cityTown.put(16,"YENİCE");
	cityTown.put(17,"ADİLCEVAZ");
	cityTown.put(17,"AHLAT");
	cityTown.put(17,"GÜROYMAK");
	cityTown.put(17,"MERKEZ");
	cityTown.put(17,"MUTKİ");
	cityTown.put(17,"TATVAN");
	cityTown.put(18,"MERKEZ");
	cityTown.put(19,"BULANIK");
	cityTown.put(19,"KORKUT");
	cityTown.put(19,"MALAZGİRT");
	cityTown.put(19,"MERKEZ");
	cityTown.put(20,"AYDINLAR");
	cityTown.put(20,"BAYKAN");
	cityTown.put(20,"ERUH");
	cityTown.put(20,"KURTALAN");
	cityTown.put(20,"MERKEZ");
	cityTown.put(21,"CİZRE");
	cityTown.put(21,"İDİL");
	cityTown.put(21,"MERKEZ");
	cityTown.put(22,"BAŞKALE");
	cityTown.put(22,"ÇALDIRAN");
	cityTown.put(22,"ÇATAK");
	cityTown.put(22,"ERCİŞ");
	cityTown.put(22,"GEVAŞ");
	cityTown.put(22,"GÜRPINAR");
	cityTown.put(22,"MERKEZ");
	cityTown.put(22,"MURADİYE");
	cityTown.put(22,"ÖZALP");
	cityTown.put(23,"BOZHÜYÜK");
	cityTown.put(23,"GÖLPAZARI");
	cityTown.put(23,"MERKEZ");
	cityTown.put(23,"OSMANELİ");
	cityTown.put(23,"PAZARYERİ");
	cityTown.put(23,"SÖGÜT");
	cityTown.put(24,"GEMLİK");
	cityTown.put(24,"GÜRSU");
	cityTown.put(24,"İNEGÖL");
	cityTown.put(24,"İZNİK");
	cityTown.put(24,"KARACABEY");
	cityTown.put(24,"KELEŞ");
	cityTown.put(24,"KESTEL");
	cityTown.put(24,"MUDANYA");
	cityTown.put(24,"MUSTAFAKEMALPAŞA");
	cityTown.put(24,"NİLÜFER");
	cityTown.put(24,"ORHANELİ");
	cityTown.put(24,"ORHANGAZİ");
	cityTown.put(24,"OSMANGAZİ");
	cityTown.put(24,"YENİŞEHİR");
	cityTown.put(24,"YILDIRIM");
	cityTown.put(25,"DERİNCE");
	cityTown.put(25,"GEBZE");
	cityTown.put(25,"GÖLCÜK");
	cityTown.put(25,"KANDIRA");
	cityTown.put(25,"KARAMÜRSEL");
	cityTown.put(25,"MERKEZ");
	cityTown.put(26,"AKYAZI");
	cityTown.put(26,"GEYVE");
	cityTown.put(26,"HENDEK");
	cityTown.put(26,"KARASU");
	cityTown.put(26,"KAYNARCA");
	cityTown.put(26,"MERKEZ");
	cityTown.put(26,"SAPANCA");
	cityTown.put(26,"TARAKLI");
	cityTown.put(27,"ALTINOVA");
	cityTown.put(27,"ARMUTLU");
	cityTown.put(27,"MERKEZ");
	cityTown.put(28,"ADALAR");
	cityTown.put(28,"BAĞCILAR");
	cityTown.put(28,"BAHÇELİEVLER");
	cityTown.put(28,"BAKIRKÖY");
	cityTown.put(28,"BEŞİKTAŞ");
	cityTown.put(28,"BEYKOZ");
	cityTown.put(28,"BEYOĞLU");
	cityTown.put(28,"BÜYÜKÇEKMECE");
	cityTown.put(28,"ÇATALCA");
	cityTown.put(28,"EMİNÖNÜ");
	cityTown.put(28,"ESENLER");
	cityTown.put(28,"EYÜP");
	cityTown.put(28,"FATİH");
	cityTown.put(28,"GAZİOSMANPAŞA");
	cityTown.put(28,"GÜNGÖREN");
	cityTown.put(28,"KADIKÖY");
	cityTown.put(28,"KAĞITHANE");
	cityTown.put(28,"KARTAL");
	cityTown.put(28,"KÜÇÜKÇEKMECE");
	cityTown.put(28,"MALTEPE");
	cityTown.put(28,"PENDİK");
	cityTown.put(28,"SARIYER");
	cityTown.put(28,"SİLİVRİ");
	cityTown.put(28,"SULTANBEYLİ");
	cityTown.put(28,"ŞİLE");
	cityTown.put(28,"ŞİŞLİ");
	cityTown.put(28,"TUZLA");
	cityTown.put(28,"ÜMRANİYE");
	cityTown.put(28,"ÜSKÜDAR");
	cityTown.put(28,"ZEYTİNBURNU");
	cityTown.put(29,"ÇERKEZKÖY");
	cityTown.put(29,"ÇORLU");
	cityTown.put(29,"HAYRABOLU");
	cityTown.put(29,"MALKARA");
	cityTown.put(29,"MARMARA EREĞLİSİ");
	cityTown.put(29,"MERKEZ");
	cityTown.put(29,"MURATLI");
	cityTown.put(29,"SARAY");
	cityTown.put(29,"ŞARKÖY");
	cityTown.put(30,"ALİAĞA");
	cityTown.put(30,"BALÇOVA");
	cityTown.put(30,"BAYINDIR");
	cityTown.put(30,"BERGAMA");
	cityTown.put(30,"BEYDAĞ");
	cityTown.put(30,"BORNOVA");
	cityTown.put(30,"BUCA");
	cityTown.put(30,"ÇEŞME");
	cityTown.put(30,"DİKİLİ");
	cityTown.put(30,"FOÇA");
	cityTown.put(30,"GÜZELBAHÇE");
	cityTown.put(30,"KARABURUN");
	cityTown.put(30,"KARŞIYAKA");
	cityTown.put(30,"KEMALPAŞA");
	cityTown.put(30,"KINIK");
	cityTown.put(30,"KİRAZ");
	cityTown.put(30,"KONAK");
	cityTown.put(30,"MENDERES");
	cityTown.put(30,"MENEMEN");
	cityTown.put(30,"NARLIDERE");
	cityTown.put(30,"ÖDEMİŞ");
	cityTown.put(30,"SEFERİHİSAR");
	cityTown.put(30,"SELÇUK");
	cityTown.put(30,"TİRE");
	cityTown.put(30,"TORBALI");
	cityTown.put(30,"URLA");
	cityTown.put(31,"AHMETLİ");
	cityTown.put(31,"AKHİSAR");
	cityTown.put(31,"ALAŞEHİR");
	cityTown.put(31,"DEMİRCİ");
	cityTown.put(31,"GÖLMARMARA");
	cityTown.put(31,"GÖRDES");
	cityTown.put(31,"KIRKAĞAÇ");
	cityTown.put(31,"KULA");
	cityTown.put(31,"MERKEZ");
	cityTown.put(31,"SALİHLİ");
	cityTown.put(31,"SARUHANLI");
	cityTown.put(31,"SOMA");
	cityTown.put(31,"TURGUTLU");
	cityTown.put(32,"HASANKEYF");
	cityTown.put(32,"MERKEZ");
	cityTown.put(33,"MERKEZ");
	cityTown.put(34,"ÇERMİK");
	cityTown.put(34,"EĞİL");
	cityTown.put(34,"ERGANİ");
	cityTown.put(34,"HANİ");
	cityTown.put(34,"HAZRO");
	cityTown.put(34,"KOCAKÖY");
	cityTown.put(34,"LİCE");
	cityTown.put(34,"MERKEZ");
	cityTown.put(34,"SİLVAN");
	cityTown.put(35,"DERİK");
	cityTown.put(35,"KIZILTEPE");
	cityTown.put(35,"MAZIDAĞI");
	cityTown.put(35,"MERKEZ");
	cityTown.put(35,"MİDYAT");
	cityTown.put(35,"NUSAYBİN");
	cityTown.put(35,"ÖMERLİ");
	cityTown.put(35,"SAVUR");
	cityTown.put(36,"ENEZ");
	cityTown.put(36,"HAVSA");
	cityTown.put(36,"İPSALA");
	cityTown.put(36,"KEŞAN");
	cityTown.put(36,"LALAPAŞA");
	cityTown.put(36,"MERİÇ");
	cityTown.put(36,"MERKEZ");
	cityTown.put(36,"UZUNKÖPRÜ");
	cityTown.put(37,"BABAESKİ");
	cityTown.put(37,"LÜLEBURGAZ");
	cityTown.put(37,"MERKEZ");
	cityTown.put(37,"PEHLİVANKÖY");
	cityTown.put(37,"PINARHİSAR");
	cityTown.put(37,"VİZE");
	cityTown.put(38,"DİYADİN");
	cityTown.put(38,"DOĞUBEYAZIT");
	cityTown.put(38,"MERKEZ");
	cityTown.put(38,"PATNOS");
	cityTown.put(38,"TUTAK");
	cityTown.put(39,"ÇILDIR");
	cityTown.put(39,"GÖLE");
	cityTown.put(39,"MERKEZ");
	cityTown.put(40,"AYDINTEPE");
	cityTown.put(40,"DEMİRÖZÜ");
	cityTown.put(40,"MERKEZ");
	cityTown.put(41,"ÇAYIRLI");
	cityTown.put(41,"ILIÇ");
	cityTown.put(41,"KEMAH");
	cityTown.put(41,"KEMALİYE");
	cityTown.put(41,"MERKEZ");
	cityTown.put(41,"REFAHİYE");
	cityTown.put(41,"TERCAN");
	cityTown.put(41,"ÜZÜMLÜ");
	cityTown.put(42,"AŞKALE");
	cityTown.put(42,"HINIS");
	cityTown.put(42,"HORASAN");
	cityTown.put(42,"ILICA");
	cityTown.put(42,"İSPİR");
	cityTown.put(42,"NARMAN");
	cityTown.put(42,"OLTU");
	cityTown.put(42,"OLUR");
	cityTown.put(42,"PASİNLER");
	cityTown.put(42,"TORTUM");
	cityTown.put(43,"MERKEZ");
	cityTown.put(44,"KAĞIZMAN");
	cityTown.put(44,"MERKEZ");
	cityTown.put(44,"SARIKAMIŞ");
	cityTown.put(45,"ARABAN");
	cityTown.put(45,"ISLAHİYE");
	cityTown.put(45,"NİZİP");
	cityTown.put(45,"NURDAĞI");
	cityTown.put(45,"OĞUZELİ");
	cityTown.put(45,"ŞAHİNBEY");
	cityTown.put(45,"ŞEHİTKAMİL");
	cityTown.put(45,"YAVUZELİ");
	cityTown.put(46,"MERKEZ");
	cityTown.put(47,"ALTINÖZÜ");
	cityTown.put(47,"BELEN");
	cityTown.put(47,"DÖRTYOL");
	cityTown.put(47,"ERZİN");
	cityTown.put(47,"İSKENDERUN");
	cityTown.put(47,"KIRIKHAN");
	cityTown.put(47,"KUMLU");
	cityTown.put(47,"MERKEZ");
	cityTown.put(47,"REYHANLI");
	cityTown.put(47,"SAMANDAĞI");
	cityTown.put(47,"YAYLADAĞI");
	cityTown.put(48,"AFŞIN");
	cityTown.put(48,"ANDIRIN");
	cityTown.put(48,"ÇAĞLAYANCERİT");
	cityTown.put(48,"ELBİSTAN");
	cityTown.put(48,"GÖKSUN");
	cityTown.put(48,"MERKEZ");
	cityTown.put(48,"PAZARCIK");
	cityTown.put(49,"AMASRA");
	cityTown.put(49,"MERKEZ");
	cityTown.put(49,"ULUS");
	cityTown.put(50,"ESKİPAZAR");
	cityTown.put(50,"MERKEZ");
	cityTown.put(50,"SAFRANBOLU");
	cityTown.put(51,"ABANA");
	cityTown.put(51,"ARAC");
	cityTown.put(51,"BOZKURT");
	cityTown.put(51,"CİDE");
	cityTown.put(51,"ÇATALZEYTİN");
	cityTown.put(51,"DADAY");
	cityTown.put(51,"DEVREKANI");
	cityTown.put(51,"HANÖNÜ");
	cityTown.put(51,"İHSANGAZİ");
	cityTown.put(51,"İNEBOLU");
	cityTown.put(51,"KÜRE");
	cityTown.put(51,"MERKEZ");
	cityTown.put(51,"TAŞKÖPRÜ");
	cityTown.put(51,"TOSYA");
	cityTown.put(52,"ALAPLI");
	cityTown.put(52,"ÇAYCUMA");
	cityTown.put(52,"DEVREK");
	cityTown.put(52,"EREĞLİ");
	cityTown.put(52,"MERKEZ");
	cityTown.put(53,"AKKIŞLA");
	cityTown.put(53,"BÜNYAN");
	cityTown.put(53,"DEVELİ");
	cityTown.put(53,"FELAHİYE");
	cityTown.put(53,"HACILAR");
	cityTown.put(53,"İNCESU");
	cityTown.put(53,"KOCASİNAN");
	cityTown.put(53,"MELİKGAZİ");
	cityTown.put(53,"ÖZVATAN");
	cityTown.put(53,"PINARBAŞI");
	cityTown.put(53,"TALAS");
	cityTown.put(53,"TOMARZA");
	cityTown.put(53,"YAHYALI");
	cityTown.put(53,"YEŞİLHİSAR");
	cityTown.put(54,"AKPINAR");
	cityTown.put(54,"ÇİÇEKDAĞI");
	cityTown.put(54,"KAMAN");
	cityTown.put(54,"MERKEZ");
	cityTown.put(54,"MUCUR");
	cityTown.put(55,"AVANOS");
	cityTown.put(55,"DERİNKUYU");
	cityTown.put(55,"GÜLŞEHİR");
	cityTown.put(55,"HACIBEKTAŞ");
	cityTown.put(55,"KOZAKLI");
	cityTown.put(55,"MERKEZ");
	cityTown.put(55,"ÜRGÜP");
	cityTown.put(56,"ALTUNHİSAR");
	cityTown.put(56,"BOR");
	cityTown.put(56,"MERKEZ");
	cityTown.put(56,"ULUKIŞLA");
	cityTown.put(57,"ESKİL");
	cityTown.put(57,"GÜLAĞAÇ");
	cityTown.put(57,"GÜZELYURT");
	cityTown.put(57,"MERKEZ");
	cityTown.put(58,"AYRANCI");
	cityTown.put(58,"BAŞYAYLA");
	cityTown.put(58,"ERMENEK");
	cityTown.put(58,"MERKEZ");
	cityTown.put(59,"AKÖREN");
	cityTown.put(59,"AKŞEHİR");
	cityTown.put(59,"ALTINEKİN");
	cityTown.put(59,"BEYŞEHİR");
	cityTown.put(59,"BOZKIR");
	cityTown.put(59,"CİHANBEYLİ");
	cityTown.put(59,"ÇELTİK");
	cityTown.put(59,"ÇUMRA");
	cityTown.put(59,"DERBENT");
	cityTown.put(59,"DOĞANHİSAR");
	cityTown.put(59,"EMİRGAZİ");
	cityTown.put(59,"EREĞLİ");
	cityTown.put(59,"HADIM");
	cityTown.put(59,"HÜYÜK");
	cityTown.put(59,"ILGIN");
	cityTown.put(59,"KADINHANI");
	cityTown.put(59,"KARAPINAR");
	cityTown.put(59,"KARATAY");
	cityTown.put(59,"MERAM");
	cityTown.put(59,"SARAYÖNÜ");
	cityTown.put(59,"SELÇUKLU");
	cityTown.put(59,"SEYDİŞEHİR");
	cityTown.put(59,"TAŞKENT");
	cityTown.put(59,"YUNAK");
	cityTown.put(60,"BAŞMAKÇI");
	cityTown.put(60,"BOLVADİN");
	cityTown.put(60,"ÇAY");
	cityTown.put(60,"ÇOBANLAR");
	cityTown.put(60,"DİNAR");
	cityTown.put(60,"EMİRDAĞ");
	cityTown.put(60,"İHSANİYE");
	cityTown.put(60,"KIZILÖREN");
	cityTown.put(60,"MERKEZ");
	cityTown.put(60,"SANDIKLI");
	cityTown.put(60,"SİNCANLI");
	cityTown.put(60,"SUHUT");
	cityTown.put(60,"SULTANDAĞI");
	cityTown.put(61,"ALPU");
	cityTown.put(61,"BEYLİKOVA");
	cityTown.put(61,"ÇİFTELER");
	cityTown.put(61,"GÜNYÜZÜ");
	cityTown.put(61,"HAN");
	cityTown.put(61,"İNÖNÜ");
	cityTown.put(61,"MAHMUDİYE");
	cityTown.put(61,"MERKEZ");
	cityTown.put(61,"MİHALIÇCIK");
	cityTown.put(61,"SEYİTGAZİ");
	cityTown.put(61,"SİVRİHİSAR");
	cityTown.put(62,"ALTINTAŞ");
	cityTown.put(62,"DOMANİC");
	cityTown.put(62,"EMET");
	cityTown.put(62,"GEDİZ");
	cityTown.put(62,"MERKEZ");
	cityTown.put(62,"PAZARLAR");
	cityTown.put(62,"SİMAV");
	cityTown.put(62,"TAVŞANLI");
	cityTown.put(63,"BANAZ");
	cityTown.put(63,"EŞME");
	cityTown.put(63,"MERKEZ");
	cityTown.put(63,"SİVASLI");
	cityTown.put(63,"ULUBEY");
	cityTown.put(64,"AĞİN");
	cityTown.put(64,"ARICAK");
	cityTown.put(64,"BASKIL");
	cityTown.put(64,"KARAKOÇAN");
	cityTown.put(64,"KEBAN");
	cityTown.put(64,"KOVANCILAR");
	cityTown.put(64,"MADEN");
	cityTown.put(64,"MERKEZ");
	cityTown.put(64,"PALU");
	cityTown.put(64,"SİVRİCE");
	cityTown.put(65,"AKÇADAĞ");
	cityTown.put(65,"ARAPKIR");
	cityTown.put(65,"ARGUVAN");
	cityTown.put(65,"BATTALGAZİ");
	cityTown.put(65,"DARENDE");
	cityTown.put(65,"DOĞANŞEHİR");
	cityTown.put(65,"HEKİMHAN");
	cityTown.put(65,"MERKEZ");
	cityTown.put(65,"PÖTÜRGE");
	cityTown.put(65,"YAZIHAN");
	cityTown.put(65,"YEŞİLYURT");
	cityTown.put(66,"ÇEMİŞGEZEK");
	cityTown.put(66,"HOZAT");
	cityTown.put(66,"MAZGİRT");
	cityTown.put(66,"MERKEZ");
	cityTown.put(66,"NAZİMİYE");
	cityTown.put(66,"PERTEK");
	cityTown.put(67,"AKKUŞ");
	cityTown.put(67,"FATSA");
	cityTown.put(67,"GÖLKÖY");
	cityTown.put(67,"KABADÜZ");
	cityTown.put(67,"MERKEZ");
	cityTown.put(67,"MESUDİYE");
	cityTown.put(67,"PERŞEMBE");
	cityTown.put(67,"ULUBEY");
	cityTown.put(67,"ÜNYE");
	cityTown.put(68,"ALACAM");
	cityTown.put(68,"BAFRA");
	cityTown.put(68,"ÇARŞAMBA");
	cityTown.put(68,"HAVZA");
	cityTown.put(68,"KAVAK");
	cityTown.put(68,"LADİK");
	cityTown.put(68,"MERKEZ");
	cityTown.put(68,"SALIPAZARI");
	cityTown.put(68,"TEKKEKÖY");
	cityTown.put(68,"TERME");
	cityTown.put(68,"VEZİRKÖPRÜ");
	cityTown.put(69,"AYANCIK");
	cityTown.put(69,"BOYABAT");
	cityTown.put(69,"DURAĞAN");
	cityTown.put(69,"ERFELEK");
	cityTown.put(69,"GERZE");
	cityTown.put(69,"MERKEZ");
	cityTown.put(70,"ALTINYAYLA");
	cityTown.put(70,"DİVRİĞİ");
	cityTown.put(70,"DOĞANSAR");
	cityTown.put(70,"GEMEREK");
	cityTown.put(70,"HAFIK");
	cityTown.put(70,"KANGAL");
	cityTown.put(70,"MERKEZ");
	cityTown.put(70,"SARKIŞLA");
	cityTown.put(70,"SUŞEHRİ");
	cityTown.put(70,"YILDIZELİ");
	cityTown.put(70,"ZARA");
	cityTown.put(71,"BOĞAZLIYAN");
	cityTown.put(71,"ÇANDIR");
	cityTown.put(71,"ÇAYIRALAN");
	cityTown.put(71,"MERKEZ");
	cityTown.put(71,"SARIKAYA");
	cityTown.put(71,"SEFAATLİ");
	cityTown.put(71,"SORGUN");
	cityTown.put(71,"YENİFAKILI");
	cityTown.put(71,"YERKÖY");
	cityTown.put(72,"BESNİ");
	cityTown.put(72,"GÖLBAŞI");
	cityTown.put(72,"KAHTA");
	cityTown.put(72,"MERKEZ");
	cityTown.put(73,"AKÇAKALE");
	cityTown.put(73,"BİRECİK");
	cityTown.put(73,"BOZOVA");
	cityTown.put(73,"HALFETİ");
	cityTown.put(73,"HARRAN");
	cityTown.put(73,"HİLVAN");
	cityTown.put(73,"MERKEZ");
	cityTown.put(73,"SİVEREK");
	cityTown.put(73,"SURUÇ");
	cityTown.put(73,"VİRANŞEHİR");
	cityTown.put(74,"GÖYNÜCEK");
	cityTown.put(74,"GÜMÜŞHACIKÖY");
	cityTown.put(74,"MERKEZ");
	cityTown.put(74,"MERZİFON");
	cityTown.put(74,"SULUOVA");
	cityTown.put(74,"TAŞOVA");
	cityTown.put(75,"ALACA");
	cityTown.put(75,"BOĞAZKALE");
	cityTown.put(75,"ISKILIP");
	cityTown.put(75,"KARGI");
	cityTown.put(75,"MECİTÖZÜ");
	cityTown.put(75,"MERKEZ");
	cityTown.put(75,"OĞUZLAR");
	cityTown.put(75,"OSMANCIK");
	cityTown.put(75,"SUNGURLU");
	cityTown.put(75,"UĞURLUDAĞ");
	cityTown.put(76,"ALMUS");
	cityTown.put(76,"ERBAA");
	cityTown.put(76,"MERKEZ");
	cityTown.put(76,"NİKSAR");
	cityTown.put(76,"PAZAR");
	cityTown.put(76,"REŞADİYE");
	cityTown.put(76,"SULUSARAY");
	cityTown.put(76,"TURHAL");
	cityTown.put(76,"ZİLE");
	cityTown.put(77,"ARDANUC");
	cityTown.put(77,"ARHAVİ");
	cityTown.put(77,"HOPA");
	cityTown.put(77,"MERKEZ");
	cityTown.put(77,"MURGÜL");
	cityTown.put(77,"SAVSAT");
	cityTown.put(77,"YUSUFELİ");
	cityTown.put(78,"ALUCRA");
	cityTown.put(78,"BULANCAK");
	cityTown.put(78,"DERELİ");
	cityTown.put(78,"ESPİYE");
	cityTown.put(78,"EYNESİL");
	cityTown.put(78,"GÖRELE");
	cityTown.put(78,"KEŞAP");
	cityTown.put(78,"MERKEZ");
	cityTown.put(78,"SEBİNKARAHİSAR");
	cityTown.put(78,"TİREBOLU");
	cityTown.put(79,"KELKİT");
	cityTown.put(79,"KURTUN");
	cityTown.put(79,"MERKEZ");
	cityTown.put(79,"ŞİRAN");
	cityTown.put(80,"ÇAYELİ");
	cityTown.put(80,"FINDIKLI");
	cityTown.put(80,"MERKEZ");
	cityTown.put(80,"PAZAR");
	cityTown.put(81,"AKÇAABAT");
	cityTown.put(81,"ARAKLI");
	cityTown.put(81,"ARŞIN");
	cityTown.put(81,"BEŞİKDÜZÜ");
	cityTown.put(81,"ÇARŞIBAŞI");
	cityTown.put(81,"ÇAYKARA");
	cityTown.put(81,"DERNEK PAZARI");
	cityTown.put(81,"MAÇKA");
	cityTown.put(81,"MERKEZ");
	cityTown.put(81,"OF");
	cityTown.put(81,"SÜRMENE");
	cityTown.put(81,"TONYA");
	cityTown.put(81,"VAKFIKEBİR");
	cityTown.put(81,"YOMRA");
	cityTown.put(56,"ÇAMARDI");
	cityTown.put(56,"ÇİFTLİK");
	
	int cityName = Integer.parseInt(request.getParameter("id"));
	
	if(cityName == 0)
	{
		String json = "[";
		json += "{\"optionValue\":0, \"optionDisplay\": \"Seçim yapınız\"}";
		out.println(json+"]");
	}
	else
	{
		String json = "[";
		
		for (Map.Entry<Integer, String> entry : cityTown.entries()) {
			
			if(entry.getKey() == cityName)
			{
				json += "{\"optionValue\":\""+entry.getValue()+"\", \"optionDisplay\": \""+entry.getValue()+"\"},";
			}
		}
		
		int strLen = json.length();
		int lastIdx = strLen - 1;
		
		String s = json.substring(0, lastIdx);
		 
		out.println(s+"]");
	}
	

%>